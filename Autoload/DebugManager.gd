extends Node

## Debug Manager - MINIMAL SAFE VERSION
## Only basic logging and simple debug keys

var debug_enabled: bool = true

# Debug logging categories
enum LogLevel { INFO, WARNING, ERROR, DEBUG }

func _ready():
	print("DebugManager: Minimal safe version initialized")
	setup_debug_keys()

func _unhandled_input(event):
	if not debug_enabled:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F3:
				toggle_debug_info()
			KEY_F4:
				validate_current_scene_safe()
			KEY_F5:
				reset_debug_state()
			KEY_F6:
				validate_systems_safe()
			KEY_F7:
				cycle_themes_safe()
			KEY_F8:
				test_theme_loading()

func setup_debug_keys():
	debug_log("=== SAFE DEBUG KEYS ===", LogLevel.INFO)
	debug_log("F3 = Debug Info", LogLevel.INFO)
	debug_log("F4 = Scene Info", LogLevel.INFO)
	debug_log("F5 = Reset", LogLevel.INFO)
	debug_log("F6 = System Check", LogLevel.INFO)
	debug_log("F7 = Theme Test", LogLevel.INFO)
	debug_log("F8 = Theme Reload Test", LogLevel.INFO)
	debug_log("=====================", LogLevel.INFO)

func toggle_debug_info():
	debug_log("=== DEBUG INFO ===", LogLevel.INFO)
	debug_log("Scene: " + get_tree().current_scene.name, LogLevel.INFO)
	debug_log("FPS: " + str(Engine.get_frames_per_second()), LogLevel.INFO)
	debug_log("Debug enabled: " + str(debug_enabled), LogLevel.INFO)
	debug_log("==================", LogLevel.INFO)

func validate_current_scene_safe():
	debug_log("=== SCENE INFO ===", LogLevel.INFO)
	
	var current_scene = get_tree().current_scene
	if current_scene:
		debug_log("Scene: " + current_scene.name, LogLevel.INFO)
		debug_log("Scene path: " + current_scene.scene_file_path, LogLevel.INFO)
	else:
		debug_log("No current scene!", LogLevel.ERROR)
	
	debug_log("==================", LogLevel.INFO)

func validate_systems_safe():
	debug_log("=== SYSTEM CHECK ===", LogLevel.INFO)
	
	# Only check if autoloads exist - NO method calls
	debug_log("SceneManager: " + ("✓" if SceneManager else "✗"), LogLevel.INFO)
	debug_log("UIThemeManager: " + ("✓" if UIThemeManager else "✗"), LogLevel.INFO)
	debug_log("UIStateManager: " + ("✓" if UIStateManager else "✗"), LogLevel.INFO)
	debug_log("NotificationManager: " + ("✓" if NotificationManager else "✗"), LogLevel.INFO)
	debug_log("FontManager: " + ("✓" if FontManager else "✗"), LogLevel.INFO)
	debug_log("MusicPlayer: " + ("✓" if MusicPlayer else "✗"), LogLevel.INFO)
	
	debug_log("====================", LogLevel.INFO)

func cycle_themes_safe():
	if UIThemeManager:
		debug_log("Theme system available - attempting safe theme test", LogLevel.INFO)
		
		# Try to get current theme name safely
		if UIThemeManager.has_method("get_current_theme_name"):
			var current_theme = UIThemeManager.get_current_theme_name()
			debug_log("Current theme: " + current_theme, LogLevel.INFO)
		else:
			debug_log("Theme name method not available", LogLevel.WARNING)
		
		# Actually cycle the themes
		if UIThemeManager.has_method("cycle_themes_for_testing"):
			UIThemeManager.cycle_themes_for_testing()
		else:
			debug_log("Theme cycling method not available", LogLevel.WARNING)
			
	else:
		debug_log("UIThemeManager not available", LogLevel.ERROR)

func test_theme_loading():
	"""Test if UIThemeConfig class is properly loaded"""
	if UIThemeManager:
		debug_log("=== TESTING THEME LOADING ===", LogLevel.INFO)
		
		if UIThemeManager.has_method("debug_class_registration"):
			UIThemeManager.debug_class_registration()
		
		if UIThemeManager.has_method("test_code_based_themes"):
			UIThemeManager.test_code_based_themes()
			
		debug_log("=== THEME LOADING TEST COMPLETE ===", LogLevel.INFO)
	else:
		debug_log("UIThemeManager not available for testing", LogLevel.ERROR)

func reset_debug_state():
	debug_log("Debug state reset", LogLevel.INFO)

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
