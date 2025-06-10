extends Node2D

@onready var ui = $UI
@onready var background = $UI/Background
@onready var vbox_container = $UI/VBoxContainer

func _ready():
	print("DriveMode: _ready() started")
	
	# Debug UI nodes
	if ui:
		print("DriveMode: UI found:", ui.name)
	else:
		print("DriveMode: ERROR - UI not found!")
		return
	
	if background:
		print("DriveMode: Background found:", background.name)
	else:
		print("DriveMode: ERROR - Background not found!")
		return
		
	if vbox_container:
		print("DriveMode: VBoxContainer found:", vbox_container.name)
	else:
		print("DriveMode: ERROR - VBoxContainer not found!")
		return
	
	print("DriveMode: Setting up fade-in effect")
	# Start with UI children invisible for fade-in effect (CanvasLayer doesn't have modulate)
	background.modulate.a = 0.0
	vbox_container.modulate.a = 0.0
	
	print("DriveMode: Attempting to play music")
	# Play drive mode music when scene loads
	if MusicPlayer:
		print("DriveMode: MusicPlayer found, playing drive_mode_music")
		MusicPlayer.play_track("drive_mode_music")
		print("DriveMode: Music play_track called successfully")
	else:
		print("DriveMode: WARNING - MusicPlayer not available!")
	
	print("DriveMode: Creating fade-in tween")
	# Fade in the UI children
	var tween = create_tween()
	if tween:
		tween.set_parallel(true)
		tween.tween_property(background, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
		tween.tween_property(vbox_container, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
		print("DriveMode: Fade-in tween created successfully")
	else:
		print("DriveMode: ERROR - Could not create tween!")
	
	print("DriveMode: _ready() completed successfully")

func _on_back_button_pressed():
	print("DriveMode: Back button pressed")
	
	# Fade out before transitioning (fade the children, not the CanvasLayer)
	var tween = create_tween()
	if tween:
		tween.set_parallel(true)
		tween.tween_property(background, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
		tween.tween_property(vbox_container, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
		await tween.finished
		print("DriveMode: Fade out completed")
	
	# Use the SceneManager singleton to change back to lobby
	print("DriveMode: Returning to lobby")
	SceneManager.change_scene_to_lobby() 
