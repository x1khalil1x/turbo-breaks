extends Camera2D

## TopDownCamera - A smooth camera system for top-down 2D games
## Provides player following, smooth movement, and configurable bounds

# Camera settings
@export var follow_speed: float = 5.0
@export var look_ahead_distance: float = 50.0
@export var dead_zone_radius: float = 32.0
@export var smooth_enabled: bool = true

# Target tracking
var target: Node2D = null
var target_position: Vector2

# Camera state
var is_following: bool = true

func _ready() -> void:
	# Try to find a player node to follow
	find_target()
	
	# Set up camera properties
	enabled = true
	
	# Initialize target position
	if target:
		target_position = target.global_position
	else:
		target_position = global_position

func _process(delta: float) -> void:
	if not is_following or not target:
		return
	
	update_camera_position(delta)

func find_target() -> void:
	# Look for a player node in the scene
	var player_node = get_node_or_null("../Player")
	if player_node:
		set_target(player_node)
	else:
		# Try to find any node with "Player" in the name
		var scene_root = get_tree().current_scene
		if scene_root:
			var found_player = find_player_recursive(scene_root)
			if found_player:
				set_target(found_player)

func find_player_recursive(node: Node) -> Node2D:
	# Check if current node is a player
	if node.name.to_lower().contains("player") and node is Node2D:
		return node as Node2D
	
	# Check children
	for child in node.get_children():
		var result = find_player_recursive(child)
		if result:
			return result
	
	return null

func set_target(new_target: Node2D) -> void:
	target = new_target
	if target:
		target_position = target.global_position

func update_camera_position(delta: float) -> void:
	if not target:
		return
	
	var target_global_pos = target.global_position
	
	# Calculate distance to target
	var distance_to_target = global_position.distance_to(target_global_pos)
	
	# Only move camera if target is outside dead zone
	if distance_to_target > dead_zone_radius:
		if smooth_enabled:
			# Smooth camera movement
			target_position = target_global_pos
			global_position = global_position.lerp(target_position, follow_speed * delta)
		else:
			# Instant camera movement
			global_position = target_global_pos

func set_follow_speed(speed: float) -> void:
	follow_speed = clamp(speed, 0.1, 20.0)

func enable_following() -> void:
	is_following = true

func disable_following() -> void:
	is_following = false

func center_on_target() -> void:
	if target:
		global_position = target.global_position

# Utility functions for camera bounds (already handled by Camera2D limit properties)
func set_camera_bounds(left: int, top: int, right: int, bottom: int) -> void:
	limit_left = left
	limit_top = top
	limit_right = right
	limit_bottom = bottom 
