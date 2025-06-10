# Tile Standards for Different Perspectives
# Use this class to maintain consistency across all tileset development
class_name TileStandards

# Recommended tile sizes per perspective
const TOP_DOWN_TILE_SIZE = Vector2i(32, 32)    # Good for detail and readability  
const SIDE_VIEW_TILE_SIZE = Vector2i(16, 16)   # Allows for finer platforming
const ISOMETRIC_TILE_SIZE = Vector2i(64, 32)   # Standard diamond ratio

# Alternative tile sizes for different use cases
const TOP_DOWN_LARGE = Vector2i(48, 48)        # For less detailed, faster development
const SIDE_VIEW_LARGE = Vector2i(24, 24)       # For bigger characters/objects
const ISOMETRIC_SMALL = Vector2i(32, 16)       # For mobile or pixel-dense screens

# Color palette constraints
const SHARED_PALETTE_SIZE = 16          # Core colors used across all perspectives
const PERSPECTIVE_VARIANT_COLORS = 4    # Additional colors per perspective
const MAX_TOTAL_COLORS = 32             # Hard limit for consistency

# Performance guidelines
const MAX_TILESET_TEXTURE_SIZE = 2048   # Stay under this for mobile compatibility
const RECOMMENDED_ATLAS_SIZE = 1024     # Sweet spot for most devices
const MAX_TILES_PER_TILESET = 256       # Practical limit for organization

# Collision layer bit assignments
const COLLISION_SOLID = 1               # Walls, floors, impassable terrain
const COLLISION_PLATFORM = 2            # One-way platforms (side-view only)
const COLLISION_TRIGGER = 4             # Event triggers, pickups
const COLLISION_DECORATION = 8          # Background elements (no collision)

# Standard Z-Index assignments
const Z_BACKGROUND = -20
const Z_GROUND = -10
const Z_OBJECTS = 0
const Z_WALLS = 10
const Z_COLLISION_DEBUG = 20
const Z_UI_OVERLAY = 30

# Helper functions for consistent development

static func get_perspective_tile_size(perspective: String) -> Vector2i:
	"""Get the recommended tile size for a given perspective"""
	match perspective.to_lower():
		"topdown", "top_down", "top-down":
			return TOP_DOWN_TILE_SIZE
		"sideview", "side_view", "side-view", "platformer":
			return SIDE_VIEW_TILE_SIZE
		"isometric", "iso", "2.5d":
			return ISOMETRIC_TILE_SIZE
		_:
			push_warning("Unknown perspective: " + perspective + ". Using top-down default.")
			return TOP_DOWN_TILE_SIZE

static func calculate_tileset_dimensions(tile_count: int, tiles_per_row: int, tile_size: Vector2i) -> Vector2i:
	"""Calculate the total texture size needed for a tileset"""
	var rows = ceil(float(tile_count) / float(tiles_per_row))
	return Vector2i(tiles_per_row * tile_size.x, int(rows) * tile_size.y)

static func validate_tileset_size(texture_size: Vector2i) -> bool:
	"""Check if a tileset texture size is within recommended limits"""
	return texture_size.x <= MAX_TILESET_TEXTURE_SIZE and texture_size.y <= MAX_TILESET_TEXTURE_SIZE

static func get_collision_layer_name(layer_bit: int) -> String:
	"""Get human-readable name for collision layer"""
	match layer_bit:
		COLLISION_SOLID:
			return "Solid"
		COLLISION_PLATFORM:
			return "Platform"
		COLLISION_TRIGGER:
			return "Trigger"
		COLLISION_DECORATION:
			return "Decoration"
		_:
			return "Custom_" + str(layer_bit)

static func setup_tilemap_layers(tilemap: TileMap, perspective: String) -> void:
	"""Automatically configure tilemap layers for a given perspective"""
	if not tilemap:
		push_error("Invalid tilemap provided")
		return
	
	match perspective.to_lower():
		"topdown", "top_down", "top-down":
			setup_topdown_layers(tilemap)
		"sideview", "side_view", "side-view":
			setup_sideview_layers(tilemap)
		"isometric", "iso":
			setup_isometric_layers(tilemap)

static func setup_topdown_layers(tilemap: TileMap) -> void:
	"""Configure layers optimized for top-down perspective"""
	# This would configure the tilemap programmatically
	# Implementation depends on your specific needs
	pass

static func setup_sideview_layers(tilemap: TileMap) -> void:
	"""Configure layers optimized for side-view platformers"""
	pass

static func setup_isometric_layers(tilemap: TileMap) -> void:
	"""Configure layers optimized for isometric perspective"""
	pass

# Color palette helpers
static func create_base_palette() -> Array:
	"""Generate a recommended base color palette"""
	return [
		Color.WHITE,        # Pure white for highlights
		Color.BLACK,        # Pure black for outlines
		Color.GRAY,         # Mid-tone gray
		Color.DARK_GRAY,    # Dark gray for shadows
		Color.BROWN,        # Earth tones
		Color.GREEN,        # Vegetation
		Color.BLUE,         # Water/sky
		Color.RED,          # Danger/fire
		Color.YELLOW,       # Light/energy
		Color.PURPLE,       # Magic/special
		# Add 6 more colors based on your game's needs
	]

# Debug and testing helpers
static func create_debug_tileset(tile_size: Vector2i) -> TileSet:
	"""Create a simple colored tileset for testing purposes"""
	var tileset = TileSet.new()
	# Implementation would create a basic test tileset
	return tileset

static func log_tileset_info(tileset: TileSet, name: String = "") -> void:
	"""Print useful information about a tileset for debugging"""
	if not tileset:
		print("TileSet is null")
		return
	
	print("=== TileSet Info: " + name + " ===")
	print("Source count: ", tileset.get_source_count())
	# Add more diagnostic information as needed 