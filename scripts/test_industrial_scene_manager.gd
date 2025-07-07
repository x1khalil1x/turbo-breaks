extends Node

## Test Script for IndustrialSceneManager
## Demonstrates safe scene switching with proper UI management
## Attach this to any scene to test the new system

@export var test_target_scenes: Array[String] = [
	"res://scenes/levels/outdoor/Center.tscn",
	"res://scenes/levels/outdoor/West.tscn",
	"res://scenes/levels/outdoor/NorthWest.tscn",
	"res://scenes/levels/indoor/MainBuilding.tscn"
]

@export var current_scene_index: int = 0

func _ready():
	print("IndustrialSceneManager Test: Ready")
	print("Available test scenes:")
	for i in range(test_target_scenes.size()):
		print("  ", i, ": ", test_target_scenes[i].get_file().get_basename())
	
	print("Press F1-F4 to test scene transitions")
	print("Press F5 to check UI pool status")
	print("Press F6 to test transition safety")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				test_scene_transition(0)
			KEY_F2:
				test_scene_transition(1)
			KEY_F3:
				test_scene_transition(2)
			KEY_F4:
				test_scene_transition(3)
			KEY_F5:
				check_ui_pool_status()
			KEY_F6:
				test_rapid_transitions()
			KEY_F7:
				test_invalid_scene()

func test_scene_transition(scene_index: int):
	"""Test transition to a specific scene"""
	if scene_index >= test_target_scenes.size():
		print("IndustrialSceneManager Test: Invalid scene index ", scene_index)
		return
	
	var target_scene = test_target_scenes[scene_index]
	var scene_type = determine_scene_type_from_path(target_scene)
	
	print("IndustrialSceneManager Test: Transitioning to ", target_scene.get_file().get_basename(), " (type: ", scene_type, ")")
	
	# Use the new safe transition system
	var success = await IndustrialSceneManager.transition_scene_safe(
		target_scene,
		Vector2(540, 360),  # Center spawn
		scene_type
	)
	
	if success:
		print("IndustrialSceneManager Test: Transition successful!")
	else:
		print("IndustrialSceneManager Test: Transition failed or blocked")

func determine_scene_type_from_path(scene_path: String) -> String:
	"""Determine scene type from path"""
	var filename = scene_path.get_file().get_basename().to_lower()
	
	if "indoor" in scene_path or "building" in filename:
		return "indoor"
	elif "outdoor" in scene_path:
		return "outdoor"
	elif "drive" in scene_path:
		return "drive"
	else:
		return "outdoor"  # Default

func check_ui_pool_status():
	"""Check and display UI pool status"""
	print("=== UI POOL STATUS ===")
	var status = IndustrialSceneManager.get_ui_pool_status()
	
	for scene_type in status:
		print(scene_type, " pool: ", status[scene_type], " instances available")
	
	print("======================")

func test_rapid_transitions():
	"""Test rapid scene transitions to ensure cooldown works"""
	print("IndustrialSceneManager Test: Testing rapid transitions (should be blocked by cooldown)")
	
	# First transition
	var success1 = await IndustrialSceneManager.transition_scene_safe(
		test_target_scenes[0],
		Vector2(540, 360),
		"outdoor"
	)
	print("First transition: ", "SUCCESS" if success1 else "FAILED")
	
	# Immediate second transition (should be blocked)
	var success2 = await IndustrialSceneManager.transition_scene_safe(
		test_target_scenes[1],
		Vector2(540, 360),
		"outdoor"
	)
	print("Immediate second transition: ", "SUCCESS (unexpected)" if success2 else "BLOCKED (expected)")

func test_invalid_scene():
	"""Test handling of invalid scene paths"""
	print("IndustrialSceneManager Test: Testing invalid scene handling")
	
	var success = await IndustrialSceneManager.transition_scene_safe(
		"res://scenes/nonexistent/FakeScene.tscn",
		Vector2(540, 360),
		"outdoor"
	)
	
	print("Invalid scene transition: ", "SUCCESS (unexpected)" if success else "FAILED (expected)")

# Connect to IndustrialSceneManager signals for monitoring
func _on_scene_transition_started(from_scene: String, to_scene: String):
	print("IndustrialSceneManager Test: Transition started: ", from_scene, " -> ", to_scene)

func _on_scene_transition_completed(scene_name: String):
	print("IndustrialSceneManager Test: Transition completed: ", scene_name)

func _on_scene_ui_ready(scene_name: String):
	print("IndustrialSceneManager Test: UI ready for scene: ", scene_name)

func connect_signals():
	"""Connect to IndustrialSceneManager signals for monitoring"""
	if IndustrialSceneManager:
		IndustrialSceneManager.scene_transition_started.connect(_on_scene_transition_started)
		IndustrialSceneManager.scene_transition_completed.connect(_on_scene_transition_completed)
		IndustrialSceneManager.scene_ui_ready.connect(_on_scene_ui_ready)
		print("IndustrialSceneManager Test: Connected to signals")
	else:
		print("IndustrialSceneManager Test: IndustrialSceneManager not available") 