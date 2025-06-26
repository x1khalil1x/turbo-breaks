extends Node

## Debug Manager - Phase 1 Implementation
## Provides console logging, validation, and debug key bindings

var debug_enabled: bool = true
var debug_panel_visible: bool = false

# Debug logging categories
enum LogLevel { INFO, WARNING, ERROR, DEBUG }

# Debug signals
signal debug_mode_toggled(enabled: bool)

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
			KEY_F6:
				validate_new_systems()
			KEY_F7:
				cycle_ui_themes()

func setup_debug_keys():
	debug_log("Debug keys enabled: F3=Toggle Debug, F4=Validate, F5=Reset, F6=Systems, F7=Themes", LogLevel.INFO)

func toggle_debug_panel():
	debug_panel_visible = !debug_panel_visible
	debug_log("Debug panel: " + ("ON" if debug_panel_visible else "OFF"), LogLevel.INFO)
	debug_mode_toggled.emit(debug_panel_visible)
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

# Enhanced scene transition debugging
func log_scene_transition(from_scene: String, to_scene: String, position: Vector2):
	debug_log("TRANSITION: %s → %s at %s" % [from_scene, to_scene, position], LogLevel.INFO)

func validate_doorway_positioning():
	"""Check for doorways too close to each other and validate spawn positions"""
	debug_log("=== DOORWAY POSITIONING VALIDATION ===", LogLevel.INFO)
	
	var doorways = get_tree().get_nodes_in_group("doorways")
	var issues = []
	
	for i in range(doorways.size()):
		var doorway_a = doorways[i]
		
		# Validate individual doorway
		var config_validation = validate_doorway(doorway_a)
		if not config_validation.valid:
			issues.append("Doorway '%s': %s" % [doorway_a.doorway_id, str(config_validation.issues)])
		
		# Check for overlapping doorways
		for j in range(i + 1, doorways.size()):
			var doorway_b = doorways[j]
			var distance = doorway_a.global_position.distance_to(doorway_b.global_position)
			
			if distance < 80:  # Too close threshold
				issues.append("Doorways '%s' and '%s' are too close: %s pixels apart" % [
					doorway_a.doorway_id, doorway_b.doorway_id, distance
				])
		
		# Validate spawn position is within reasonable bounds
		if doorway_a.target_position != Vector2.ZERO:
			var spawn_pos = doorway_a.target_position
			if spawn_pos.x < 50 or spawn_pos.y < 50 or spawn_pos.x > 1030 or spawn_pos.y > 670:
				issues.append("Doorway '%s' spawn position may be too close to edge: %s" % [
					doorway_a.doorway_id, spawn_pos
				])
	
	if issues.size() > 0:
		debug_log("Positioning issues found:", LogLevel.WARNING)
		for issue in issues:
			debug_log("  - " + issue, LogLevel.WARNING)
	else:
		debug_log("All doorway positions validated successfully", LogLevel.INFO)
	
	debug_log("=== DOORWAY VALIDATION COMPLETE ===", LogLevel.INFO)

# Visual debug helpers
func show_spawn_position_markers():
	"""Add visual markers at spawn positions for debugging"""
	debug_log("Adding spawn position markers", LogLevel.INFO)
	
	var doorways = get_tree().get_nodes_in_group("doorways")
	for doorway in doorways:
		if doorway.target_position != Vector2.ZERO:
			# Create a visual marker at the spawn position
			var marker = ColorRect.new()
			marker.size = Vector2(20, 20)
			marker.color = Color.RED
			marker.position = doorway.target_position - Vector2(10, 10)
			marker.name = "SpawnMarker_" + doorway.doorway_id
			
			# Add to current scene
			get_tree().current_scene.add_child(marker)
			debug_log("Spawn marker added for doorway '%s' at %s" % [doorway.doorway_id, doorway.target_position], LogLevel.INFO)

func hide_spawn_position_markers():
	"""Remove visual spawn position markers"""
	var markers = get_tree().get_nodes_in_group("spawn_markers")
	for marker in markers:
		marker.queue_free()
	debug_log("Spawn position markers removed", LogLevel.INFO)

# Phase 2B: New system validation functions
func validate_new_systems():
	"""Validate all Phase 1 and Phase 2 systems"""
	debug_log("=== NEW SYSTEMS VALIDATION ===", LogLevel.INFO)
	
	# Validate WorldMapManager
	if WorldMapManager:
		debug_log("WorldMapManager: Available", LogLevel.INFO)
		WorldMapManager.validate_zone_system()
	else:
		debug_log("WorldMapManager: Missing!", LogLevel.ERROR)
	
	# Validate UIThemeManager
	if UIThemeManager:
		debug_log("UIThemeManager: Available", LogLevel.INFO)
		UIThemeManager.validate_theme_system()
	else:
		debug_log("UIThemeManager: Missing!", LogLevel.ERROR)
	
	# Validate UIStateManager
	if UIStateManager:
		debug_log("UIStateManager: Available", LogLevel.INFO)
		UIStateManager.validate_ui_state()
	else:
		debug_log("UIStateManager: Missing!", LogLevel.ERROR)
	
	# Validate NotificationManager
	if NotificationManager:
		debug_log("NotificationManager: Available", LogLevel.INFO)
		NotificationManager.validate_notification_system()
	else:
		debug_log("NotificationManager: Missing!", LogLevel.ERROR)
	
	# Validate DrivingConfigManager
	if DrivingConfigManager:
		debug_log("DrivingConfigManager: Available", LogLevel.INFO)
		DrivingConfigManager.validate_driving_system()
	else:
		debug_log("DrivingConfigManager: Missing!", LogLevel.ERROR)
	
	debug_log("=== NEW SYSTEMS VALIDATION COMPLETE ===", LogLevel.INFO)

func cycle_ui_themes():
	"""Debug function to cycle through UI themes"""
	if UIThemeManager:
		debug_log("Cycling UI themes...", LogLevel.INFO)
		UIThemeManager.cycle_themes_for_testing()
	else:
		debug_log("UIThemeManager not available for theme cycling", LogLevel.ERROR) 
