extends Node


# Removed unused signal - scene_changed

var current_scene: Node = null
var player_spawn_position: Vector2 = Vector2.ZERO

# Global transition cooldown system
var transition_cooldown: float = 0.0
const GLOBAL_TRANSITION_COOLDOWN: float = 1.5  # 1.5 seconds global cooldown

func _ready():
	print("SceneManager: Ready")
	# Get the current scene
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("SceneManager: Current scene:", str(current_scene.name) if current_scene else "none")

func _process(delta):
	if transition_cooldown > 0:
		transition_cooldown -= delta

func can_transition() -> bool:
	return transition_cooldown <= 0.0

func change_scene_to_file(path: String):
	if not can_transition():
		print("SceneManager: Transition blocked by global cooldown (", transition_cooldown, "s remaining)")
		return
		
	print("SceneManager: change_scene_to_file called with path:", path)
	# Deferred call to avoid issues with the current scene
	call_deferred("_deferred_change_scene", path)
	transition_cooldown = GLOBAL_TRANSITION_COOLDOWN
# Generic method for changing to any scene
func change_scene(path: String):
	print("SceneManager: change_scene called with path:", path)
	change_scene_to_file(path)

func change_scene_with_position(path: String, spawn_position: Vector2 = Vector2.ZERO):
	if not can_transition():
		print("SceneManager: Transition with position blocked by global cooldown (", transition_cooldown, "s remaining)")
		return
		
	print("SceneManager: change_scene_with_position - ", path, " at ", spawn_position)
	player_spawn_position = spawn_position
	change_scene_to_file(path)

func _deferred_change_scene(path: String):
	print("SceneManager: Loading scene: ", path)
	
	# Free current scene
	if current_scene:
		current_scene.free()
	
	# Load new scene
	var new_scene = load(path)
	if not new_scene:
		print("SceneManager: ERROR - Failed to load scene: ", path)
		return
	
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	# Position player if spawn position specified
	if player_spawn_position != Vector2.ZERO:
		call_deferred("position_player_in_new_scene")

func position_player_in_new_scene():
	await get_tree().process_frame  # Wait for scene to be fully ready
	
	var player = find_player_in_scene()
	if player:
		player.global_position = player_spawn_position
		print("SceneManager: Player positioned at: ", player_spawn_position)
		player_spawn_position = Vector2.ZERO
	else:
		print("SceneManager: WARNING - No player found in new scene!")

func find_player_in_scene() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func change_scene_to_lobby():
	print("SceneManager: change_scene_to_lobby called")
	change_scene_to_file("res://scenes/levels/lobby/Lobby.tscn")

func change_scene_to_drive_mode():
	print("SceneManager: change_scene_to_drive_mode called")
	change_scene_to_file("res://scenes/drive_mode/DriveMode.tscn") 

func change_scene_to_intro():
	print("SceneManager: change_scene_to_intro called")
	change_scene_to_file("res://scenes/intro/Intro.tscn") 

func change_scene_to_overworld():
	print("SceneManager: change_scene_to_overworld called")
	change_scene_to_file("res://scenes/overworld/OverworldTemplate.tscn")
