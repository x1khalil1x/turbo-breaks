extends Node2D

@export var scene_id: String = ""
@export var scene_type: String = "outdoor"

func _ready():
	# Initialize scene with standardized pattern
	await initialize_scene()

func initialize_scene():
	# Wait for all nodes to be ready
	await get_tree().process_frame
	
	# 1. Connect doorway signals
	setup_doorway_connections()
	
	# 2. Register with MapManager if outdoor and MapManager exists
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
	
	# 3. Initialize debug logging and validation
	if DebugManager:
		DebugManager.log_info("Scene loaded: " + scene_id + " (type: " + scene_type + ")")
		validate_current_scene()

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
	
	# Check for camera
	var cameras = get_tree().get_nodes_in_group("camera")
	if cameras.size() == 0:
		issues.append("No camera found in scene")
	elif cameras.size() > 1:
		issues.append("Multiple cameras found - may cause conflicts")
	
	# Log validation results
	if issues.size() > 0:
		DebugManager.log_warning("Scene validation issues for '" + scene_id + "':")
		for issue in issues:
			DebugManager.log_warning("  - " + issue)
	else:
		DebugManager.log_info("Scene '" + scene_id + "' validation passed")

func _on_doorway_entered(target_scene: String, target_position: Vector2):
	if DebugManager:
		DebugManager.log_scene_transition(scene_id, target_scene, target_position)
	
	print("Scene '" + scene_id + "' transitioning to: " + target_scene)
	SceneManager.change_scene_with_position(target_scene, target_position) 
