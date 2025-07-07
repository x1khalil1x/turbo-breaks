extends Node2D

@export var scene_id: String = ""
@export var scene_type: String = "outdoor"

func _ready():
	# Enhanced initialization that works both standalone and in normal game flow
	call_deferred("initialize_scene")

func initialize_scene():
	# ENHANCED: Use SceneInitializationHelper for standalone testing
	if is_standalone_testing():
		print("OutdoorScene: Detected standalone testing - using enhanced initialization")
		if SceneInitializationHelper:
			SceneInitializationHelper.setup_scene_type_defaults(self, "outdoor")
			SceneInitializationHelper.create_test_player_if_missing(self)
	
	# Standard initialization (works for both normal and standalone)
	setup_doorway_connections()
	register_with_systems()
	finalize_scene_setup()

func is_standalone_testing() -> bool:
	"""Detect if this scene is being run standalone vs through SceneManager"""
	# Check if we're the main scene (indicates standalone testing)
	return get_tree().current_scene == self

func setup_doorway_connections():
	var doorways = get_tree().get_nodes_in_group("doorways")
	
	if doorways.size() == 0:
		if DebugManager:
			DebugManager.log_warning("Scene '" + scene_id + "' has no doorways")
		return
	
	for doorway in doorways:
		if not doorway.player_entered_doorway.is_connected(_on_doorway_entered):
			doorway.player_entered_doorway.connect(_on_doorway_entered)
		
		# Validate doorway configuration
		if DebugManager:
			var validation = doorway.validate_configuration()
			if not validation.valid:
				DebugManager.log_warning("Doorway '" + doorway.doorway_id + "' issues: " + str(validation.issues))
	
	if DebugManager:
		DebugManager.log_info("Connected " + str(doorways.size()) + " doorways in scene: " + scene_id)

func register_with_systems():
	"""Register with MapManager and other systems"""
	if scene_type == "outdoor":
		if scene_id == "":
			scene_id = name.to_lower()
		
		# Check if MapManager autoload exists
		if has_node("/root/MapManager"):
			var map_manager = get_node("/root/MapManager")
			if map_manager.has_method("register_current_scene"):
				map_manager.register_current_scene(scene_id)
			else:
				print("MapManager exists but register_current_scene method not found")
		else:
			print("MapManager autoload not found - scene registration skipped")

func finalize_scene_setup():
	"""Final setup and validation"""
	if DebugManager:
		DebugManager.log_info("Scene loaded: " + scene_id + " (type: " + scene_type + ")")
		validate_current_scene()

func find_cameras_recursive(node: Node, camera_list: Array):
	"""Recursively find Camera2D nodes"""
	if node is Camera2D:
		camera_list.append(node)
	
	for child in node.get_children():
		find_cameras_recursive(child, camera_list)

func validate_current_scene():
	"""Validate the current scene configuration"""
	if not DebugManager:
		return
	
	var issues = []
	
	# Check for required components
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() == 0:
		issues.append("No player found in scene")
	elif player_nodes.size() > 1:
		issues.append("Multiple players found in scene")
	
	# Check for camera (global camera system is preferred)
	var cameras = get_tree().get_nodes_in_group("camera")
	var camera_nodes = get_tree().get_nodes_in_group("camera")
	
	# Look for Camera2D nodes if no camera group found
	if cameras.size() == 0:
		camera_nodes = []
		find_cameras_recursive(get_tree().current_scene, camera_nodes)
	
	if camera_nodes.size() == 0:
		# Check for global camera system (preferred architecture)
		var has_global_camera = false
		if has_node("/root/Main"):
			var main_scene = get_node("/root/Main")
			find_cameras_recursive(main_scene, camera_nodes)
			if camera_nodes.size() > 0:
				has_global_camera = true
		
		if not has_global_camera:
			issues.append("No camera found in scene or global camera system")
		else:
			# Global camera found - this is good architecture
			DebugManager.log_info("Using global camera system (recommended)")
	elif camera_nodes.size() > 1:
		issues.append("Multiple cameras found - may cause conflicts")
	
	# Log validation results
	if issues.size() > 0:
		DebugManager.log_warning("Scene validation issues for '" + scene_id + "':")
		for issue in issues:
			DebugManager.log_warning("  - " + issue)
	else:
		DebugManager.log_info("Scene '" + scene_id + "' validation passed")

func _on_doorway_entered(target_scene: String, target_position: Vector2, entry_direction: Vector2 = Vector2.ZERO):
	if DebugManager:
		DebugManager.log_info("Scene transition: " + scene_id + " -> " + target_scene + " at " + str(target_position))
	
	print("Scene '" + scene_id + "' transitioning to: " + target_scene)
	print("  Target position: " + str(target_position) + " Entry direction: " + str(entry_direction))
	SceneManager.change_scene_with_position(target_scene, target_position) 
