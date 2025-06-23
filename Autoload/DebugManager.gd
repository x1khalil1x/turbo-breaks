extends Node

## Debug Manager - Phase 1 Implementation
## Provides console logging, validation, and debug key bindings

var debug_enabled: bool = true
var debug_panel_visible: bool = false

# Debug logging categories
enum LogLevel { INFO, WARNING, ERROR, DEBUG }

func _ready():
	print("DebugManager: Phase 1 initialized")
	setup_debug_keys()

func _unhandled_input(event):
	if not debug_enabled:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F3:
				toggle_debug_panel()
			KEY_F4:
				validate_current_scene()
			KEY_F5:
				reset_debug_state()

func setup_debug_keys():
	debug_log("Debug keys enabled: F3=Toggle Debug, F4=Validate, F5=Reset", LogLevel.INFO)

func toggle_debug_panel():
	debug_panel_visible = !debug_panel_visible
	debug_log("Debug panel: " + ("ON" if debug_panel_visible else "OFF"), LogLevel.INFO)
	# TODO: Show/hide debug UI overlay

func validate_current_scene():
	debug_log("=== SCENE VALIDATION ===", LogLevel.INFO)
	
	var current_scene = get_tree().current_scene
	if not current_scene:
		debug_log("No current scene found!", LogLevel.ERROR)
		return
	
	debug_log("Scene: " + current_scene.name, LogLevel.INFO)
	
	# Check for player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		debug_log("No player found in scene!", LogLevel.WARNING)
	else:
		debug_log("Player found at: " + str(players[0].global_position), LogLevel.INFO)
	
	# Check for doorways
	var doorways = get_tree().get_nodes_in_group("doorways")
	debug_log("Doorways found: " + str(doorways.size()), LogLevel.INFO)
	
	for doorway in doorways:
		if doorway.target_scene == "":
			debug_log("Doorway '" + doorway.doorway_id + "' has no target scene!", LogLevel.WARNING)
		else:
			debug_log("Doorway '" + doorway.doorway_id + "' -> " + doorway.target_scene, LogLevel.INFO)
	
	# Check SceneManager
	if SceneManager:
		debug_log("SceneManager: Available", LogLevel.INFO)
	else:
		debug_log("SceneManager: Missing!", LogLevel.ERROR)
	
	debug_log("=== VALIDATION COMPLETE ===", LogLevel.INFO)

func reset_debug_state():
	debug_log("Debug state reset", LogLevel.INFO)
	debug_panel_visible = false

func debug_log(message: String, level: LogLevel = LogLevel.DEBUG):
	if not debug_enabled:
		return
	
	var prefix = get_log_prefix(level)
	var timestamp = Time.get_datetime_string_from_system()
	var full_message = "[%s] %s %s" % [timestamp, prefix, message]
	
	print(full_message)

func get_log_prefix(level: LogLevel) -> String:
	match level:
		LogLevel.INFO:
			return "[INFO]"
		LogLevel.WARNING:
			return "[WARN]"
		LogLevel.ERROR:
			return "[ERROR]"
		LogLevel.DEBUG:
			return "[DEBUG]"
		_:
			return "[LOG]"

# Public API for other scripts
func log_info(message: String):
	debug_log(message, LogLevel.INFO)

func log_warning(message: String):
	debug_log(message, LogLevel.WARNING)

func log_error(message: String):
	debug_log(message, LogLevel.ERROR)

func log_debug(message: String):
	debug_log(message, LogLevel.DEBUG)

# Doorway-specific debugging
func log_doorway_event(doorway_id: String, event: String):
	debug_log("Doorway '%s': %s" % [doorway_id, event], LogLevel.INFO)

func validate_doorway(doorway) -> Dictionary:
	var result = {"valid": true, "issues": []}
	
	if doorway.target_scene == "":
		result.valid = false
		result.issues.append("No target scene set")
	
	if doorway.doorway_id == "":
		result.valid = false
		result.issues.append("No doorway ID set")
	
	if not FileAccess.file_exists(doorway.target_scene):
		result.valid = false
		result.issues.append("Target scene file doesn't exist: " + doorway.target_scene)
	
	return result 