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