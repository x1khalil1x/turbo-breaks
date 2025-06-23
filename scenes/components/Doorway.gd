extends Area2D
class_name Doorway

@export var target_scene: String = ""
@export var target_position: Vector2 = Vector2.ZERO
@export var doorway_id: String = ""

signal player_entered_doorway(target_scene: String, target_position: Vector2)

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("doorways")
	
	# Visual feedback (optional)
	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(64, 32)  # Doorway size
	collision_shape.shape = rectangle_shape
	add_child(collision_shape)
	
	print("Doorway setup: ", doorway_id, " -> ", target_scene)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered doorway: ", doorway_id)
		if DebugManager:
			DebugManager.log_doorway_event(doorway_id, "Player entered")
		player_entered_doorway.emit(target_scene, target_position) 
