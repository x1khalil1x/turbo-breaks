extends CharacterBody2D
class_name Player

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D

# Track last movement direction for idle states
var last_direction: String = "down"

func _physics_process(delta):
	handle_input()
	move_and_slide()
	update_animation()

func handle_input():
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	
	# Normalize to prevent faster diagonal movement
	velocity = direction.normalized() * speed

func update_animation():
	if not sprite:
		return
		
	if velocity.length() > 0:
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
		sprite.play(anim_name)
