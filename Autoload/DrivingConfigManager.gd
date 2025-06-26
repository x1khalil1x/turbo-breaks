extends Node

## DrivingConfigManager - Phase 1 Implementation
## Vehicle configuration, track management, and driving system coordination
## Based on ROAD_RULES.md - Foundation First Approach

# Vehicle configuration
var vehicle_configs: Dictionary = {}  # vehicle_id -> vehicle_config_resource
var current_vehicle_config = null
var default_vehicle_id: String = "sports_car"

# Track configuration
var track_configs: Dictionary = {}  # track_id -> track_config_resource
var current_track_config = null
var available_tracks: Array[String] = []

# Driving state management
var driving_mode_active: bool = false
var current_biome: String = "urban"
var performance_settings: Dictionary = {}

# Configuration signals
signal vehicle_config_loaded(vehicle_id: String, config)
signal track_config_loaded(track_id: String, config)
signal driving_mode_changed(active: bool)
signal biome_changed(new_biome: String, previous_biome: String)

func _ready():
	print("DrivingConfigManager: Phase 1 initialized")
	
	# Initialize default configurations
	initialize_default_configs()
	
	# Load default vehicle
	load_vehicle_config(default_vehicle_id)
	
	# Connect to existing systems - wait for next frame to ensure autoloads are ready
	await get_tree().process_frame
	if DebugManager:
		DebugManager.log_info("DrivingConfigManager: Driving system configuration ready")
	else:
		print("DrivingConfigManager: DebugManager not available - continuing without logging")

func initialize_default_configs():
	"""Initialize default vehicle and track configurations for Phase 1"""
	# For Phase 1: Define configuration paths
	# TODO Phase 2: Load actual .tres resources from data/driving/
	
	# Vehicle configurations
	vehicle_configs = {
		"sports_car": create_default_vehicle_config("sports_car"),
		"heavy_truck": create_default_vehicle_config("heavy_truck"),
		"motorcycle": create_default_vehicle_config("motorcycle")
	}
	
	# Track configurations  
	track_configs = {
		"highway_01": create_default_track_config("highway_01"),
		"city_circuit": create_default_track_config("city_circuit"),
		"forest_trail": create_default_track_config("forest_trail")
	}
	
	var track_keys = track_configs.keys()
	available_tracks.clear()
	for key in track_keys:
		available_tracks.append(key)
	
	# Performance settings
	performance_settings = {
		"physics_fps": 60,
		"collision_accuracy": "normal",
		"particle_density": "medium",
		"draw_distance": 1000.0
	}
	
	DebugManager.log_info("DrivingConfigManager: Initialized " + str(vehicle_configs.size()) + " vehicle configs and " + str(track_configs.size()) + " track configs")

func create_default_vehicle_config(vehicle_id: String) -> Dictionary:
	"""Create default vehicle configuration for Phase 1"""
	var base_config = {
		"id": vehicle_id,
		"display_name": vehicle_id.capitalize().replace("_", " "),
		"max_speed": 300.0,
		"acceleration": 150.0,
		"handling": 0.8,
		"mass": 1000.0,
		"engine_sound": "res://audio/sfx/driving/engine_idle.ogg",
		"model_path": "res://assets/driving/vehicles/" + vehicle_id + ".tscn"
	}
	
	# Vehicle-specific adjustments
	match vehicle_id:
		"sports_car":
			base_config["max_speed"] = 400.0
			base_config["acceleration"] = 200.0
			base_config["handling"] = 0.9
			base_config["mass"] = 800.0
		"heavy_truck":
			base_config["max_speed"] = 200.0
			base_config["acceleration"] = 80.0
			base_config["handling"] = 0.6
			base_config["mass"] = 2500.0
		"motorcycle":
			base_config["max_speed"] = 350.0
			base_config["acceleration"] = 250.0
			base_config["handling"] = 0.95
			base_config["mass"] = 300.0
	
	return base_config

func create_default_track_config(track_id: String) -> Dictionary:
	"""Create default track configuration for Phase 1"""
	return {
		"id": track_id,
		"display_name": track_id.capitalize().replace("_", " "),
		"biome": "urban",
		"length": 5000.0,
		"difficulty": "medium",
		"checkpoints": 5,
		"music_track": "res://audio/music/driving/highway_driving.ogg",
		"scene_path": "res://scenes/driving/tracks/" + track_id + ".tscn",
		"preview_image": "res://assets/driving/tracks/" + track_id + "_preview.png"
	}

# Vehicle Management
func load_vehicle_config(vehicle_id: String) -> bool:
	"""Load vehicle configuration by ID"""
	if not vehicle_id in vehicle_configs:
		DebugManager.log_warning("DrivingConfigManager: Unknown vehicle ID: " + vehicle_id)
		return false
	
	current_vehicle_config = vehicle_configs[vehicle_id]
	vehicle_config_loaded.emit(vehicle_id, current_vehicle_config)
	
	DebugManager.log_info("DrivingConfigManager: Loaded vehicle config - " + vehicle_id)
	return true

func get_current_vehicle_config() -> Dictionary:
	"""Get current vehicle configuration"""
	return current_vehicle_config if current_vehicle_config != null else {}

func get_vehicle_config(vehicle_id: String) -> Dictionary:
	"""Get specific vehicle configuration"""
	return vehicle_configs.get(vehicle_id, {})

func get_available_vehicles() -> Array[String]:
	"""Get list of available vehicle IDs"""
	return vehicle_configs.keys()

# Track Management
func load_track_config(track_id: String) -> bool:
	"""Load track configuration by ID"""
	if not track_id in track_configs:
		DebugManager.log_warning("DrivingConfigManager: Unknown track ID: " + track_id)
		return false
	
	current_track_config = track_configs[track_id]
	
	# Update biome based on track
	var new_biome = current_track_config.get("biome", "urban")
	set_current_biome(new_biome)
	
	track_config_loaded.emit(track_id, current_track_config)
	DebugManager.log_info("DrivingConfigManager: Loaded track config - " + track_id)
	return true

func get_current_track_config() -> Dictionary:
	"""Get current track configuration"""
	return current_track_config if current_track_config != null else {}

func get_track_config(track_id: String) -> Dictionary:
	"""Get specific track configuration"""
	return track_configs.get(track_id, {})

func get_available_tracks() -> Array[String]:
	"""Get list of available track IDs"""
	return available_tracks.duplicate()

# Driving Mode Management
func enter_driving_mode(track_id: String = "", vehicle_id: String = ""):
	"""Enter driving mode with optional track and vehicle selection"""
	if track_id != "" and not load_track_config(track_id):
		DebugManager.log_error("DrivingConfigManager: Failed to load track for driving mode")
		return
	
	if vehicle_id != "" and not load_vehicle_config(vehicle_id):
		DebugManager.log_error("DrivingConfigManager: Failed to load vehicle for driving mode")
		return
	
	driving_mode_active = true
	driving_mode_changed.emit(true)
	
	# Update UI state
	if UIStateManager:
		UIStateManager.set_game_mode(UIStateManager.GameMode.DRIVING)
	
	DebugManager.log_info("DrivingConfigManager: Entered driving mode")

func exit_driving_mode():
	"""Exit driving mode and return to exploration"""
	driving_mode_active = false
	driving_mode_changed.emit(false)
	
	# Update UI state
	if UIStateManager:
		UIStateManager.set_game_mode(UIStateManager.GameMode.EXPLORATION)
	
	DebugManager.log_info("DrivingConfigManager: Exited driving mode")

# Biome and Environment Management
func set_current_biome(biome: String):
	"""Set current driving biome"""
	if biome == current_biome:
		return
	
	var previous_biome = current_biome
	current_biome = biome
	
	# Update audio based on biome
	update_biome_audio(biome)
	
	biome_changed.emit(biome, previous_biome)
	DebugManager.log_info("DrivingConfigManager: Biome changed from " + previous_biome + " to " + biome)

func update_biome_audio(biome: String):
	"""Update audio settings based on biome"""
	var music_track = get_biome_music(biome)
	
	if MusicPlayer and music_track != "":
		# TODO: Integrate with MusicPlayer to change biome music
		DebugManager.log_info("DrivingConfigManager: Would switch to biome music - " + music_track)

func get_biome_music(biome: String) -> String:
	"""Get music track for specific biome"""
	var biome_music = {
		"urban": "res://audio/music/driving/city_finale.ogg",
		"highway": "res://audio/music/driving/highway_driving.ogg",
		"forest": "res://audio/music/driving/forest_ambient.ogg",
		"desert": "res://audio/music/driving/desert_intensity.ogg"
	}
	
	return biome_music.get(biome, "")

# Performance and Settings
func update_performance_setting(setting: String, value):
	"""Update driving performance setting"""
	if setting in performance_settings:
		performance_settings[setting] = value
		DebugManager.log_info("DrivingConfigManager: Updated " + setting + " to " + str(value))
	else:
		DebugManager.log_warning("DrivingConfigManager: Unknown performance setting: " + setting)

func get_performance_settings() -> Dictionary:
	"""Get current performance settings"""
	return performance_settings.duplicate()

func apply_performance_optimizations():
	"""Apply performance optimizations based on settings"""
	# TODO Phase 2: Implement actual performance optimizations
	var fps_target = performance_settings.get("physics_fps", 60)
	Engine.physics_ticks_per_second = fps_target
	
	DebugManager.log_info("DrivingConfigManager: Applied performance optimizations")

# Integration with other systems
func register_with_scene_manager():
	"""Register driving scenes with SceneManager"""
	if not SceneManager:
		return
	
	# Register driving scene paths for navigation
	for track_id in track_configs:
		var track_config = track_configs[track_id]
		var scene_path = track_config.get("scene_path", "")
		
		if scene_path != "":
			# TODO: Register scene with SceneManager
			DebugManager.log_debug("DrivingConfigManager: Would register scene " + scene_path)

# Public API
func is_driving_mode_active() -> bool:
	"""Check if driving mode is currently active"""
	return driving_mode_active

func get_current_biome() -> String:
	"""Get current biome"""
	return current_biome

func get_vehicle_display_name(vehicle_id: String) -> String:
	"""Get display name for vehicle"""
	var config = get_vehicle_config(vehicle_id)
	return config.get("display_name", vehicle_id)

func get_track_display_name(track_id: String) -> String:
	"""Get display name for track"""
	var config = get_track_config(track_id)
	return config.get("display_name", track_id)

# Debug and validation
func validate_driving_system():
	"""Validate driving configuration system integrity"""
	DebugManager.log_info("=== DRIVING CONFIG VALIDATION ===")
	
	DebugManager.log_info("Driving mode active: " + str(driving_mode_active))
	DebugManager.log_info("Current biome: " + current_biome)
	DebugManager.log_info("Available vehicles: " + str(vehicle_configs.size()))
	DebugManager.log_info("Available tracks: " + str(track_configs.size()))
	DebugManager.log_info("Current vehicle: " + str(current_vehicle_config != null))
	DebugManager.log_info("Current track: " + str(current_track_config != null))
	
	# Validate configuration completeness
	for vehicle_id in vehicle_configs:
		var config = vehicle_configs[vehicle_id]
		if not config.has("max_speed") or not config.has("acceleration"):
			DebugManager.log_warning("Vehicle config incomplete: " + vehicle_id)
	
	for track_id in track_configs:
		var config = track_configs[track_id]
		if not config.has("scene_path") or not config.has("biome"):
			DebugManager.log_warning("Track config incomplete: " + track_id)
	
	DebugManager.log_info("=== DRIVING CONFIG VALIDATION COMPLETE ===")

# Development helpers
func test_vehicle_switching():
	"""Debug function to test vehicle switching"""
	var vehicles = get_available_vehicles()
	for vehicle_id in vehicles:
		load_vehicle_config(vehicle_id)
		DebugManager.log_info("DrivingConfigManager: Tested vehicle " + vehicle_id)

func force_driving_mode_toggle():
	"""Debug function to toggle driving mode"""
	if driving_mode_active:
		exit_driving_mode()
	else:
		enter_driving_mode()
	
	DebugManager.log_info("DrivingConfigManager: Toggled driving mode to " + str(driving_mode_active)) 
