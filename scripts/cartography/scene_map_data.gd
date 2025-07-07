@tool
class_name SceneMapData extends Resource

## SceneMapData - Zone Metadata Resource
## Defines exploration zone properties for cartography and discovery systems
## Based on CARTOGRAPHY_RULES.md Phase 1 - Metadata Backbone

# Core zone identification
@export var zone_id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""

# Geographic and visual properties
@export var map_position: Vector2 = Vector2.ZERO
@export var biome_theme: String = "urban"
@export var thumbnail_path: String = ""

# Discovery and navigation
@export var discovery_radius: float = 32.0
@export var is_hub_location: bool = false
@export var connected_zones: Array[String] = []
@export var requires_story_progress: bool = false

# Gameplay properties
@export var has_indoor_areas: bool = false
@export var has_doorways: bool = false
@export var recommended_level: int = 1

# Audio and atmosphere
@export var ambient_music: String = ""
@export var exploration_music: String = ""

# Development and debugging
@export var zone_description: String = ""
@export var development_notes: String = ""

func _init():
	"""Initialize with safe defaults"""
	# Set default values to prevent null reference errors
	if zone_id == "":
		zone_id = "unknown_zone"
	if display_name == "":
		display_name = zone_id.capitalize().replace("_", " ")

# Validation functions
func is_valid() -> bool:
	"""Check if zone data is properly configured"""
	if zone_id == "" or zone_id == "unknown_zone":
		return false
	if scene_path == "":
		return false
	if display_name == "":
		return false
	return true

func get_validation_errors() -> Array[String]:
	"""Get list of configuration issues"""
	var errors: Array[String] = []
	
	if zone_id == "" or zone_id == "unknown_zone":
		errors.append("Zone ID not set or using default")
	
	if scene_path == "":
		errors.append("Scene path not specified")
	elif not FileAccess.file_exists(scene_path):
		errors.append("Scene file doesn't exist: " + scene_path)
	
	if display_name == "":
		errors.append("Display name not set")
	
	if map_position == Vector2.ZERO:
		errors.append("Map position not configured")
	
	# Validate connected zones exist (basic check)
	for connected_zone in connected_zones:
		if connected_zone == zone_id:
			errors.append("Zone cannot connect to itself")
	
	return errors

# Helper functions for WorldMapManager integration
func can_be_discovered() -> bool:
	"""Check if zone can be discovered based on requirements"""
	# For Phase 1: Simple check, can be expanded for story requirements
	return not requires_story_progress

func get_discovery_method() -> String:
	"""Get primary discovery method for this zone"""
	if is_hub_location:
		return "hub_connection"
	elif requires_story_progress:
		return "story_unlock"
	else:
		return "proximity"

func is_connected_to(other_zone_id: String) -> bool:
	"""Check if this zone connects to another zone"""
	return other_zone_id in connected_zones

func get_theme_music() -> String:
	"""Get appropriate music for zone context"""
	# Prefer exploration music, fall back to ambient
	if exploration_music != "":
		return exploration_music
	return ambient_music

# Development helpers
func get_debug_info() -> Dictionary:
	"""Get comprehensive debug information"""
	return {
		"zone_id": zone_id,
		"display_name": display_name,
		"scene_path": scene_path,
		"map_position": map_position,
		"biome_theme": biome_theme,
		"is_hub": is_hub_location,
		"connected_count": connected_zones.size(),
		"connected_zones": connected_zones,
		"discovery_radius": discovery_radius,
		"requires_story": requires_story_progress,
		"has_indoor": has_indoor_areas,
		"has_doorways": has_doorways,
		"validation_valid": is_valid(),
		"validation_errors": get_validation_errors()
	}

# Static helper functions for resource creation
static func create_zone_data(p_zone_id: String, p_scene_path: String, p_display_name: String = "") -> SceneMapData:
	"""Create a new zone data resource with basic configuration"""
	var zone_data = SceneMapData.new()
	zone_data.zone_id = p_zone_id
	zone_data.scene_path = p_scene_path
	zone_data.display_name = p_display_name if p_display_name != "" else p_zone_id.capitalize().replace("_", " ")
	return zone_data

static func create_hub_zone(p_zone_id: String, p_scene_path: String, p_connected_zones: Array[String]) -> SceneMapData:
	"""Create a hub zone with multiple connections"""
	var zone_data = create_zone_data(p_zone_id, p_scene_path)
	zone_data.is_hub_location = true
	zone_data.connected_zones = p_connected_zones
	zone_data.discovery_radius = 64.0  # Larger radius for hub zones
	return zone_data 