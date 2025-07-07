@tool
extends Node2D
class_name SceneBorderDebug

## Scene Border Debug Visualization Component
## Shows the actual scene boundaries for tile placement and camera limits

@export var border_color: Color = Color.MAGENTA
@export var border_width: float = 2.0
@export var scene_size: Vector2 = Vector2(1280, 720)
@export var show_in_game: bool = false

var border_line: Line2D

func _ready():
	create_border_line()
	
	# Hide in production unless specifically enabled
	if not Engine.is_editor_hint() and not show_in_game:
		visible = false

func create_border_line():
	if border_line:
		border_line.queue_free()
	
	border_line = Line2D.new()
	border_line.width = border_width
	border_line.default_color = border_color
	border_line.closed = true
	
	# Create rectangle border
	border_line.points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(scene_size.x, 0),
		Vector2(scene_size.x, scene_size.y),
		Vector2(0, scene_size.y),
		Vector2(0, 0)
	])
	
	add_child(border_line)

func _validate_property(property):
	# Update border when properties change in editor
	if property.name in ["border_color", "border_width", "scene_size"]:
		if border_line:
			call_deferred("create_border_line") 