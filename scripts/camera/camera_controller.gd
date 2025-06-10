extends Camera2D
class_name CameraController

@export var follow_target: Node2D
@export var follow_speed: float = 5.0
@export var camera_bounds: Rect2

func _ready():
	make_current()

func _process(delta):
	if follow_target:
		global_position = global_position.lerp(follow_target.global_position, follow_speed * delta)
		apply_bounds()

func apply_bounds():
	if camera_bounds.size > Vector2.ZERO:
		global_position.x = clamp(global_position.x, camera_bounds.position.x, camera_bounds.end.x)
		global_position.y = clamp(global_position.y, camera_bounds.position.y, camera_bounds.end.y)
