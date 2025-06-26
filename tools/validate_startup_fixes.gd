@tool
extends EditorScript

## Startup Fixes Validation Script
## Run this in Godot Editor via Tools -> Execute Script
## Validates that all critical startup fixes are properly applied

func _run():
	print("🔍 TURBO BREAKS - Startup Fixes Validation")
	print("=" * 50)
	
	var validation_passed = true
	
	# 1. Check variable scope fix in game_ui.gd
	print("\n1. Checking variable scope fix in game_ui.gd...")
	validation_passed &= check_game_ui_variable_scope()
	
	# 2. Check UIThemeConfig.create_theme_resource() exists
	print("\n2. Checking UIThemeConfig.create_theme_resource()...")
	validation_passed &= check_theme_resource_creation()
	
	# 3. Check autoload order in project.godot
	print("\n3. Checking autoload dependency order...")
	validation_passed &= check_autoload_order()
	
	# 4. Check null safety in autoloads
	print("\n4. Checking autoload null safety...")
	validation_passed &= check_autoload_null_safety()
	
	# 5. Check signal handlers exist
	print("\n5. Checking signal handlers...")
	validation_passed &= check_signal_handlers()
	
	print("\n" + "=" * 50)
	if validation_passed:
		print("✅ ALL VALIDATIONS PASSED - Startup fixes properly applied!")
		print("🎮 Game should now start without critical errors.")
	else:
		print("❌ SOME VALIDATIONS FAILED - Check output above for details.")
	print("=" * 50)

func check_game_ui_variable_scope() -> bool:
	var file_path = "res://scripts/ui/game_ui.gd"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ Cannot open " + file_path)
		return false
	
	var content = file.get_as_text()
	file.close()
	
	# Check that we use _theme_config instead of theme_config
	if "_theme_config.reduced_motion" in content and "_theme_config.large_text_mode" in content:
		print("✅ Variable scope fixed - using _theme_config parameter correctly")
		return true
	else:
		print("❌ Variable scope not fixed - still using incorrect variable names")
		return false

func check_theme_resource_creation() -> bool:
	var file_path = "res://scripts/ui/ui_theme_config.gd"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ Cannot open " + file_path)
		return false
	
	var content = file.get_as_text()
	file.close()
	
	# Check that create_theme_resource method exists
	if "func create_theme_resource() -> Theme:" in content:
		print("✅ UIThemeConfig.create_theme_resource() method found")
		return true
	else:
		print("❌ UIThemeConfig.create_theme_resource() method missing")
		return false

func check_autoload_order() -> bool:
	var config = ConfigFile.new()
	var err = config.load("res://project.godot")
	if err != OK:
		print("❌ Cannot load project.godot")
		return false
	
	var autoloads = []
	for key in config.get_section_keys("autoload"):
		autoloads.append(key)
	
	# Check that DebugManager comes first
	if autoloads.size() > 0 and autoloads[0] == "DebugManager":
		print("✅ DebugManager loads first - dependency order fixed")
		return true
	else:
		print("❌ DebugManager not loading first - dependency order issue")
		print("  Current order: " + str(autoloads))
		return false

func check_autoload_null_safety() -> bool:
	var autoload_files = [
		"res://Autoload/UIThemeManager.gd",
		"res://Autoload/UIStateManager.gd", 
		"res://Autoload/NotificationManager.gd",
		"res://Autoload/DrivingConfigManager.gd",
		"res://Autoload/WorldMapManager.gd"
	]
	
	var all_safe = true
	
	for file_path in autoload_files:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if not file:
			print("❌ Cannot open " + file_path)
			all_safe = false
			continue
		
		var content = file.get_as_text()
		file.close()
		
		# Check for await and null checks
		if "await get_tree().process_frame" in content and "if DebugManager:" in content:
			print("✅ " + file_path.get_file() + " has null safety")
		else:
			print("❌ " + file_path.get_file() + " missing null safety")
			all_safe = false
	
	return all_safe

func check_signal_handlers() -> bool:
	var file_path = "res://scripts/ui/game_ui.gd"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ Cannot open " + file_path)
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var required_handlers = [
		"func _on_modal_opened(",
		"func _on_modal_closed(",
		"func _on_notification_created(",
		"func _on_notification_dismissed("
	]
	
	var all_found = true
	for handler in required_handlers:
		if handler in content:
			print("✅ Signal handler found: " + handler.replace("func ", "").replace("(", ""))
		else:
			print("❌ Signal handler missing: " + handler.replace("func ", "").replace("(", ""))
			all_found = false
	
	return all_found 