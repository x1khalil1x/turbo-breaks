extends AudioStreamPlayer

# Singleton for managing background music
# Add this as an AutoLoad in Project Settings

var music_catalog: Dictionary = {}
var current_track: String = ""

func _ready():
	load_music_catalog()

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
	else:
		print("Track not found in catalog: ", track_name)

func fade_to_track(new_stream: AudioStream, track_name: String):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80, 0.5)
	tween.tween_callback(func():
		stream = new_stream
		play()
		current_track = track_name
	)
	tween.tween_property(self, "volume_db", 0, 0.5)

func stop_music(fade_out: bool = true):
	if fade_out:
		var tween = create_tween()
		tween.tween_property(self, "volume_db", -80, 0.5)
		tween.tween_callback(stop)
		tween.tween_callback(func(): volume_db = 0)
	else:
		stop()
	current_track = "" 
