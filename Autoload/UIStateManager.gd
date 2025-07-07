extends Node

## UIStateManager - Phase 1 Implementation
## UI mode and context management, modal dialog handling, input focus control
## Based on UI_RULES.md - Modal Layering and State Management

# UI States and Modes
enum UIState { GAMEPLAY, PAUSE, MENU, LOADING, DIALOG }
enum GameMode { EXPLORATION, DRIVING, CHARACTER_SELECT, WORLD_MAP }

# Current state tracking
var current_ui_state: UIState = UIState.GAMEPLAY
var current_game_mode: GameMode = GameMode.EXPLORATION
var previous_ui_state: UIState = UIState.GAMEPLAY

# Modal dialog management
var modal_stack: Array[String] = []  # Stack of open modal IDs
var modal_components: Dictionary = {}  # modal_id -> node reference
var input_blocked: bool = false

# UI context and focus
var ui_context_data: Dictionary = {}
var active_ui_components: Array[Node] = []
var focus_locked_component: Node = null

# State change signals
signal ui_state_changed(new_state: UIState, previous_state: UIState)
signal game_mode_changed(new_mode: GameMode, previous_mode: GameMode)
signal modal_opened(modal_id: String)
signal modal_closed(modal_id: String, result: Dictionary)
signal input_focus_changed(has_focus: bool, component: Node)

# Modal management signals
signal show_modal(modal_name: String, data: Dictionary)
signal close_modal(modal_name: String)
signal close_all_modals()

# HUD/Interface signals  
signal set_hud_visibility(visible: bool)
signal show_driving_hud()
signal show_exploration_hud()

# Dialog system signals
signal show_dialog(speaker: String, text: String, choices: Array)
signal close_dialog()

# Current UI state tracking
var current_modals: Array[String] = []
var hud_visible: bool = true
var current_hud_mode: String = "exploration"  # "exploration", "driving", "menu"
var dialog_active: bool = false

func _ready():
	print("UIStateManager: Phase 1 initialized")
	
	# Initialize with exploration mode
	set_game_mode(GameMode.EXPLORATION)
	
	# Connect to existing systems - wait for next frame to ensure autoloads are ready
	await get_tree().process_frame
	if DebugManager:
		DebugManager.log_info("UIStateManager: State management ready")
	else:
		print("UIStateManager: DebugManager not available - continuing without logging")

func _unhandled_input(event):
	# Handle global UI input when not blocked
	if input_blocked or modal_stack.size() > 0:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				handle_escape_key()
			KEY_TAB:
				if event.shift_pressed:
					focus_previous_component()
				else:
					focus_next_component()

func handle_escape_key():
	"""Handle escape key based on current UI state"""
	match current_ui_state:
		UIState.GAMEPLAY:
			set_ui_state(UIState.PAUSE)
		UIState.PAUSE:
			set_ui_state(UIState.GAMEPLAY)
		UIState.DIALOG:
			close_top_modal()
		UIState.MENU:
			# Back to previous state or gameplay
			set_ui_state(previous_ui_state if previous_ui_state != UIState.MENU else UIState.GAMEPLAY)

# State Management
func set_ui_state(new_state: UIState):
	"""Change UI state with validation and event emission"""
	if new_state == current_ui_state:
		return
	
	var old_state = current_ui_state
	previous_ui_state = old_state
	current_ui_state = new_state
	
	# Handle state-specific logic
	match new_state:
		UIState.PAUSE:
			get_tree().paused = true
			input_blocked = false
		UIState.GAMEPLAY:
			get_tree().paused = false
			input_blocked = false
			clear_all_modals()  # Ensure clean state
		UIState.LOADING:
			input_blocked = true
		UIState.DIALOG:
			# Don't change pause state, but may block input based on modal
			pass
		UIState.MENU:
			get_tree().paused = true
			input_blocked = false
	
	ui_state_changed.emit(new_state, old_state)
	DebugManager.log_info("UIStateManager: State changed from " + UIState.keys()[old_state] + " to " + UIState.keys()[new_state])

func set_game_mode(new_mode: GameMode):
	"""Change game mode and update UI context"""
	if new_mode == current_game_mode:
		return
	
	var old_mode = current_game_mode
	current_game_mode = new_mode
	
	# Update UI context for new mode
	update_ui_context_for_mode(new_mode)
	
	game_mode_changed.emit(new_mode, old_mode)
	DebugManager.log_info("UIStateManager: Game mode changed from " + GameMode.keys()[old_mode] + " to " + GameMode.keys()[new_mode])

func update_ui_context_for_mode(mode: GameMode):
	"""Update UI context data based on game mode"""
	ui_context_data.clear()
	
	match mode:
		GameMode.EXPLORATION:
			ui_context_data = {
				"show_minimap": true,
				"show_interaction_prompts": true,
				"allow_pause": true,
				"input_mode": "keyboard_mouse"
			}
		GameMode.DRIVING:
			ui_context_data = {
				"show_speed_hud": true,
				"show_turbo_meter": true,
				"allow_pause": true,
				"input_mode": "driving_controls"
			}
		GameMode.CHARACTER_SELECT:
			ui_context_data = {
				"show_character_options": true,
				"allow_back_button": true,
				"input_mode": "menu_navigation"
			}
		GameMode.WORLD_MAP:
			ui_context_data = {
				"show_discovered_zones": true,
				"allow_fast_travel": true,
				"input_mode": "map_navigation"
			}

# Modal Dialog Management
func open_modal(modal_id: String, modal_component: Node, block_input: bool = true) -> bool:
	"""Open a modal dialog with input blocking"""
	if modal_id in modal_components:
		DebugManager.log_warning("UIStateManager: Modal '" + modal_id + "' already open")
		return false
	
	# Add to modal stack and tracking
	modal_stack.append(modal_id)
	modal_components[modal_id] = modal_component
	
	# Configure modal component
	if modal_component is Control:
		modal_component.set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
		if block_input:
			modal_component.mouse_filter = Control.MOUSE_FILTER_STOP
			modal_component.grab_focus()
	
	# Update state if first modal
	if modal_stack.size() == 1:
		if current_ui_state == UIState.GAMEPLAY:
			set_ui_state(UIState.DIALOG)
		if block_input:
			input_blocked = true
	
	modal_opened.emit(modal_id)
	DebugManager.log_info("UIStateManager: Modal opened - " + modal_id)
	return true

func close_modal_dialog(modal_id: String, result: Dictionary = {}) -> bool:
	"""Close specific modal dialog"""
	if not modal_id in modal_components:
		DebugManager.log_warning("UIStateManager: Modal '" + modal_id + "' not found to close")
		return false
	
	# Remove from tracking
	var modal_component = modal_components[modal_id]
	modal_components.erase(modal_id)
	modal_stack.erase(modal_id)
	
	# Restore input if no modals remain
	if modal_stack.size() == 0:
		input_blocked = false
		if current_ui_state == UIState.DIALOG:
			set_ui_state(previous_ui_state)
	
	# Clean up component
	if modal_component and is_instance_valid(modal_component):
		if modal_component is Control:
			modal_component.mouse_filter = Control.MOUSE_FILTER_IGNORE
			modal_component.release_focus()
	
	modal_closed.emit(modal_id, result)
	DebugManager.log_info("UIStateManager: Modal closed - " + modal_id)
	return true

func close_top_modal(result: Dictionary = {}) -> bool:
	"""Close the topmost modal dialog"""
	if modal_stack.size() == 0:
		return false
	
	var top_modal = modal_stack[-1]
	return close_modal_dialog(top_modal, result)

func clear_all_modals():
	"""Close all open modals (for emergency cleanup)"""
	var modals_to_close = modal_stack.duplicate()
	for modal_id in modals_to_close:
		close_modal_dialog(modal_id, {"force_closed": true})
	
	DebugManager.log_info("UIStateManager: All modals cleared")

# Focus and Input Management
func register_ui_component(component: Node, can_focus: bool = false):
	"""Register UI component for focus management"""
	if not component in active_ui_components:
		active_ui_components.append(component)
		
		if can_focus and component is Control:
			component.focus_entered.connect(_on_component_focus_entered.bind(component))
			component.focus_exited.connect(_on_component_focus_exited.bind(component))
		
		DebugManager.log_debug("UIStateManager: Registered UI component " + component.name)

func unregister_ui_component(component: Node):
	"""Unregister UI component"""
	if component in active_ui_components:
		active_ui_components.erase(component)
		
		if focus_locked_component == component:
			focus_locked_component = null
		
		DebugManager.log_debug("UIStateManager: Unregistered UI component " + component.name)

func focus_next_component():
	"""Focus next component in tab order"""
	if focus_locked_component:
		return
	
	# Find current focused component and move to next
	var current_focused = get_viewport().gui_get_focus_owner()
	if current_focused:
		current_focused.find_next_valid_focus().grab_focus()

func focus_previous_component():
	"""Focus previous component in tab order"""
	if focus_locked_component:
		return
	
	var current_focused = get_viewport().gui_get_focus_owner()
	if current_focused:
		current_focused.find_prev_valid_focus().grab_focus()

func _on_component_focus_entered(component: Node):
	"""Handle component gaining focus"""
	input_focus_changed.emit(true, component)

func _on_component_focus_exited(component: Node):
	"""Handle component losing focus"""
	input_focus_changed.emit(false, component)

# Public API
func get_current_ui_state() -> UIState:
	"""Get current UI state"""
	return current_ui_state

func get_current_game_mode() -> GameMode:
	"""Get current game mode"""
	return current_game_mode

func get_ui_context_data() -> Dictionary:
	"""Get current UI context data"""
	return ui_context_data.duplicate()

func is_input_blocked() -> bool:
	"""Check if input is currently blocked"""
	return input_blocked or modal_stack.size() > 0

func is_modal_open(modal_id: String = "") -> bool:
	"""Check if specific modal or any modal is open"""
	if modal_id == "":
		return modal_stack.size() > 0
	return modal_id in modal_components

func get_open_modals() -> Array[String]:
	"""Get list of currently open modal IDs"""
	return modal_stack.duplicate()

# Debug and validation
func validate_ui_state():
	"""Validate UI state system integrity"""
	DebugManager.log_info("=== UI STATE VALIDATION ===")
	
	DebugManager.log_info("Current UI state: " + UIState.keys()[current_ui_state])
	DebugManager.log_info("Current game mode: " + GameMode.keys()[current_game_mode])
	DebugManager.log_info("Input blocked: " + str(input_blocked))
	DebugManager.log_info("Open modals: " + str(modal_stack.size()))
	DebugManager.log_info("Registered components: " + str(active_ui_components.size()))
	
	# Validate modal consistency
	if modal_stack.size() != modal_components.size():
		DebugManager.log_warning("Modal stack and component tracking out of sync")
	
	# Validate component references
	var valid_components = 0
	for component in active_ui_components:
		if is_instance_valid(component):
			valid_components += 1
	
	if valid_components != active_ui_components.size():
		DebugManager.log_warning("Some registered components are invalid")
	
	DebugManager.log_info("=== UI STATE VALIDATION COMPLETE ===")

# Development helpers
func force_ui_state(state: UIState):
	"""Debug function to force UI state"""
	set_ui_state(state)
	DebugManager.log_info("UIStateManager: Forced UI state to " + UIState.keys()[state])

func force_game_mode(mode: GameMode):
	"""Debug function to force game mode"""
	set_game_mode(mode)
	DebugManager.log_info("UIStateManager: Forced game mode to " + GameMode.keys()[mode])

# === MODAL MANAGEMENT ===
func show_inventory_modal():
	if "inventory" not in current_modals:
		current_modals.append("inventory")
		show_modal.emit("inventory", {})

func show_pause_modal():
	if "pause" not in current_modals:
		current_modals.append("pause")
		show_modal.emit("pause", {})

func show_settings_modal():
	if "settings" not in current_modals:
		current_modals.append("settings")
		show_modal.emit("settings", {})

func close_modal_by_name(modal_name: String):
	if modal_name in current_modals:
		current_modals.erase(modal_name)
		close_modal.emit(modal_name)

func close_all_open_modals():
	current_modals.clear()
	close_all_modals.emit()

# === HUD MANAGEMENT ===
func set_exploration_mode():
	current_hud_mode = "exploration"
	show_exploration_hud.emit()
	set_hud_visibility.emit(true)

func set_driving_mode():
	current_hud_mode = "driving"
	show_driving_hud.emit()
	set_hud_visibility.emit(true)

func set_menu_mode():
	current_hud_mode = "menu"
	set_hud_visibility.emit(false)

func toggle_hud():
	hud_visible = !hud_visible
	set_hud_visibility.emit(hud_visible)

# === DIALOG SYSTEM ===
func show_character_dialog(speaker: String, text: String, choices: Array = []):
	dialog_active = true
	show_dialog.emit(speaker, text, choices)

func close_character_dialog():
	dialog_active = false
	close_dialog.emit()

# === SCENE TRANSITION HELPERS ===
func prepare_for_scene_transition():
	"""Call this before scene transitions to clean up UI state"""
	close_all_open_modals()
	close_character_dialog()

func setup_ui_for_scene(scene_type: String):
	"""Configure UI state for specific scene types"""
	match scene_type:
		"lobby":
			set_menu_mode()
		"exploration":
			set_exploration_mode()
		"driving":
			set_driving_mode()
		"indoor":
			set_exploration_mode()

# === DEBUG HELPERS ===
func get_ui_state_debug_info() -> Dictionary:
	return {
		"current_modals": current_modals,
		"hud_visible": hud_visible,
		"current_hud_mode": current_hud_mode,
		"dialog_active": dialog_active
	}

# Debug input removed to fix input action error
# func _input(event):
# 	# Debug key to show UI state (F6) - action "ui_debug" doesn't exist
# 	if event.is_action_pressed("ui_debug") and DebugManager:
# 		var state = get_ui_state_debug_info()
# 		DebugManager.log_info("UI State: " + str(state)) 
