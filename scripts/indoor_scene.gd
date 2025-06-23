extends Node2D

func _ready():
	# Connect to ALL doorways in the scene
	for doorway in get_tree().get_nodes_in_group("doorways"):
		doorway.player_entered_doorway.connect(_on_doorway_entered)
	
	if DebugManager:
		DebugManager.log_info("Indoor scene loaded: " + name)

func _on_doorway_entered(target_scene: String, target_position: Vector2):
	print("Indoor scene received doorway signal - transitioning to: ", target_scene)
	if DebugManager:
		DebugManager.log_doorway_event("indoor_transition", "Scene change to " + target_scene)
	SceneManager.change_scene_with_position(target_scene, target_position) 