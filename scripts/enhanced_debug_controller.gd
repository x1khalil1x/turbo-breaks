extends Node

## Enhanced Debug Controller - How to Use Debug Systems Effectively
## Attach this to any scene to get comprehensive debug capabilities
## Demonstrates patterns you should use throughout your project

@export var enable_scene_transition_tests: bool = true
@export var enable_ui_pool_monitoring: bool = true
@export var enable_autoload_validation: bool = true

# Your core scenes for testing
var core_test_scenes: Array[String] = [
	"res://scenes/levels/outdoor/Center.tscn",
	"res://scenes/levels/outdoor/West.tscn",
	"res://scenes/levels/outdoor/NorthWest.tscn", 
	"res://scenes/levels/indoor/MainBuilding.tscn"
]

func _ready():
	print("🔧 Enhanced Debug Controller: Active")
	print("=== AVAILABLE DEBUG COMMANDS ===")
	print("BUILT-IN (DebugManager):")
	print("  F3 = Toggle Debug Panel")
	print("  F4 = Validate Current Scene")
	print("  F5 = Reset Debug State")
	print("  F6 = Validate All Systems")
	print("  F7 = Cycle UI Themes")
	print("  F8 = Test IndustrialSceneManager")
	print("  F9 = Show UI Pool Status")
	print("  F10 = Test Transition Safety")
	print("")
	print("ENHANCED (This Controller):")
	print("  1-4 = Test core scenes (Center, West, NorthWest, MainBuilding)")
	print("  Q = Quick scene validation")
	print("  W = Show all autoload status")
	print("  E = Test UI pooling efficiency")
	print("  R = Performance benchmark")
	print("  T = Toggle all debug features")
	print("================================")
	
	# Connect to DebugManager if available
	if DebugManager:
		DebugManager.debug_mode_toggled.connect(_on_debug_mode_toggled)
		print("✅ Connected to DebugManager")
	
	# Connect to IndustrialSceneManager if available
	if IndustrialSceneManager:
		IndustrialSceneManager.scene_transition_started.connect(_on_scene_transition_started)
		IndustrialSceneManager.scene_transition_completed.connect(_on_scene_transition_completed)
		IndustrialSceneManager.scene_ui_ready.connect(_on_scene_ui_ready)
		print("✅ Connected to IndustrialSceneManager")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			# Core scene testing (1-4)
			KEY_1:
				if enable_scene_transition_tests:
					test_core_scene(0, "Center")
			KEY_2:
				if enable_scene_transition_tests:
					test_core_scene(1, "West")
			KEY_3:
				if enable_scene_transition_tests:
					test_core_scene(2, "NorthWest")
			KEY_4:
				if enable_scene_transition_tests:
					test_core_scene(3, "MainBuilding")
			
			# Enhanced debug functions
			KEY_Q:
				quick_scene_validation()
			KEY_W:
				show_autoload_status()
			KEY_E:
				test_ui_pooling_efficiency()
			KEY_R:
				run_performance_benchmark()
			KEY_T:
				toggle_all_debug_features()

# CORE SCENE TESTING
func test_core_scene(index: int, scene_name: String):
	"""Test transition to one of your core scenes"""
	if index >= core_test_scenes.size():
		print("❌ Invalid scene index: ", index)
		return
	
	var target_scene = core_test_scenes[index]
	var scene_type = "indoor" if "indoor" in target_scene else "outdoor"
	
	print("🎬 Testing transition to ", scene_name, " (", scene_type, ")")
	
	if IndustrialSceneManager:
		var success = await IndustrialSceneManager.transition_scene_safe(
			target_scene,
			Vector2(540, 360),
			scene_type
		)
		print("🎬 Transition result: ", "SUCCESS" if success else "FAILED")
	else:
		print("❌ IndustrialSceneManager not available - using fallback")
		if SceneManager:
			SceneManager.change_scene_with_position(target_scene, Vector2(540, 360))
		else:
			print("❌ No scene manager available!")

# VALIDATION FUNCTIONS
func quick_scene_validation():
	"""Quick validation of current scene state"""
	print("🔍 === QUICK SCENE VALIDATION ===")
	
	var current_scene = get_tree().current_scene
	if not current_scene:
		print("❌ No current scene!")
		return
	
	print("📍 Scene: ", current_scene.name)
	
	# Check critical components
	var players = get_tree().get_nodes_in_group("player")
	var doorways = get_tree().get_nodes_in_group("doorways")
	var ui_components = get_all_ui_components()
	
	print("🎮 Players: ", players.size(), " (should be 1)")
	print("🚪 Doorways: ", doorways.size())
	print("🖥️ UI Components: ", ui_components.size())
	
	# Validate doorways
	for doorway in doorways:
		var validation = validate_doorway_quick(doorway)
		if not validation.valid:
			print("⚠️ Doorway '", doorway.doorway_id, "' issues: ", validation.issues)
	
	print("🔍 === VALIDATION COMPLETE ===")

func show_autoload_status():
	"""Show status of all autoloads"""
	print("🔧 === AUTOLOAD STATUS ===")
	
	var autoloads = [
		"DebugManager", "SceneManager", "IndustrialSceneManager",
		"MusicPlayer", "FontManager", "MapManager", 
		"UIThemeManager", "UIStateManager", "NotificationManager",
		"DrivingConfigManager", "WorldMapManager"
	]
	
	for autoload_name in autoloads:
		var autoload = get_node_or_null("/root/" + autoload_name)
		var status = "✅ Available" if autoload else "❌ Missing"
		print("  ", autoload_name, ": ", status)
		
		# Additional health checks for key autoloads
		if autoload and autoload_name == "UIThemeManager":
			var theme_status = "Unknown"
			if autoload.has_method("get_current_theme"):
				var current_theme = autoload.get_current_theme()
				theme_status = "Theme loaded" if current_theme else "No theme"
			print("    └─ Theme status: ", theme_status)
		
		if autoload and autoload_name == "IndustrialSceneManager":
			var pool_status = autoload.get_ui_pool_status()
			var total_pooled = 0
			for scene_type in pool_status:
				total_pooled += pool_status[scene_type]
			print("    └─ UI Pool: ", total_pooled, " instances across ", pool_status.size(), " types")
	
	print("🔧 === STATUS COMPLETE ===")

# PERFORMANCE TESTING
func test_ui_pooling_efficiency():
	"""Test UI pooling vs traditional creation"""
	print("⚡ === UI POOLING EFFICIENCY TEST ===")
	
	if not IndustrialSceneManager:
		print("❌ IndustrialSceneManager not available")
		return
	
	var start_time = Time.get_ticks_msec()
	
	# Test pooled UI acquisition
	for i in range(5):
		var ui_instance = IndustrialSceneManager.acquire_ui_for_scene("outdoor")
		if ui_instance:
			IndustrialSceneManager.return_ui_to_pool(ui_instance, "outdoor")
	
	var pooled_time = Time.get_ticks_msec() - start_time
	
	# Test traditional UI creation
	start_time = Time.get_ticks_msec()
	var ui_scene = load("res://scenes/UI/GameUI.tscn")
	
	for i in range(5):
		if ui_scene:
			var ui_instance = ui_scene.instantiate()
			ui_instance.queue_free()
	
	var traditional_time = Time.get_ticks_msec() - start_time
	
	print("📊 Pooled UI: ", pooled_time, "ms")
	print("📊 Traditional UI: ", traditional_time, "ms")
	print("📊 Efficiency gain: ", float(traditional_time) / float(pooled_time), "x faster")
	print("⚡ === EFFICIENCY TEST COMPLETE ===")

func run_performance_benchmark():
	"""Run comprehensive performance benchmark"""
	print("🚀 === PERFORMANCE BENCHMARK ===")
	
	var start_memory = OS.get_static_memory_usage()
	var start_time = Time.get_ticks_msec()
	
	# Scene transition benchmark
	print("Testing scene transition performance...")
	for i in range(3):
		if IndustrialSceneManager:
			await IndustrialSceneManager.transition_scene_safe(
				core_test_scenes[i % core_test_scenes.size()],
				Vector2(540, 360),
				"outdoor"
			)
			await get_tree().process_frame
	
	var total_time = Time.get_ticks_msec() - start_time
	var end_memory = OS.get_static_memory_usage()
	
	print("📊 Total benchmark time: ", total_time, "ms")
	print("📊 Average per transition: ", total_time / 3, "ms")
	print("📊 Memory delta: ", end_memory - start_memory, " bytes")
	print("🚀 === BENCHMARK COMPLETE ===")

# UTILITY FUNCTIONS
func validate_doorway_quick(doorway) -> Dictionary:
	"""Quick doorway validation"""
	var result = {"valid": true, "issues": []}
	
	if not doorway.has_method("get") or not "target_scene" in doorway:
		result.valid = false
		result.issues.append("Missing target_scene property")
		return result
	
	if doorway.target_scene == "":
		result.valid = false
		result.issues.append("No target scene set")
	
	if not FileAccess.file_exists(doorway.target_scene):
		result.valid = false
		result.issues.append("Target scene file doesn't exist")
	
	return result

func get_all_ui_components() -> Array:
	"""Get all UI components in the current scene"""
	var components = []
	find_ui_components_recursive(get_tree().current_scene, components)
	return components

func find_ui_components_recursive(node: Node, components: Array):
	"""Recursively find UI components"""
	if node is Control:
		components.append(node)
	
	for child in node.get_children():
		find_ui_components_recursive(child, components)

func toggle_all_debug_features():
	"""Toggle all debug features on/off"""
	enable_scene_transition_tests = !enable_scene_transition_tests
	enable_ui_pool_monitoring = !enable_ui_pool_monitoring
	enable_autoload_validation = !enable_autoload_validation
	
	print("🔄 Debug features toggled:")
	print("  Scene transition tests: ", "ON" if enable_scene_transition_tests else "OFF")
	print("  UI pool monitoring: ", "ON" if enable_ui_pool_monitoring else "OFF")
	print("  Autoload validation: ", "ON" if enable_autoload_validation else "OFF")

# EVENT HANDLERS
func _on_debug_mode_toggled(enabled: bool):
	"""Handle debug mode toggle from DebugManager"""
	print("🔧 Debug mode: ", "ENABLED" if enabled else "DISABLED")

func _on_scene_transition_started(from_scene: String, to_scene: String):
	"""Handle scene transition start"""
	if enable_scene_transition_tests:
		print("🎬 Scene transition: ", from_scene, " → ", to_scene)

func _on_scene_transition_completed(scene_name: String):
	"""Handle scene transition completion"""
	if enable_scene_transition_tests:
		print("✅ Scene transition completed: ", scene_name)

func _on_scene_ui_ready(scene_name: String):
	"""Handle UI ready event"""
	if enable_ui_pool_monitoring:
		print("🖥️ UI ready for scene: ", scene_name) 