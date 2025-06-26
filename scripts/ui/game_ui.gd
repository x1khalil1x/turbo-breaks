extends Control
class_name GameUI

## GameUI - Main UI Coordinator and Controller
## Based on UI_RULES.md - Foundation First UI System
## Manages UI layers, theme application, and component registration

# UI Layer References
@onready var background_layer = $UILayers/BackgroundLayer
@onready var hud_layer = $UILayers/HUDLayer
@onready var overlay_layer = $UILayers/OverlayLayer
@onready var modal_layer = $UILayers/ModalLayer
@onready var debug_layer = $UILayers/DebugLayer

# HUD Components
@onready var hud = $UILayers/HUDLayer/HUD
@onready var top_bar = $UILayers/HUDLayer/HUD/TopBar
@onready var bottom_bar = $UILayers/HUDLayer/HUD/BottomBar
@onready var notification_panel = $UILayers/OverlayLayer/NotificationPanel
@onready var pause_menu = $UILayers/OverlayLayer/PauseMenu
@onready var modal_background = $UILayers/ModalLayer/ModalBackground
@onready var modal_container = $UILayers/ModalLayer/ModalContainer
@onready var debug_overlay = $UILayers/DebugLayer/DebugOverlay

# UI State Management
var current_ui_mode: String = "exploration"
var registered_ui_components: Array[Control] = []
var active_modals: Array[Control] = []
var hud_elements: Dictionary = {}

# Signals following UI_RULES.md contract
signal ui_component_registered(component: Control, component_type: String)
signal ui_mode_changed(old_mode: String, new_mode: String)
signal modal_opened(modal: Control, modal_id: String)
signal modal_closed(modal: Control, modal_id: String)

func _ready():
	print("GameUI: Initializing main UI coordinator")
	
	# Initialize UI system
	initialize_ui_system()
	
	# Connect to autoload systems
	connect_to_autoloads()
	
	# Apply current theme
	apply_current_theme()
	
	# Setup initial UI state
	set_ui_mode("exploration")
	
	# Register with UIStateManager
	UIStateManager.register_ui_component(self)
	
	DebugManager.log_info("GameUI: Main UI coordinator ready")

func initialize_ui_system():
	"""Initialize the UI component system"""
	# Register core UI layers
	register_ui_component(hud, "hud_layer")
	register_ui_component(overlay_layer, "overlay_layer")
	register_ui_component(modal_layer, "modal_layer")
	
	# Configure layer properties
	setup_ui_layers()
	
	# Initialize notification system
	setup_notification_system()
	
	# Initialize modal system
	setup_modal_system()
	
	DebugManager.log_info("GameUI: UI system initialized with layered architecture")

func setup_ui_layers():
	"""Configure UI layer properties for proper rendering order"""
	# Background layer - lowest priority, non-interactive
	background_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# HUD layer - non-blocking, passes input through when not focused
	hud_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Overlay layer - interactive but not blocking
	overlay_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Modal layer - blocks input when active
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Only active when modal is shown
	
	# Debug layer - highest priority, non-blocking
	debug_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup_notification_system():
	"""Initialize notification display system"""
	if NotificationManager:
		NotificationManager.notification_created.connect(_on_notification_created)
		NotificationManager.notification_dismissed.connect(_on_notification_dismissed)
		
		# Configure notification panel
		notification_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		notification_panel.add_theme_constant_override("separation", 8)

func setup_modal_system():
	"""Initialize modal dialog system"""
	if UIStateManager:
		UIStateManager.modal_opened.connect(_on_modal_opened)
		UIStateManager.modal_closed.connect(_on_modal_closed)
		
	# Configure modal background
	modal_background.color = Color(0, 0, 0, 0.7)
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP

func connect_to_autoloads():
	"""Connect to autoload systems for theme and state management"""
	# Wait for next frame to ensure autoloads are ready
	await get_tree().process_frame
	
	# Theme system connection
	if UIThemeManager:
		UIThemeManager.theme_changed.connect(_on_theme_changed)
		UIThemeManager.theme_config_changed.connect(_on_theme_config_changed)
		UIThemeManager.accessibility_settings_changed.connect(_on_accessibility_changed)
		print("GameUI: Connected to UIThemeManager")
	else:
		print("GameUI: UIThemeManager not available - theme integration disabled")
	
	# State management connection
	if UIStateManager:
		UIStateManager.ui_state_changed.connect(_on_ui_state_changed)
		UIStateManager.game_mode_changed.connect(_on_game_mode_changed)
		UIStateManager.modal_opened.connect(_on_modal_opened)
		UIStateManager.modal_closed.connect(_on_modal_closed)
		print("GameUI: Connected to UIStateManager")
	else:
		print("GameUI: UIStateManager not available - state integration disabled")
	
	# Notification system connection
	if NotificationManager:
		NotificationManager.notification_added.connect(_on_notification_created)
		NotificationManager.notification_removed.connect(_on_notification_dismissed)
		print("GameUI: Connected to NotificationManager")
	else:
		print("GameUI: NotificationManager not available - notification integration disabled")
	
	# Debug system connection
	if DebugManager and DebugManager.has_signal("debug_mode_toggled"):
		DebugManager.debug_mode_toggled.connect(_on_debug_mode_toggled)
		print("GameUI: Connected to DebugManager")
	else:
		print("GameUI: DebugManager debug_mode_toggled not available - debug integration disabled")

# Theme Management Functions
func apply_current_theme():
	"""Apply current theme to all registered UI components"""
	if not UIThemeManager:
		DebugManager.log_warning("GameUI: UIThemeManager not available for theme application")
		return
	
	var current_theme = UIThemeManager.get_current_theme()
	if current_theme:
		# Apply theme to root control
		theme = current_theme
		
		# Apply to all registered components
		for component in registered_ui_components:
			if component and is_instance_valid(component):
				apply_theme_to_component(component, current_theme)
		
		DebugManager.log_info("GameUI: Theme applied to " + str(registered_ui_components.size()) + " components")

func apply_theme_to_component(component: Control, ui_theme: Theme):
	"""Apply theme to a specific UI component"""
	if component and ui_theme:
		component.theme = ui_theme
		
		# If component has custom theme application method, call it
		if component.has_method("apply_theme_changes"):
			component.apply_theme_changes(UIThemeManager.current_theme_config)

# UI Component Registration System
func register_ui_component(component: Control, component_type: String = ""):
	"""Register UI component for theme updates and management"""
	if not component:
		DebugManager.log_warning("GameUI: Attempted to register null component")
		return
	
	if component in registered_ui_components:
		return  # Already registered
	
	registered_ui_components.append(component)
	
	# Apply current theme to new component
	if UIThemeManager and UIThemeManager.current_theme:
		apply_theme_to_component(component, UIThemeManager.current_theme)
	
	ui_component_registered.emit(component, component_type)
	DebugManager.log_info("GameUI: Registered UI component - " + component_type)

func unregister_ui_component(component: Control):
	"""Unregister UI component"""
	if component in registered_ui_components:
		registered_ui_components.erase(component)

# UI Mode Management
func set_ui_mode(new_mode: String):
	"""Change UI mode and update component visibility"""
	if new_mode == current_ui_mode:
		return
	
	var old_mode = current_ui_mode
	current_ui_mode = new_mode
	
	# Update UI based on mode
	update_ui_for_mode(new_mode)
	
	ui_mode_changed.emit(old_mode, new_mode)
	DebugManager.log_info("GameUI: UI mode changed from " + old_mode + " to " + new_mode)

func update_ui_for_mode(mode: String):
	"""Update UI layout and visibility based on current mode"""
	match mode:
		"exploration":
			show_exploration_ui()
		"driving":
			show_driving_ui()
		"character_select":
			show_character_select_ui()
		"world_map":
			show_world_map_ui()
		"menu":
			show_menu_ui()
		_:
			DebugManager.log_warning("GameUI: Unknown UI mode - " + mode)

func show_exploration_ui():
	"""Configure UI for exploration mode"""
	hud_layer.visible = true
	# Show minimap, interaction prompts, inventory access
	
func show_driving_ui():
	"""Configure UI for driving mode"""
	hud_layer.visible = true
	# Show speedometer, turbo meter, checkpoint progress
	
func show_character_select_ui():
	"""Configure UI for character selection"""
	hud_layer.visible = false
	# Show character customization interface
	
func show_world_map_ui():
	"""Configure UI for world map"""
	hud_layer.visible = false
	# Show full-screen map interface
	
func show_menu_ui():
	"""Configure UI for menu screens"""
	hud_layer.visible = false
	# Show menu interface only

# Modal Management Functions
func show_modal(modal_scene: PackedScene, modal_id: String, modal_data: Dictionary = {}) -> Control:
	"""Display modal dialog with proper input blocking"""
	if not modal_scene:
		DebugManager.log_error("GameUI: Cannot show modal - scene is null")
		return null
	
	# Instantiate modal
	var modal_instance = modal_scene.instantiate()
	if not modal_instance:
		DebugManager.log_error("GameUI: Failed to instantiate modal scene")
		return null
	
	# Configure modal
	modal_container.add_child(modal_instance)
	modal_background.visible = true
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Register with state manager
	UIStateManager.open_modal(modal_id, modal_instance, true)
	
	active_modals.append(modal_instance)
	modal_opened.emit(modal_instance, modal_id)
	
	return modal_instance

func close_modal(modal_id: String, result: Dictionary = {}):
	"""Close specific modal dialog"""
	UIStateManager.close_modal(modal_id, result)

func close_all_modals():
	"""Close all open modals"""
	for modal in active_modals:
		if modal and is_instance_valid(modal):
			modal.queue_free()
	
	active_modals.clear()
	modal_background.visible = false
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Signal Handlers
func _on_theme_changed(_theme_name: String, _theme_resource: Theme):
	"""Handle theme change from UIThemeManager"""
	apply_current_theme()

func _on_theme_config_changed(_theme_config):
	"""Handle theme configuration change"""
	# Apply advanced theme features based on config
	if _theme_config.reduced_motion:
		# Disable or reduce UI animations
		pass
	
	if _theme_config.large_text_mode:
		# Increase text scaling
		pass

func _on_accessibility_changed(_settings: Dictionary):
	"""Handle accessibility setting changes"""
	DebugManager.log_info("GameUI: Accessibility settings updated")

func _on_ui_state_changed(new_state, _old_state):
	"""Handle UI state changes from UIStateManager"""
	match new_state:
		UIStateManager.UIState.PAUSE:
			pause_menu.visible = true
		UIStateManager.UIState.GAMEPLAY:
			pause_menu.visible = false
		UIStateManager.UIState.LOADING:
			# Show loading indicator
			pass

func _on_game_mode_changed(new_mode, _old_mode):
	"""Handle game mode changes from UIStateManager"""
	var mode_name = UIStateManager.GameMode.keys()[new_mode].to_lower()
	set_ui_mode(mode_name)



func _on_notification_dismissed(_notification_id: String):
	"""Handle notification dismissal"""
	remove_notification_ui(_notification_id)

func _on_modal_opened(modal_id: String):
	"""Handle modal opened from UIStateManager"""
	if DebugManager:
		DebugManager.log_info("GameUI: Modal opened - " + modal_id)
	else:
		print("GameUI: Modal opened - " + modal_id)

func _on_modal_closed(modal_id: String, _result: Dictionary):
	"""Handle modal closed from UIStateManager"""
	# Clean up modal UI
	if active_modals.size() == 0:
		modal_background.visible = false
		modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	modal_closed.emit(null, modal_id)  # modal reference handled by UIStateManager

func _on_notification_created(_notification_data):
	"""Handle new notification creation"""
	# Create notification UI element
	create_notification_ui(_notification_data)

func _on_notification_dismissed(_notification_id: String):
	"""Handle notification dismissal"""
	remove_notification_ui(_notification_id)

func _on_debug_mode_toggled(enabled: bool):
	"""Handle debug mode toggle"""
	debug_overlay.visible = enabled

# Notification UI Functions
func create_notification_ui(_notification_data: Dictionary):
	"""Create UI element for notification"""
	# Implementation will be added when we create NotificationToast component
	pass

func remove_notification_ui(_notification_id: String):
	"""Remove notification UI element"""
	# Implementation will be added when we create NotificationToast component
	pass

# Validation and Debug Functions
func validate_ui_system() -> bool:
	"""Validate UI system integrity"""
	var validation_passed = true
	
	# Check layer structure
	if not hud_layer or not overlay_layer or not modal_layer:
		DebugManager.log_error("GameUI: Missing critical UI layers")
		validation_passed = false
	
	# Check autoload connections
	if not UIThemeManager or not UIStateManager:
		DebugManager.log_error("GameUI: Missing autoload connections")
		validation_passed = false
	
	# Check theme application
	if not theme:
		DebugManager.log_warning("GameUI: No theme applied")
	
	return validation_passed

func get_debug_info() -> Dictionary:
	"""Get comprehensive UI system debug information"""
	return {
		"current_mode": current_ui_mode,
		"registered_components": registered_ui_components.size(),
		"active_modals": active_modals.size(),
		"theme_applied": theme != null,
		"validation_status": validate_ui_system(),
		"layer_visibility": {
			"hud": hud_layer.visible,
			"overlay": overlay_layer.visible,
			"modal": modal_layer.visible,
			"debug": debug_layer.visible
		}
	}

# SCENE_TAG: UI_COORDINATOR - enables smart UI routing and management
const SCENE_TAGS = ["UI_COORDINATOR", "UI_FOUNDATION", "UI_THEME_AWARE"] 
