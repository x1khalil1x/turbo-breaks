extends Area2D
class_name Doorway

@export var target_scene: String = ""
@export var target_position: Vector2 = Vector2.ZERO
@export var doorway_id: String = ""
@export var show_debug_shape: bool = true  # Toggle for production

signal player_entered_doorway(target_scene: String, target_position: Vector2)

# Cooldown system to prevent rapid transitions
var transition_cooldown: float = 0.0
const COOLDOWN_TIME: float = 1.0  # 1 second cooldown

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("doorways")
	
	# Visual feedback (optional - controlled by export)
	if show_debug_shape:
		var collision_shape = CollisionShape2D.new()
		var rectangle_shape = RectangleShape2D.new()
		rectangle_shape.size = Vector2(64, 32)  # Doorway size
		collision_shape.shape = rectangle_shape
		add_child(collision_shape)
	
	print("Doorway setup: ", doorway_id, " -> ", target_scene)

func _process(delta):
	if transition_cooldown > 0:
		transition_cooldown -= delta

func _on_body_entered(body):
	if body.is_in_group("player") and transition_cooldown <= 0:
		print("Player entered doorway: ", doorway_id)
		transition_cooldown = COOLDOWN_TIME
		
		if DebugManager:
			DebugManager.log_doorway_event(doorway_id, "Player entered")
		
		player_entered_doorway.emit(target_scene, target_position)

func validate_configuration() -> Dictionary:
	"""Validate doorway configuration for debug purposes"""
	var result = {"valid": true, "issues": []}
	
	if target_scene == "":
		result.valid = false
		result.issues.append("No target scene set")
	
	if doorway_id == "":
		result.valid = false
		result.issues.append("No doorway ID set")
	
	if not FileAccess.file_exists(target_scene):
		result.valid = false
		result.issues.append("Target scene file doesn't exist: " + target_scene)
	
	return result 
