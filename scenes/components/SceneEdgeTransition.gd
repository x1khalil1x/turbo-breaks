extends Area2D
class_name SceneEdgeTransition

enum EdgeDirection { NORTH, SOUTH, EAST, WEST }

@export var edge_direction: EdgeDirection = EdgeDirection.NORTH
@export var target_scene: String = ""
@export var scene_id: String = ""
@export var spawn_position: Vector2 = Vector2.ZERO  # Manual spawn position

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("edge_transitions")
	print("EdgeTransition ready: ", scene_id, " ", EdgeDirection.keys()[edge_direction], " -> ", target_scene)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered edge: ", EdgeDirection.keys()[edge_direction])
		
		if DebugManager:
			DebugManager.log_info("Edge transition: " + scene_id + " -> " + target_scene + " at " + str(spawn_position))
		
		SceneManager.change_scene_with_position(target_scene, spawn_position)

func validate_configuration() -> Dictionary:
	"""Validate edge transition configuration for debug purposes"""
	var result = {"valid": true, "issues": []}
	
	if target_scene == "":
		result.valid = false
		result.issues.append("No target scene set")
	
	if scene_id == "":
		result.valid = false
		result.issues.append("No scene ID set")
	
	if not FileAccess.file_exists(target_scene):
		result.valid = false
		result.issues.append("Target scene file doesn't exist: " + target_scene)
	
	return result 
