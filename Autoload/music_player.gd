extends AudioStreamPlayer

# Singleton for managing background music with volume controls
signal volume_changed(new_volume: float)

var music_catalog: Dictionary = {}
var current_track: String = ""
var is_muted: bool = false
var master_volume: float = 0.5  # Default volume
var gameplay_volume: float = 0.4  # Lower volume during gameplay

enum VolumeMode { MENU, GAMEPLAY }
var current_mode: VolumeMode = VolumeMode.MENU

func _ready():
	load_music_catalog()
	# Set initial volume
	set_master_volume(master_volume)

func load_music_catalog():
	var file = FileAccess.open("res://data/music_catalog.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			music_catalog = json.data
		else:
			print("Error parsing music catalog: ", json.get_error_message())

func play_track(track_name: String, fade_in: bool = true):
	if track_name == current_track and playing:
		return
	
	if track_name in music_catalog:
		var track_path = music_catalog[track_name]["path"]
		var audio_stream = load(track_path)
		
		if audio_stream:
			if fade_in and playing:
				fade_to_track(audio_stream, track_name)
			else:
				stream = audio_stream
				play()
				current_track = track_name
				
		# Apply volume based on current mode
		apply_volume_mode()
	else:
		print("Track not found in catalog: ", track_name)

func fade_to_track(new_stream: AudioStream, track_name: String):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80, 0.5)
	tween.tween_callback(func():
		stream = new_stream
		play()
		current_track = track_name
		apply_volume_mode()
	)
	tween.tween_property(self, "volume_db", get_target_volume_db(), 0.5)

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	apply_volume_mode()
	volume_changed.emit(master_volume)

func get_master_volume() -> float:
	return master_volume

func toggle_mute():
	is_muted = !is_muted
	apply_volume_mode()

func set_mute(muted: bool):
	is_muted = muted
	apply_volume_mode()

func set_volume_mode(mode: VolumeMode):
	current_mode = mode
	apply_volume_mode()

func apply_volume_mode():
	if is_muted:
		volume_db = -80
		return
	
	var target_volume = get_target_volume_db()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", target_volume, 0.3)

func get_target_volume_db() -> float:
	var base_volume = master_volume
	
	match current_mode:
		VolumeMode.MENU:
			base_volume *= 0.4  # Full volume in menus
		VolumeMode.GAMEPLAY:
			base_volume *= 0.3  # Reduced volume during gameplay
	
	# Convert linear volume to decibels
	return linear_to_db(base_volume)

func stop_music(fade_out: bool = true):
	if fade_out:
		var tween = create_tween()
		tween.tween_property(self, "volume_db", -80, 0.5)
		tween.tween_callback(stop)
	else:
		stop()
	current_track = "" 
