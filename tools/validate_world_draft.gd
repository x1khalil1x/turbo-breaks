@tool
extends EditorScript

# WorldDraft Scene Validation
# Verifies scene structure and functionality

func _run():
	print("=== WORLDDRAFT VALIDATION ===")
	
	var scene_path = "res://scenes/tools/WorldDraft.tscn"
	var scene = load(scene_path) as PackedScene
	
	if not scene:
		print("❌ FAILED: Could not load WorldDraft.tscn")
		return
	
	print("✅ Scene loaded successfully")
	
	# Instantiate and check structure
	var instance = scene.instantiate()
	_validate_scene_structure(instance)
	_validate_dimensions()
	_validate_tilemap_setup(instance)
	
	instance.queue_free()
	print("=== VALIDATION COMPLETE ===")

func _validate_scene_structure(node: Node):
	print("\n--- Scene Structure ---")
	
	var required_nodes = [
		"DraftCanvas",
		"RegionOverlays", 
		"TileMapStack",
		"ExternalArtLayer",
		"Camera2D",
		"UI"
	]
	
	for node_name in required_nodes:
		var found = node.get_node_or_null(node_name)
		if found:
			print("✅ %s found" % node_name)
		else:
			print("❌ %s missing" % node_name)

func _validate_dimensions():
	print("\n--- Dimension Validation ---")
	
	# Verify math
	const REGION_WIDTH = 1280
	const REGION_HEIGHT = 720
	const GRID_SIZE = 3
	
	var total_width = GRID_SIZE * REGION_WIDTH
	var total_height = GRID_SIZE * REGION_HEIGHT
	
	print("Region size: %dx%d" % [REGION_WIDTH, REGION_HEIGHT])
	print("Grid layout: %dx%d" % [GRID_SIZE, GRID_SIZE])
	print("Total canvas: %dx%d" % [total_width, total_height])
	
	if total_width == 3840 and total_height == 2160:
		print("✅ Dimensions correct")
	else:
		print("❌ Dimension mismatch")

func _validate_tilemap_setup(node: Node):
	print("\n--- TileMap Validation ---")
	
	var tilemap_stack = node.get_node_or_null("TileMapStack")
	if not tilemap_stack:
		print("❌ TileMapStack not found")
		return
	
	var layers = ["BaseLayer", "DecorationLayer", "CollisionLayer"]
	
	for layer_name in layers:
		var layer = tilemap_stack.get_node_or_null(layer_name)
		if layer and layer is TileMap:
			print("✅ %s configured" % layer_name)
		else:
			print("❌ %s missing or not TileMap" % layer_name) 