extends RefCounted
class_name SceneInitializationHelper

## SceneInitializationHelper - Ensures scenes work standalone or through SceneManager
## Handles autoload dependencies and provides fallbacks for individual scene testing

static func ensure_scene_ready_for_testing(scene_node: Node):
	"""Call this from _ready() in any scene that needs to work standalone"""
	print("SceneInitializationHelper: Initializing scene for standalone testing: ", scene_node.name)
	
	# Wait for autoloads to be ready
	await scene_node.get_tree().process_frame
	
	# Validate critical autoloads
	validate_autoloads(scene_node)
	
	# Update SceneManager's current_scene if needed
	sync_with_scene_manager(scene_node)
	
	# Register with MapManager if applicable
	register_with_map_manager(scene_node)
	
	print("SceneInitializationHelper: Scene ", scene_node.name, " ready for testing")

static func validate_autoloads(_scene_node: Node):
	"""Validate that essential autoloads are available"""
	var missing_autoloads = []
	
	# Check critical autoloads
	if not DebugManager:
		missing_autoloads.append("DebugManager")
	if not SceneManager:
		missing_autoloads.append("SceneManager")
	if not UIThemeManager:
		missing_autoloads.append("UIThemeManager")
	
	if missing_autoloads.size() > 0:
		print("SceneInitializationHelper: WARNING - Missing autoloads: ", missing_autoloads)
		print("SceneInitializationHelper: Some features may not work properly")
	else:
		print("SceneInitializationHelper: All critical autoloads available")

static func sync_with_scene_manager(scene_node: Node):
	"""Update SceneManager to know about the current scene"""
	if SceneManager:
		# Update SceneManager's current_scene reference
		SceneManager.current_scene = scene_node
		print("SceneInitializationHelper: Updated SceneManager.current_scene to ", scene_node.name)
	else:
		print("SceneInitializationHelper: SceneManager not available - scene tracking disabled")

static func register_with_map_manager(scene_node: Node):
	"""Register with MapManager if the scene has location info"""
	if not MapManager:
		print("SceneInitializationHelper: MapManager not available - skipping registration")
		return
	
	# Try to determine scene ID from node name or script
	var scene_id = scene_node.name.to_lower()
	
	# Check if scene has an explicit scene_id export
	if scene_node.has_method("get") and "scene_id" in scene_node:
		if scene_node.scene_id != "":
			scene_id = scene_node.scene_id
	
	# Register with MapManager
	if MapManager.has_method("register_current_scene"):
		MapManager.register_current_scene(scene_id)
		print("SceneInitializationHelper: Registered scene '", scene_id, "' with MapManager")
	else:
		print("SceneInitializationHelper: MapManager registration method not found")

static func setup_scene_type_defaults(scene_node: Node, default_scene_type: String = "test"):
	"""Set up default scene type properties for testing"""
	# Set scene_type if not already set
	if scene_node.has_method("get") and "scene_type" in scene_node:
		if scene_node.scene_type == "":
			scene_node.scene_type = default_scene_type
			print("SceneInitializationHelper: Set scene_type to '", default_scene_type, "'")
	
	# Set scene_id if not already set
	if scene_node.has_method("get") and "scene_id" in scene_node:
		if scene_node.scene_id == "":
			scene_node.scene_id = scene_node.name.to_lower()
			print("SceneInitializationHelper: Set scene_id to '", scene_node.scene_id, "'")

static func ensure_ui_theme_applied(scene_node: Node):
	"""Ensure UI theme is applied to the scene"""
	if not UIThemeManager:
		print("SceneInitializationHelper: UIThemeManager not available - skipping theme application")
		return
	
	# Wait for UIThemeManager to be ready
	await scene_node.get_tree().process_frame
	
	# Check if UIThemeManager has a current theme
	if not UIThemeManager.current_theme:
		print("SceneInitializationHelper: UIThemeManager has no current theme - trying to initialize")
		# Force theme initialization if needed
		if UIThemeManager.has_method("get_current_theme"):
			var fallback = UIThemeManager.get_current_theme()
			if fallback:
				UIThemeManager.current_theme = fallback
				print("SceneInitializationHelper: Created emergency theme for scene testing")
	
	# Find UI components in the scene and register them
	var ui_components = []
	find_ui_components_recursive(scene_node, ui_components)
	
	for component in ui_components:
		if UIThemeManager.has_method("register_ui_component"):
			UIThemeManager.register_ui_component(component)
	
	print("SceneInitializationHelper: Registered ", ui_components.size(), " UI components with theme manager")

static func find_ui_components_recursive(node: Node, components_array: Array):
	"""Recursively find UI components in the scene tree"""
	if node is Control:
		components_array.append(node)
	
	for child in node.get_children():
		find_ui_components_recursive(child, components_array)

static func create_test_player_if_missing(scene_node: Node) -> Node:
	"""Create a basic test player if none exists in the scene"""
	var existing_players = scene_node.get_tree().get_nodes_in_group("player")
	if existing_players.size() > 0:
		print("SceneInitializationHelper: Player already exists in scene")
		return existing_players[0]
	
	print("SceneInitializationHelper: No player found - creating test player")
	
	# Try to load the Player scene
	var player_scene_path = "res://scenes/characters/Player.tscn"
	if FileAccess.file_exists(player_scene_path):
		var player_scene = load(player_scene_path)
		if player_scene:
			var player = player_scene.instantiate()
			scene_node.add_child(player)
			player.global_position = Vector2(540, 360)  # Center of screen
			print("SceneInitializationHelper: Created player at center position")
			return player
		else:
			print("SceneInitializationHelper: Failed to load player scene")
	else:
		print("SceneInitializationHelper: Player scene not found at ", player_scene_path)
	
	return null 