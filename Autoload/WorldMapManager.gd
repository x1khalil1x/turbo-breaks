extends Node

## WorldMapManager - Phase 1 Implementation
## Zone discovery, metadata tracking, and world map state management
## Based on CARTOGRAPHY_RULES.md - Phase 1: Metadata Backbone

# Zone discovery states
enum DiscoveryState { HIDDEN, DISCOVERED, VISITED }

# Scene metadata tracking
var zone_metadata: Dictionary = {}  # scene_path -> SceneMapData resource
var zone_discovery_states: Dictionary = {}  # scene_path -> DiscoveryState
var current_zone_path: String = ""

# Discovery system
@export var discovery_radius: float = 32.0  # Distance for zone boundary detection
var discovered_zones: Array[String] = []
var visited_zones: Array[String] = []

# Integration with existing systems
signal zone_discovered(zone_path: String, discovery_method: String)
signal zone_visited(zone_path: String)
signal zone_metadata_updated(zone_path: String)

func _ready():
	print("WorldMapManager: Phase 1 initialized")
	
	# Connect to existing systems - wait for next frame to ensure autoloads are ready
	await get_tree().process_frame
	
	if SceneManager:
		# Note: SceneManager doesn't emit scene_changed signal in current implementation
		# Zone tracking will be handled through other means
		if DebugManager:
			DebugManager.log_info("WorldMapManager: SceneManager integration ready")
		else:
			print("WorldMapManager: SceneManager integration ready - no debug logging")
	else:
		print("WorldMapManager: SceneManager not available - scene integration disabled")
	
	# Initialize with MapManager's 3x3 grid
	if MapManager:
		initialize_map_zones()
		if DebugManager:
			DebugManager.log_info("WorldMapManager: Integrated with MapManager grid")
		else:
			print("WorldMapManager: Integrated with MapManager grid - no debug logging")
	else:
		print("WorldMapManager: MapManager not available - map integration disabled")

func initialize_map_zones():
	"""Initialize zone metadata for MapManager's 3x3 grid system"""
	# Load zone metadata resources (temporarily disabled until resources are created)
	# load_zone_metadata_resources()
	
	for grid_pos in MapManager.map_scenes:
		var scene_path = MapManager.map_scenes[grid_pos]
		
		# Set initial discovery state
		if grid_pos == Vector2(1, 1):  # Center - starting zone
			zone_discovery_states[scene_path] = DiscoveryState.VISITED
			visited_zones.append(scene_path)
			discovered_zones.append(scene_path)
		else:
			zone_discovery_states[scene_path] = DiscoveryState.HIDDEN
		
		DebugManager.log_debug("WorldMapManager: Initialized zone " + scene_path + " at " + str(grid_pos))

func load_zone_metadata_resources():
	"""Load SceneMapData resources for all zones"""
	# TODO: Create these resource files - temporarily disabled to prevent startup errors
	DebugManager.log_info("WorldMapManager: Zone metadata loading temporarily disabled until resources are created")
	return
	
	# var zone_resource_paths = {
	# 	"res://scenes/levels/outdoor/Center.tscn": "res://data/cartography/map_data/center.tres",
	# 	"res://scenes/levels/outdoor/North.tscn": "res://data/cartography/map_data/north.tres",
	# 	"res://scenes/levels/outdoor/South.tscn": "res://data/cartography/map_data/south.tres",
	# 	"res://scenes/levels/outdoor/East.tscn": "res://data/cartography/map_data/east.tres",
	# 	"res://scenes/levels/outdoor/West.tscn": "res://data/cartography/map_data/west.tres",
	# 	"res://scenes/levels/outdoor/NorthEast.tscn": "res://data/cartography/map_data/northeast.tres",
	# 	"res://scenes/levels/outdoor/NorthWest.tscn": "res://data/cartography/map_data/northwest.tres",
	# 	"res://scenes/levels/outdoor/SouthEast.tscn": "res://data/cartography/map_data/southeast.tres",
	# 	"res://scenes/levels/outdoor/SouthWest.tscn": "res://data/cartography/map_data/southwest.tres"
	# }
	
	# for scene_path in zone_resource_paths:
	# 	var resource_path = zone_resource_paths[scene_path]
	# 	var zone_data = load(resource_path) as SceneMapData
	# 	
	# 	if zone_data:
	# 		register_scene_metadata(scene_path, zone_data)
	# 	else:
	# 		DebugManager.log_warning("WorldMapManager: Failed to load zone data for " + scene_path)

func register_scene_metadata(scene_path: String, metadata_resource = null):
	"""Register zone metadata when SceneMapData resource is available"""
	if metadata_resource:
		zone_metadata[scene_path] = metadata_resource
		zone_metadata_updated.emit(scene_path)
		DebugManager.log_info("WorldMapManager: Registered metadata for " + scene_path)
	else:
		DebugManager.log_warning("WorldMapManager: No metadata provided for " + scene_path)

func discover_zone(zone_path: String, discovery_method: String = "proximity"):
	"""Discover a new zone and update state"""
	if zone_path in discovered_zones:
		return  # Already discovered
	
	if zone_path in zone_discovery_states:
		zone_discovery_states[zone_path] = DiscoveryState.DISCOVERED
		discovered_zones.append(zone_path)
		zone_discovered.emit(zone_path, discovery_method)
		
		DebugManager.log_info("WorldMapManager: Zone discovered - " + zone_path + " via " + discovery_method)

func visit_zone(zone_path: String):
	"""Mark zone as visited when player enters"""
	if not zone_path in visited_zones:
		visited_zones.append(zone_path)
		
		# Auto-discover if not already discovered
		if not zone_path in discovered_zones:
			discover_zone(zone_path, "direct_visit")
		
		zone_discovery_states[zone_path] = DiscoveryState.VISITED
		zone_visited.emit(zone_path)
		
		DebugManager.log_info("WorldMapManager: Zone visited - " + zone_path)

func _on_scene_changed(new_scene_path: String):
	"""Handle scene changes from SceneManager"""
	current_zone_path = new_scene_path
	visit_zone(new_scene_path)

# Zone boundary detection for discovery system
func check_zone_discovery_at_position(player_position: Vector2):
	"""Check if player is near zone boundaries for discovery"""
	var current_grid_pos = MapManager.get_current_position()
	
	# Check adjacent zones for discovery
	var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
	
	for direction in directions:
		var adjacent_pos = current_grid_pos + direction
		if adjacent_pos in MapManager.map_scenes:
			var adjacent_scene = MapManager.map_scenes[adjacent_pos]
			
			# Check if player is close to the edge that would reveal this zone
			if is_near_zone_boundary(player_position, direction) and not adjacent_scene in discovered_zones:
				discover_zone(adjacent_scene, "proximity")

func is_near_zone_boundary(player_pos: Vector2, direction: Vector2) -> bool:
	"""Check if player is within discovery radius of zone boundary"""
	var world_size = Vector2(1280, 720)  # Scene dimensions from DEVELOPMENT_RULES
	
	match direction:
		Vector2(0, -1):  # North
			return player_pos.y < discovery_radius
		Vector2(0, 1):   # South  
			return player_pos.y > world_size.y - discovery_radius
		Vector2(-1, 0):  # West
			return player_pos.x < discovery_radius
		Vector2(1, 0):   # East
			return player_pos.x > world_size.x - discovery_radius
		_:
			return false

# Public API for UI and other systems
func get_zone_discovery_state(zone_path: String) -> DiscoveryState:
	"""Get discovery state for a specific zone"""
	return zone_discovery_states.get(zone_path, DiscoveryState.HIDDEN)

func get_discovered_zones() -> Array[String]:
	"""Get list of all discovered zones"""
	return discovered_zones.duplicate()

func get_visited_zones() -> Array[String]:
	"""Get list of all visited zones"""
	return visited_zones.duplicate()

func can_fast_travel_to(target_zone: String) -> bool:
	"""Check if fast travel is available to target zone"""
	# Fast travel requires visited status and path accessibility
	return target_zone in visited_zones and is_zone_accessible(target_zone)

func is_zone_accessible(zone_path: String) -> bool:
	"""Check if zone is accessible via connected paths"""
	# For Phase 1: Simple adjacency check using MapManager
	# TODO Phase 2: Implement path validation with SceneMapData
	return zone_path in MapManager.map_scenes.values()

func get_current_zone_metadata():
	"""Get metadata for current zone"""
	if current_zone_path in zone_metadata:
		return zone_metadata[current_zone_path]
	return null

# Debug and validation functions
func validate_zone_system():
	"""Validate zone discovery system integrity"""
	DebugManager.log_info("=== WORLDMAP VALIDATION ===")
	
	DebugManager.log_info("Total zones tracked: " + str(zone_discovery_states.size()))
	DebugManager.log_info("Discovered zones: " + str(discovered_zones.size()))
	DebugManager.log_info("Visited zones: " + str(visited_zones.size()))
	DebugManager.log_info("Current zone: " + current_zone_path)
	
	# Validate data consistency
	for zone in discovered_zones:
		if not zone in zone_discovery_states:
			DebugManager.log_warning("Discovered zone missing from state tracking: " + zone)
	
	for zone in visited_zones:
		if not zone in discovered_zones:
			DebugManager.log_warning("Visited zone not marked as discovered: " + zone)
	
	DebugManager.log_info("=== WORLDMAP VALIDATION COMPLETE ===")

# Development helpers
func force_discover_all_zones():
	"""Debug function to discover all zones"""
	for scene_path in MapManager.map_scenes.values():
		discover_zone(scene_path, "debug_unlock")
	DebugManager.log_info("WorldMapManager: All zones force-discovered for testing") 