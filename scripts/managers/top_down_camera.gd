extends Camera2D

## Enhanced Camera Controller - Smooth following with deadzone
## Optimized for responsive movement without jitter

# Enhanced settings
@export var follow_speed: float = 8.0
@export var dead_zone_radius: float = 16.0
@export var world_bounds: Vector2 = Vector2(1080, 720)

# Target tracking
var target: Node2D = null

func _ready() -> void:
	# Keep it simple - no zoom complications
	zoom = Vector2(1.0, 1.0)
	
	# Get viewport info
	var viewport_size = get_viewport().get_visible_rect().size
	print("Camera Controller - Viewport: ", viewport_size)
	print("Camera Controller - World: ", world_bounds)
	
	# Use manual bounds handling for precise control
	limit_left = -999999
	limit_top = -999999
	limit_right = 999999
	limit_bottom = 999999
	
	# Find and follow player
	call_deferred("find_player")

func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		# Start camera centered on player
		global_position = target.global_position
		print("Camera Controller - Found player, camera positioned at: ", global_position)
	else:
		print("Camera Controller - ERROR: No player found in 'player' group!")

func _process(delta: float) -> void:
	if not target:
		return
		
	# Calculate distance from camera center to player
	var distance_to_player = global_position.distance_to(target.global_position)
	
	# Only move camera if player is outside dead zone
	if distance_to_player > dead_zone_radius:
		# Calculate desired position (towards player, maintaining dead zone)
		var direction_to_player = global_position.direction_to(target.global_position)
		var desired_distance = distance_to_player - dead_zone_radius
		var desired_position = global_position + (direction_to_player * desired_distance)
		
		# Smooth camera movement
		global_position = global_position.lerp(desired_position, follow_speed * delta)
		
		# Apply world bounds constraints
		apply_world_bounds()

func apply_world_bounds():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate bounds for camera center position
	var min_x = viewport_size.x / 2
	var min_y = viewport_size.y / 2
	var max_x = world_bounds.x - viewport_size.x / 2
	var max_y = world_bounds.y - viewport_size.y / 2
	
	# Clamp camera position within bounds
	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y) 
