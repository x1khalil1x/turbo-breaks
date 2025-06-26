extends Node

# 3x3 GRID MAP - 9 total scenes
var map_scenes = {
	# TOP ROW
	Vector2(0, 0): "res://scenes/levels/outdoor/NorthWest.tscn",
	Vector2(1, 0): "res://scenes/levels/outdoor/North.tscn", 
	Vector2(2, 0): "res://scenes/levels/outdoor/NorthEast.tscn",
	
	# MIDDLE ROW
	Vector2(0, 1): "res://scenes/levels/outdoor/West.tscn",
	Vector2(1, 1): "res://scenes/levels/outdoor/Center.tscn",  # Starting area
	Vector2(2, 1): "res://scenes/levels/outdoor/East.tscn",
	
	# BOTTOM ROW
	Vector2(0, 2): "res://scenes/levels/outdoor/SouthWest.tscn",
	Vector2(1, 2): "res://scenes/levels/outdoor/South.tscn",
	Vector2(2, 2): "res://scenes/levels/outdoor/SouthEast.tscn"
}

var current_map_position: Vector2 = Vector2(1, 1)  # Start at center

# MOVEMENT DIRECTIONS
var NORTH = Vector2(0, -1)
var SOUTH = Vector2(0, 1) 
var EAST = Vector2(1, 0)
var WEST = Vector2(-1, 0)

func move_to_adjacent_scene(direction: Vector2):
	var new_position = current_map_position + direction
	
	print("MapManager: Trying to move from ", current_map_position, " to ", new_position)
	
	# CHECK IF TARGET SCENE EXISTS
	if new_position in map_scenes:
		var scene_path = map_scenes[new_position]
		var spawn_pos = get_spawn_position_for_direction(direction)
		
		print("MapManager: Moving to ", scene_path, " spawn at ", spawn_pos)
		
		current_map_position = new_position
		SceneManager.change_scene_with_position(scene_path, spawn_pos)
	else:
		print("MapManager: No scene at position ", new_position, " - staying put")

# SPAWN POSITIONS - where player appears when entering scene
func get_spawn_position_for_direction(direction: Vector2) -> Vector2:
	# Spawn at OPPOSITE edge of where player came from
	match direction:
		Vector2(0, -1):  return Vector2(540, 680)   # Came from SOUTH, spawn at BOTTOM
		Vector2(0, 1):   return Vector2(540, 40)    # Came from NORTH, spawn at TOP
		Vector2(-1, 0):  return Vector2(1040, 360)  # Came from EAST, spawn at RIGHT
		Vector2(1, 0):   return Vector2(40, 360)    # Came from WEST, spawn at LEFT
		_: return Vector2(540, 360)  # Default center

# UTILITY FUNCTIONS
func get_current_scene_name() -> String:
	if current_map_position in map_scenes:
		return map_scenes[current_map_position].get_file().get_basename()
	return "Unknown"

func can_move_direction(direction: Vector2) -> bool:
	var target_pos = current_map_position + direction
	return target_pos in map_scenes

# SCENE REGISTRATION AND TRACKING
func register_current_scene(scene_id: String):
	"""Register a scene when it loads - used for debugging and tracking"""
	print("MapManager: Registered scene: ", scene_id)
	
	# Try to update current_map_position based on scene_id
	update_position_from_scene_id(scene_id)
	
	if DebugManager:
		DebugManager.log_info("MapManager: Scene '" + scene_id + "' registered at position " + str(current_map_position))

func update_position_from_scene_id(scene_id: String):
	"""Update current map position based on scene ID"""
	# Convert scene_id to map position
	var scene_name = scene_id.to_lower()
	
	# Map scene names to positions
	var scene_positions = {
		"center": Vector2(1, 1),
		"north": Vector2(1, 0),
		"south": Vector2(1, 2),
		"east": Vector2(2, 1),
		"west": Vector2(0, 1),
		"northeast": Vector2(2, 0),
		"northwest": Vector2(0, 0),
		"southeast": Vector2(2, 2),
		"southwest": Vector2(0, 2)
	}
	
	if scene_name in scene_positions:
		current_map_position = scene_positions[scene_name]
		print("MapManager: Updated position to ", current_map_position, " for scene ", scene_id)
	else:
		print("MapManager: Unknown scene name: ", scene_id, " - keeping current position")

func get_current_position() -> Vector2:
	"""Get the current map position"""
	return current_map_position

func set_current_position(position: Vector2):
	"""Set the current map position"""
	if position in map_scenes:
		current_map_position = position
		print("MapManager: Position set to ", current_map_position)
	else:
		print("MapManager: Invalid position ", position, " - ignoring") 