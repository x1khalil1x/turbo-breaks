extends Node2D

func _ready():
	# Start with the lobby scene (now includes intro animation)
	SceneManager.change_scene_to_lobby() 
