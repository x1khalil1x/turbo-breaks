extends Node

@onready var camera = $"../Camera2D"

const CAMERA_SPEED = 400.0  # Faster for platformer testing
const ZOOM_SPEED = 0.15
const MIN_ZOOM = 0.8        # Allow more zoomed out for level overview
const MAX_ZOOM = 4.0

func _ready():
	camera.global_position = Vector2.ZERO

func _process(delta):
	handle_camera_movement(delta)
	handle_camera_zoom()
	handle_special_controls()

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
	
	# Speed boost for platformer testing
	var speed_multiplier = 1.0
	if Input.is_key_pressed(KEY_SHIFT):
		speed_multiplier = 2.0
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		camera.global_position += input_vector * CAMERA_SPEED * speed_multiplier * delta / camera.zoom.x

func handle_camera_zoom():
	if Input.is_action_just_pressed("wheel_up"):
		var new_zoom = camera.zoom.x + ZOOM_SPEED
		camera.zoom = Vector2(new_zoom, new_zoom).clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	
	if Input.is_action_just_pressed("wheel_down"):
		var new_zoom = camera.zoom.x - ZOOM_SPEED
		camera.zoom = Vector2(new_zoom, new_zoom).clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))

func handle_special_controls():
	# Quick jump to spawn point for testing
	if Input.is_key_pressed(KEY_R):
		var spawn_marker = get_node_or_null("../TestMarkers/PlayerTestSpawn")
		if spawn_marker:
			camera.global_position = spawn_marker.global_position 