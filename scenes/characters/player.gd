extends CharacterBody2D
class_name Player

# Movement settings
@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

@onready var sprite = $AnimatedSprite2D

# Track last movement direction for idle states
var last_direction: String = "down"
var input_direction: Vector2 = Vector2.ZERO

func _ready():
	# Add to player group for doorway detection
	add_to_group("player")

func _physics_process(delta):
	handle_input()
	apply_movement(delta)
	
	# COLLISION MAGIC HAPPENS HERE
	move_and_slide()  # Godot handles all collision automatically!
	
	update_animation()

func handle_input():
	# Get input direction
	input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	
	# Normalize to prevent faster diagonal movement
	input_direction = input_direction.normalized()

func apply_movement(delta):
	if input_direction != Vector2.ZERO:
		# Accelerate towards target speed
		velocity = velocity.move_toward(input_direction * max_speed, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func update_animation():
	if not sprite:
		return
		
	# Only change animation direction if we're moving significantly
	if velocity.length() > 20.0:  # Minimum movement threshold
		# Determine primary direction for animation
		var current_direction: String
		
		if abs(velocity.x) > abs(velocity.y):
			# Moving horizontally
			if velocity.x > 0:
				current_direction = "right"
			else:
				current_direction = "left"
		else:
			# Moving vertically  
			if velocity.y > 0:
				current_direction = "down"
			else:
				current_direction = "up"
		
		# Update last direction and play walk animation
		last_direction = current_direction
		play_animation("walk_" + current_direction)
	else:
		# Idle - use last movement direction
		play_animation("idle_" + last_direction)

func play_animation(anim_name: String):
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:  # Only change if different
			sprite.play(anim_name)
