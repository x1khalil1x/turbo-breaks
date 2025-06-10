extends Node

@onready var camera = $"../Camera2D"
@onready var grid_helper = $"../GridHelper/IsometricGrid"

const CAMERA_SPEED = 300.0
const ZOOM_SPEED = 0.15
const MIN_ZOOM = 1.0
const MAX_ZOOM = 5.0

# Isometric tile dimensions (64x32 standard diamond)
const ISO_TILE_WIDTH = 64
const ISO_TILE_HEIGHT = 32

func _ready():
	camera.global_position = Vector2.ZERO
	draw_isometric_grid()

func _process(delta):
	handle_camera_movement(delta)
	handle_camera_zoom()
	handle_grid_controls()

func handle_camera_movement(delta):
	var input_vector = Vector2.ZERO
	
	# Option 1: Standard movement
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	
	# Option 2: Isometric-aligned movement (hold CTRL)
	if Input.is_key_pressed(KEY_CTRL):
		input_vector = Vector2.ZERO
		if Input.is_key_pressed(KEY_A):  # Move along iso X-axis
			input_vector += Vector2(-0.5, 0.25)
		if Input.is_key_pressed(KEY_D):
			input_vector += Vector2(0.5, -0.25)
		if Input.is_key_pressed(KEY_W):  # Move along iso Y-axis
			input_vector += Vector2(-0.5, -0.25)
		if Input.is_key_pressed(KEY_S):
			input_vector += Vector2(0.5, 0.25)
	
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

func handle_grid_controls():
	# Toggle grid visibility
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_G):
		grid_helper.visible = !grid_helper.visible

func draw_isometric_grid():
	# Draw a simple diamond grid pattern for reference
	var points = PackedVector2Array()
	
	# Draw diamond outline
	points.append(Vector2(0, -ISO_TILE_HEIGHT/2))   # Top
	points.append(Vector2(ISO_TILE_WIDTH/2, 0))     # Right
	points.append(Vector2(0, ISO_TILE_HEIGHT/2))    # Bottom
	points.append(Vector2(-ISO_TILE_WIDTH/2, 0))    # Left
	points.append(Vector2(0, -ISO_TILE_HEIGHT/2))   # Close
	
	grid_helper.points = points 