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
@onready var top_bar = $UILayers/HUDLayer/HUD/VBoxContainer/TopBar
@onready var bottom_bar = $UILayers/HUDLayer/HUD/VBoxContainer/BottomBar
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
	
	# Register with UIStateManager if available
	if UIStateManager:
		UIStateManager.register_ui_component(self)
		print("GameUI: Registered with UIStateManager")
	else:
		print("GameUI: UIStateManager not available - continuing without state management")
	
	print("GameUI: Main UI coordinator ready")

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
	
	if DebugManager:
		DebugManager.log_info("GameUI: UI system initialized with layered architecture")
	else:
		print("GameUI: UI system initialized with layered architecture")

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
	# Note: Notification connections are now handled in connect_to_autoloads()
	# Configure notification panel
	notification_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	notification_panel.add_theme_constant_override("separation", 8)
	print("GameUI: Notification panel configured")

func setup_modal_system():
	"""Initialize modal dialog system"""
	if UIStateManager:
		UIStateManager.modal_opened.connect(_on_modal_opened)
		UIStateManager.modal_closed.connect(_on_modal_closed)
		print("GameUI: Modal system connected")
	else:
		print("GameUI: UIStateManager not available - modal system disabled")
		
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
		NotificationManager.notification_added.connect(_on_notification_added)
		NotificationManager.notification_removed.connect(_on_notification_dismissed)
		print("GameUI: Connected to NotificationManager")
	else:
		print("GameUI: NotificationManager not available - notification integration disabled")
	
	# Debug system connection
	if DebugManager:
		if DebugManager.has_signal("debug_mode_toggled"):
			DebugManager.debug_mode_toggled.connect(_on_debug_mode_toggled)
			print("GameUI: Connected to DebugManager debug_mode_toggled signal")
		else:
			print("GameUI: DebugManager found but debug_mode_toggled signal not available")
	else:
		print("GameUI: DebugManager not available - debug integration disabled")

# Theme Management Functions
func apply_current_theme():
	"""Apply current theme to all registered UI components"""
	if not UIThemeManager:
		print("GameUI: UIThemeManager not available for theme application")
		return
	
	var current_theme = null
	if UIThemeManager and UIThemeManager.has_method("get_current_theme"):
		current_theme = UIThemeManager.get_current_theme()
	elif UIThemeManager:
		current_theme = UIThemeManager.current_theme
		
	if current_theme:
		# Apply theme to root control
		theme = current_theme
		
		# Apply to all registered components
		for component in registered_ui_components:
			if component and is_instance_valid(component):
				apply_theme_to_component(component, current_theme)
		
		if DebugManager:
			DebugManager.log_info("GameUI: Theme applied to " + str(registered_ui_components.size()) + " components")
		else:
			print("GameUI: Theme applied to " + str(registered_ui_components.size()) + " components")

func apply_theme_to_component(component: Control, ui_theme: Theme):
	"""Apply theme to a specific UI component"""
	if component and ui_theme:
		component.theme = ui_theme
		
		# If component has custom theme application method, call it
		if component.has_method("apply_theme_changes") and UIThemeManager:
			component.apply_theme_changes(UIThemeManager.current_theme_config)

# UI Component Registration System
func register_ui_component(component: Control, component_type: String = ""):
	"""Register UI component for theme updates and management"""
	if not component:
		print("GameUI: Attempted to register null component")
		return
	
	if component in registered_ui_components:
		return  # Already registered
	
	registered_ui_components.append(component)
	
	# Apply current theme to new component
	if UIThemeManager and UIThemeManager.current_theme:
		apply_theme_to_component(component, UIThemeManager.current_theme)
	
	ui_component_registered.emit(component, component_type)
	if DebugManager:
		DebugManager.log_info("GameUI: Registered UI component - " + component_type)
	else:
		print("GameUI: Registered UI component - " + component_type)

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
	if DebugManager:
		DebugManager.log_info("GameUI: UI mode changed from " + old_mode + " to " + new_mode)
	else:
		print("GameUI: UI mode changed from " + old_mode + " to " + new_mode)

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
			if DebugManager:
				DebugManager.log_warning("GameUI: Unknown UI mode - " + mode)
			else:
				print("GameUI: Unknown UI mode - " + mode)

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
func show_modal(modal_scene: PackedScene, modal_id: String, _modal_data: Dictionary = {}) -> Control:
	"""Display modal dialog with proper input blocking"""
	if not modal_scene:
		print("GameUI: ERROR - Cannot show modal - scene is null")
		return null
	
	# Instantiate modal
	var modal_instance = modal_scene.instantiate()
	if not modal_instance:
		print("GameUI: ERROR - Failed to instantiate modal scene")
		return null
	
	# Configure modal
	modal_container.add_child(modal_instance)
	modal_background.visible = true
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Register with state manager
	if UIStateManager:
		UIStateManager.open_modal(modal_id, modal_instance, true)
	
	active_modals.append(modal_instance)
	modal_opened.emit(modal_instance, modal_id)
	
	return modal_instance

func close_modal(modal_id: String, result: Dictionary = {}):
	"""Close specific modal dialog"""
	if UIStateManager:
		UIStateManager.close_modal_dialog(modal_id, result)

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
	if DebugManager:
		DebugManager.log_info("GameUI: Accessibility settings updated")
	else:
		print("GameUI: Accessibility settings updated")

func _on_ui_state_changed(new_state, _old_state):
	"""Handle UI state changes from UIStateManager"""
	if not UIStateManager:
		return
		
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
	if not UIStateManager:
		return
		
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

func _on_notification_added(_notification_data):
	"""Handle new notification creation"""
	# Create notification UI element
	create_notification_ui(_notification_data)

func _on_debug_mode_toggled(enabled: bool):
	"""Handle debug mode toggle"""
	debug_overlay.visible = enabled
	
	if enabled:
		# Add debug information to the overlay
		update_debug_overlay_content()
		DebugManager.log_info("GameUI: Visual debug overlay ENABLED")
	else:
		DebugManager.log_info("GameUI: Visual debug overlay DISABLED")

func update_debug_overlay_content():
	"""Update debug overlay with current information"""
	# Clear existing debug content
	for child in debug_overlay.get_children():
		child.queue_free()
	
	# Create debug information panel
	var debug_panel = create_debug_info_panel()
	debug_overlay.add_child(debug_panel)
	
	# Create performance monitor
	var perf_panel = create_performance_panel()
	debug_overlay.add_child(perf_panel)

func create_debug_info_panel() -> Panel:
	"""Create the main debug information panel"""
	var panel = Panel.new()
	panel.size = Vector2(300, 200)
	panel.position = Vector2(10, 10)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(10, 10)
	vbox.size = Vector2(280, 180)
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "🔧 DEBUG OVERLAY"
	title.add_theme_stylebox_override("normal", StyleBoxFlat.new())
	vbox.add_child(title)
	
	# Scene info
	var scene_info = Label.new()
	var current_scene = get_tree().current_scene
	scene_info.text = "📍 Scene: " + (current_scene.name if current_scene else "Unknown")
	vbox.add_child(scene_info)
	
	# Player info
	var player_info = Label.new()
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_info.text = "🎮 Player: " + str(players[0].global_position)
	else:
		player_info.text = "🎮 Player: Not found"
	vbox.add_child(player_info)
	
	# UI info
	var ui_info = Label.new()
	ui_info.text = "🖥️ UI Mode: " + current_ui_mode
	vbox.add_child(ui_info)
	
	# Autoload status
	var autoload_info = Label.new()
	var healthy_autoloads = 0
	var total_autoloads = 11  # Based on your project.godot
	
	if DebugManager: healthy_autoloads += 1
	if SceneManager: healthy_autoloads += 1
	if IndustrialSceneManager: healthy_autoloads += 1
	if UIThemeManager: healthy_autoloads += 1
	if UIStateManager: healthy_autoloads += 1
	if NotificationManager: healthy_autoloads += 1
	
	autoload_info.text = "⚙️ Autoloads: " + str(healthy_autoloads) + "/" + str(total_autoloads) + " healthy"
	vbox.add_child(autoload_info)
	
	# Key commands reminder
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	var commands = Label.new()
	commands.text = "F4=Validate F6=Systems F8=SceneMgr"
	commands.add_theme_font_size_override("font_size", 10)
	vbox.add_child(commands)
	
	return panel

func create_performance_panel() -> Panel:
	"""Create performance monitoring panel"""
	var panel = Panel.new()
	panel.size = Vector2(250, 150)
	panel.position = Vector2(320, 10)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(10, 10)
	vbox.size = Vector2(230, 130)
	panel.add_child(vbox)
	
	# Performance title
	var title = Label.new()
	title.text = "📊 PERFORMANCE"
	vbox.add_child(title)
	
	# FPS
	var fps_label = Label.new()
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	vbox.add_child(fps_label)
	
	# Memory usage
	var memory_label = Label.new()
	memory_label.text = "Memory: " + str(OS.get_static_memory_usage()) + " bytes"
	vbox.add_child(memory_label)
	
	# UI Pool status (if available)
	if IndustrialSceneManager:
		var pool_status = IndustrialSceneManager.get_ui_pool_status()
		var total_pooled = 0
		for scene_type in pool_status:
			total_pooled += pool_status[scene_type]
		
		var pool_label = Label.new()
		pool_label.text = "UI Pool: " + str(total_pooled) + " instances"
		vbox.add_child(pool_label)
	
	return panel

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
		print("GameUI: ERROR - Missing critical UI layers")
		validation_passed = false
	
	# Check autoload connections
	if not UIThemeManager or not UIStateManager:
		print("GameUI: ERROR - Missing autoload connections")
		validation_passed = false
	
	# Check theme application
	if not theme:
		print("GameUI: WARNING - No theme applied")
	
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
