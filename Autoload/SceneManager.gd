extends Node

# Singleton for managing scene transitions
# Add this as an AutoLoad in Project Settings

signal scene_changed(scene_name: String)

var current_scene: Node = null

func _ready():
	print("SceneManager: Ready")
	# Get the current scene
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("SceneManager: Current scene:", current_scene.name if current_scene else "none")

func change_scene_to_file(path: String):
	print("SceneManager: change_scene_to_file called with path:", path)
	# Deferred call to avoid issues with the current scene
	call_deferred("_deferred_change_scene", path)

# Generic method for changing to any scene
func change_scene(path: String):
	print("SceneManager: change_scene called with path:", path)
	change_scene_to_file(path)

func _deferred_change_scene(path: String):
	print("SceneManager: _deferred_change_scene starting for:", path)
	
	# Check if file exists
	if not FileAccess.file_exists(path):
		print("SceneManager: ERROR - Scene file does not exist:", path)
		return
	
	# Free the current scene
	if current_scene:
		print("SceneManager: Freeing current scene:", current_scene.name)
		current_scene.free()
	
	# Load and instantiate the new scene
	print("SceneManager: Loading new scene...")
	var new_scene = load(path)
	if not new_scene:
		print("SceneManager: ERROR - Failed to load scene:", path)
		return
	
	print("SceneManager: Scene loaded successfully, instantiating...")
	current_scene = new_scene.instantiate()
	if not current_scene:
		print("SceneManager: ERROR - Failed to instantiate scene")
		return
	
	print("SceneManager: Scene instantiated successfully:", current_scene.name)
	
	# Add it to the scene tree
	print("SceneManager: Adding scene to tree...")
	get_tree().root.add_child(current_scene)
	print("SceneManager: Scene added to tree successfully")
	
	print("SceneManager: Setting as current scene...")
	get_tree().current_scene = current_scene
	print("SceneManager: Current scene set successfully")
	
	print("SceneManager: Scene change completed to:", current_scene.name)
	# Emit signal
	scene_changed.emit(path.get_file().get_basename())
	print("SceneManager: Signal emitted")

func change_scene_to_lobby():
	print("SceneManager: change_scene_to_lobby called")
	change_scene_to_file("res://scenes/lobby/Lobby.tscn")

func change_scene_to_drive_mode():
	print("SceneManager: change_scene_to_drive_mode called")
	change_scene_to_file("res://scenes/drive_mode/DriveMode.tscn") 

func change_scene_to_intro():
	print("SceneManager: change_scene_to_intro called")
	change_scene_to_file("res://scenes/intro/Intro.tscn") 

func change_scene_to_overworld():
	print("SceneManager: change_scene_to_overworld called")
	change_scene_to_file("res://scenes/overworld/OverworldTemplate.tscn")
