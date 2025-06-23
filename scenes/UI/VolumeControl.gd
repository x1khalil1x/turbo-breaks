extends Control
class_name VolumeControl

@onready var speaker_button = $VBoxContainer/SpeakerButton
@onready var volume_slider = $VBoxContainer/VolumeSlider
@onready var container = $VBoxContainer

var is_expanded: bool = false

func _ready():
	print("VolumeControl: _ready() called - should be visible now!")
	
	# Make sure it's visible
	visible = true
	modulate = Color.WHITE
	
	# Set initial size
	container.custom_minimum_size = Vector2(50, 50)
	
	# Hide slider initially
	volume_slider.visible = false
	
	connect_signals()
	update_speaker_icon()
	
	print("VolumeControl: Setup complete - button should be in top-right")

func connect_signals():
	print("VolumeControl: Connecting signals")
	
	if speaker_button:
		speaker_button.pressed.connect(_on_speaker_pressed)
		print("VolumeControl: Speaker button connected")
	else:
		print("VolumeControl: ERROR - Speaker button not found!")
	
	if volume_slider:
		volume_slider.value_changed.connect(_on_volume_changed)
		print("VolumeControl: Volume slider connected")
	
	# Check MusicPlayer autoload
	if MusicPlayer:
		print("VolumeControl: MusicPlayer found - connecting signals")
		MusicPlayer.volume_changed.connect(_on_music_volume_changed)
	else:
		print("VolumeControl: WARNING - MusicPlayer autoload not found!")

func _on_speaker_pressed():
	print("VolumeControl: Speaker button pressed!")
	if is_expanded:
		collapse_ui()
	else:
		expand_ui()

func expand_ui():
	print("VolumeControl: Expanding UI")
	is_expanded = true
	volume_slider.visible = true
	
	# Set slider value
	if MusicPlayer:
		volume_slider.value = MusicPlayer.get_master_volume()
	
	# Animate expansion
	var tween = create_tween()
	tween.tween_property(container, "custom_minimum_size", Vector2(200, 50), 0.3)

func collapse_ui():
	print("VolumeControl: Collapsing UI")
	is_expanded = false
	
	var tween = create_tween()
	tween.tween_property(container, "custom_minimum_size", Vector2(50, 50), 0.3)
	tween.tween_callback(func(): volume_slider.visible = false)

func _on_volume_changed(value: float):
	print("VolumeControl: Volume changed to: ", value)
	if MusicPlayer:
		MusicPlayer.set_master_volume(value)
	update_speaker_icon()

func _on_music_volume_changed(volume: float):
	if volume_slider and not volume_slider.has_focus():
		volume_slider.value = volume

func update_speaker_icon():
	if not speaker_button:
		return
		
	var volume = 0.7  # Default
	if MusicPlayer:
		volume = MusicPlayer.get_master_volume()
	
	if volume == 0.0:
		speaker_button.text = "🔇"
	elif volume < 0.3:
		speaker_button.text = "🔈"
	elif volume < 0.7:
		speaker_button.text = "🔉"
	else:
		speaker_button.text = "🔊"
	
	print("VolumeControl: Speaker icon updated to: ", speaker_button.text) 
