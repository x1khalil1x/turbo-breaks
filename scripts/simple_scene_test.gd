extends Node2D

## Simple Scene Test Script
## Attach this to any scene to make it testable standalone
## Automatically handles missing dependencies and creates test setup

@export var scene_type: String = "test"
@export var auto_create_player: bool = true
@export var enable_debug_logging: bool = true

func _ready():
	print("SimpleSceneTest: Starting standalone scene test for ", name)
	await setup_test_environment()

func setup_test_environment():
	"""Set up environment for standalone testing"""
	await get_tree().process_frame
	
	# Use SceneInitializationHelper for robust setup
	if SceneInitializationHelper:
		await SceneInitializationHelper.ensure_scene_ready_for_testing(self)
		SceneInitializationHelper.setup_scene_type_defaults(self, scene_type)
		
		if auto_create_player:
			SceneInitializationHelper.create_test_player_if_missing(self)
		
		await SceneInitializationHelper.ensure_ui_theme_applied(self)
		
		print("SimpleSceneTest: Scene ", name, " ready for testing!")
	else:
		print("SimpleSceneTest: SceneInitializationHelper not available - basic setup only")
		await basic_setup()

func basic_setup():
	"""Basic setup without SceneInitializationHelper"""
	# Ensure SceneManager knows about us
	if SceneManager:
		SceneManager.current_scene = self
	
	# Create basic test player if needed
	if auto_create_player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() == 0:
			print("SimpleSceneTest: No player found - you may need to add one manually")
	
	print("SimpleSceneTest: Basic setup complete")

func _input(event):
	"""Handle test-specific input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				print_scene_info()
			KEY_F2:
				validate_scene()
			KEY_ESCAPE:
				print("SimpleSceneTest: ESC pressed - returning to lobby")
				if SceneManager:
					SceneManager.change_scene_to_lobby()

func print_scene_info():
	"""Print debugging information about the current scene"""
	print("=== SCENE INFO ===")
	print("Scene Name: ", name)
	print("Scene Type: ", scene_type)
	print("Players: ", get_tree().get_nodes_in_group("player").size())
	print("Doorways: ", get_tree().get_nodes_in_group("doorways").size())
	print("UI Controls: ", get_all_ui_controls().size())
	print("SceneManager Available: ", SceneManager != null)
	print("DebugManager Available: ", DebugManager != null)
	print("==================")

func validate_scene():
	"""Validate scene configuration"""
	print("=== SCENE VALIDATION ===")
	var issues = []
	
	# Check for player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		issues.append("No player in scene")
	elif players.size() > 1:
		issues.append("Multiple players in scene")
	
	# Check for camera
	var cameras = []
	find_cameras_recursive(self, cameras)
	if cameras.size() == 0:
		issues.append("No camera found")
	elif cameras.size() > 1:
		issues.append("Multiple cameras found")
	
	# Report results
	if issues.size() == 0:
		print("✅ Scene validation passed!")
	else:
		print("⚠️ Scene issues found:")
		for issue in issues:
			print("  - ", issue)
	print("========================")

func get_all_ui_controls() -> Array:
	"""Get all UI controls in the scene"""
	var controls = []
	find_controls_recursive(self, controls)
	return controls

func find_controls_recursive(node: Node, controls_array: Array):
	"""Recursively find Control nodes"""
	if node is Control:
		controls_array.append(node)
	
	for child in node.get_children():
		find_controls_recursive(child, controls_array)

func find_cameras_recursive(node: Node, cameras_array: Array):
	"""Recursively find Camera2D nodes"""
	if node is Camera2D:
		cameras_array.append(node)
	
	for child in node.get_children():
		find_cameras_recursive(child, cameras_array) 