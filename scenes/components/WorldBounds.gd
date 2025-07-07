extends Node2D
class_name WorldBounds

@export var world_size: Vector2 = Vector2(1280, 720)
var boundary_thickness: float = 32.0

func _ready():
	create_world_boundaries()
	setup_camera_limits()

func create_world_boundaries():
	# TOP BOUNDARY
	create_boundary(Vector2(world_size.x/2, -boundary_thickness/2), Vector2(world_size.x, boundary_thickness))
	
	# BOTTOM BOUNDARY  
	create_boundary(Vector2(world_size.x/2, world_size.y + boundary_thickness/2), Vector2(world_size.x, boundary_thickness))
	
	# LEFT BOUNDARY
	create_boundary(Vector2(-boundary_thickness/2, world_size.y/2), Vector2(boundary_thickness, world_size.y))
	
	# RIGHT BOUNDARY
	create_boundary(Vector2(world_size.x + boundary_thickness/2, world_size.y/2), Vector2(boundary_thickness, world_size.y))

func create_boundary(pos: Vector2, size: Vector2):
	var boundary = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	shape.size = size
	collision.shape = shape
	boundary.position = pos
	boundary.add_child(collision)
	add_child(boundary)

func setup_camera_limits():
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = int(world_size.x)
		camera.limit_bottom = int(world_size.y) 