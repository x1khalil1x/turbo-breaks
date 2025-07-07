extends Area2D
class_name Doorway

@export var target_scene: String = ""
@export var target_position: Vector2 = Vector2.ZERO
@export var doorway_id: String = ""
@export var show_debug_shape: bool = true  # Toggle for production

# Entry direction and push distance system
@export var entry_direction: Vector2 = Vector2(0, 1)  # Direction player should face after entering
@export var push_distance: float = 40.0  # Distance to push player away from doorway
@export var doorway_width: float = 64.0  # Width of doorway opening
@export var doorway_height: float = 32.0  # Height of doorway opening

signal player_entered_doorway(target_scene: String, target_position: Vector2, entry_direction: Vector2)

# Cooldown system to prevent rapid transitions
var transition_cooldown: float = 0.0
const COOLDOWN_TIME: float = 1.0  # 1 second cooldown

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("doorways")
	
	# Visual feedback (optional - controlled by export)
	if show_debug_shape:
		var collision_shape = CollisionShape2D.new()
		var rectangle_shape = RectangleShape2D.new()
		rectangle_shape.size = Vector2(doorway_width, doorway_height)
		collision_shape.shape = rectangle_shape
		add_child(collision_shape)
		
		# Add entry direction indicator in debug mode
		if entry_direction != Vector2.ZERO:
			var direction_indicator = Line2D.new()
			direction_indicator.add_point(Vector2.ZERO)
			direction_indicator.add_point(entry_direction.normalized() * 30)
			direction_indicator.default_color = Color.YELLOW
			direction_indicator.width = 3.0
			add_child(direction_indicator)
	
	print("Doorway setup: ", doorway_id, " -> ", target_scene)
	print("  Entry direction: ", entry_direction, " Push distance: ", push_distance)

func _process(delta):
	if transition_cooldown > 0:
		transition_cooldown -= delta

func _on_body_entered(body):
	if body.is_in_group("player") and transition_cooldown <= 0:
		print("Player entered doorway: ", doorway_id)
		transition_cooldown = COOLDOWN_TIME
		
		if DebugManager:
			DebugManager.log_info("Doorway entered: " + doorway_id + " -> " + target_scene)
		
		# Calculate safe spawn position with push distance
		var safe_position = calculate_safe_spawn_position()
		
		player_entered_doorway.emit(target_scene, safe_position, entry_direction)

func calculate_safe_spawn_position() -> Vector2:
	"""Calculate safe spawn position that accounts for push distance"""
	if push_distance <= 0:
		return target_position
	
	# Push player away from doorway in the entry direction
	var push_offset = entry_direction.normalized() * push_distance
	var safe_position = target_position + push_offset
	
	print("Doorway: Calculated safe spawn - Original: ", target_position, " Safe: ", safe_position)
	return safe_position

func set_entry_direction_from_name():
	"""Auto-set entry direction based on doorway ID for convenience"""
	var id_lower = doorway_id.to_lower()
	
	if "north" in id_lower or "top" in id_lower:
		entry_direction = Vector2(0, 1)  # Face down when entering from north
	elif "south" in id_lower or "bottom" in id_lower:
		entry_direction = Vector2(0, -1)  # Face up when entering from south
	elif "east" in id_lower or "right" in id_lower:
		entry_direction = Vector2(-1, 0)  # Face left when entering from east
	elif "west" in id_lower or "left" in id_lower:
		entry_direction = Vector2(1, 0)  # Face right when entering from west
	elif "exit" in id_lower:
		entry_direction = Vector2(0, -1)  # Face up when exiting buildings
	else:
		entry_direction = Vector2(0, 1)  # Default face down

func validate_configuration() -> Dictionary:
	"""Validate doorway configuration for debug purposes"""
	var result = {"valid": true, "issues": []}
	
	if target_scene == "":
		result.valid = false
		result.issues.append("No target scene set")
	
	if doorway_id == "":
		result.valid = false
		result.issues.append("No doorway ID set")
	
	if not FileAccess.file_exists(target_scene):
		result.valid = false
		result.issues.append("Target scene file doesn't exist: " + target_scene)
	
	if push_distance < 30.0:
		result.issues.append("Push distance may be too small (recommended: 40+)")
	
	if entry_direction == Vector2.ZERO:
		result.issues.append("Entry direction not set - player orientation will be random")
	
	return result 
