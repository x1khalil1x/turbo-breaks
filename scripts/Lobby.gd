extends Node2D

# References to UI elements 
@onready var ui = $UI
@onready var background = $UI/Background
@onready var title_container = $UI/CenterContainer/MainContainer/TitleContainer
@onready var button_container = $UI/CenterContainer/MainContainer/ButtonContainer
@onready var title_label = $UI/CenterContainer/MainContainer/TitleContainer/TitleLabel
@onready var subtitle_label = $UI/CenterContainer/MainContainer/TitleContainer/SubtitleLabel

# Animation state
enum MenuState { SHADER_INTRO, TITLE_FADE, MENU_READY }
var current_state = MenuState.SHADER_INTRO
var intro_timer: float = 0.0
var intro_duration: float = 3.0  # 3 seconds before title appears

func _ready():
	print("Lobby: _ready() started")
	setup_initial_state()
	apply_fonts()
	start_intro_sequence()

func setup_initial_state():
	# Hide UI elements initially
	title_container.modulate.a = 0.0
	button_container.modulate.a = 0.0
	
	# Set music to menu mode
	if has_node("/root/MusicPlayer"):
		MusicPlayer.set_volume_mode(MusicPlayer.VolumeMode.MENU)

func start_intro_sequence():
	print("Lobby: Starting intro sequence")
	current_state = MenuState.SHADER_INTRO
	intro_timer = 0.0
	
	# Start lobby music
	if has_node("/root/MusicPlayer"):
		MusicPlayer.play_track("lobby_music")

func _process(delta):
	match current_state:
		MenuState.SHADER_INTRO:
			handle_shader_intro(delta)
		MenuState.TITLE_FADE:
			pass  # Handled by tween
		MenuState.MENU_READY:
			pass  # Ready for interaction

func handle_shader_intro(delta):
	intro_timer += delta
	
	if intro_timer >= intro_duration:
		start_title_fade()

func start_title_fade():
	print("Lobby: Starting title fade")
	current_state = MenuState.TITLE_FADE
	
	# Fade in title
	var tween = create_tween()
	tween.tween_property(title_container, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	show_menu_buttons()

func show_menu_buttons():
	print("Lobby: Showing menu buttons")
	current_state = MenuState.MENU_READY
	
	# Fade in buttons
	var tween = create_tween()
	tween.tween_property(button_container, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)

# Button handlers (same as your original)
func _on_drive_button_pressed():
	print("Lobby: Drive button pressed")
	fade_out_and_transition("drive")

func _on_font_demo_button_pressed():
	print("Lobby: Font demo button pressed")  
	fade_out_and_transition("font_demo")

func _on_exit_button_pressed():
	print("Lobby: Exit button pressed")
	get_tree().quit()

func fade_out_and_transition(destination: String):
	# Fade out elements
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_container, "modulate:a", 0.0, 0.4)
	tween.tween_property(button_container, "modulate:a", 0.0, 0.4)
	
	# FIXED: Use background instead of shader_background
	if background and background.material:
		tween.tween_property(background.material, "shader_parameter/fade_alpha", 0.0, 0.4)
	
	await tween.finished
	
	# Transition to destination
	match destination:
		"drive":
			SceneManager.change_scene_to_drive_mode()
		"font_demo":
			# Update this path based on where your font demo is
			SceneManager.change_scene("res://scenes/UI/font_demo/FontDemo.tscn") 

func apply_fonts():
	# ONLY apply fonts to labels - ignore buttons completely
	if FontManager:
		FontManager.make_title_text(title_label, "TURBO BREAKS", 48)
		FontManager.make_menu_text(subtitle_label, "Main Menu", 24)
		print("FontManager applied to labels only")
	
	# DO NOT touch buttons - let them keep their default text
