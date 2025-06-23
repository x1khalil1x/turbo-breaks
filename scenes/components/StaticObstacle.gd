extends StaticBody2D
class_name StaticObstacle

@export var obstacle_type: String = "generic"

func _ready():
	# Add collision shape automatically
	if not get_child_count() > 0:
		create_default_collision()

func create_default_collision():
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)  # Default size
	collision.shape = shape
	add_child(collision) 