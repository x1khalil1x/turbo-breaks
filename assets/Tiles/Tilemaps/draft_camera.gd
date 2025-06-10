extends Node

@onready var camera = $"../Camera2D"

const CAMERA_SPEED = 300.0
const ZOOM_SPEED = 0.1
const MIN_ZOOM = 0.5
const MAX_ZOOM = 4.0

func _ready():
	# Set initial camera position
	camera.global_position = Vector2.ZERO

func _process(delta):
	handle_camera_movement(delta)
	handle_camera_zoom()

func handle_camera_movement(delta):
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	
	# Normalize diagonal movement and apply speed
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		camera.global_position += input_vector * CAMERA_SPEED * delta / camera.zoom.x

func handle_camera_zoom():
	if Input.is_action_just_pressed("wheel_up"):
		var new_zoom = camera.zoom.x + ZOOM_SPEED
		camera.zoom = Vector2(new_zoom, new_zoom).clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	
	if Input.is_action_just_pressed("wheel_down"):
		var new_zoom = camera.zoom.x - ZOOM_SPEED
		camera.zoom = Vector2(new_zoom, new_zoom).clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM)) 