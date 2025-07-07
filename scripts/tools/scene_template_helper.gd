@tool
extends EditorScript
class_name SceneTemplateHelper

# Scene Template Helper - Rapid Scene Creation Tool
# Automates template duplication and initial setup

enum ZoneType {
	URBAN,
	NATURE, 
	HIGHWAY,
	CUSTOM
}

const TEMPLATE_PATHS = {
	ZoneType.URBAN: "res://scenes/levels/templates/UrbanZoneTemplate.tscn",
	ZoneType.NATURE: "res://scenes/levels/templates/NatureZoneTemplate.tscn", 
	ZoneType.HIGHWAY: "res://scenes/levels/templates/HighwayZoneTemplate.tscn"
}

const OUTPUT_DIR = "res://scenes/levels/outdoor/"

func _run():
	print("=== SCENE TEMPLATE HELPER ===")
	print("Available templates:")
	print("1. Urban Zone Template")
	print("2. Nature Zone Template") 
	print("3. Highway Zone Template")
	print("")
	print("Usage: Modify zone_name and zone_type variables below, then run script")
	
	# MODIFY THESE VARIABLES FOR YOUR NEW SCENE:
	var zone_name = "ExampleZone"  # Change this to your zone name
	var zone_type = ZoneType.URBAN  # Change this to appropriate type
	
	create_scene_from_template(zone_name, zone_type)

func create_scene_from_template(zone_name: String, zone_type: ZoneType):
	if zone_type == ZoneType.CUSTOM:
		print("❌ CUSTOM zone type requires manual template selection")
		return
		
	var template_path = TEMPLATE_PATHS[zone_type]
	var output_path = OUTPUT_DIR + zone_name + ".tscn"
	
	print("Creating scene: %s" % zone_name)
	print("Template: %s" % template_path)
	print("Output: %s" % output_path)
	
	# Load template scene
	var template_scene = load(template_path) as PackedScene
	if not template_scene:
		print("❌ FAILED: Could not load template scene")
		return
	
	# Instance and modify
	var scene_instance = template_scene.instantiate()
	scene_instance.name = zone_name
	
	# Create packed scene
	var new_packed_scene = PackedScene.new()
	new_packed_scene.pack(scene_instance)
	
	# Save to file
	var result = ResourceSaver.save(new_packed_scene, output_path)
	if result == OK:
		print("✅ SUCCESS: Scene created at %s" % output_path)
		print("Next steps:")
		print("1. Open scene in editor")
		print("2. Begin asset population")
		print("3. Configure doorway connections")
		print("4. Test player movement and transitions")
	else:
		print("❌ FAILED: Could not save scene file (Error: %d)" % result)
	
	# Cleanup
	scene_instance.queue_free()

func create_custom_template_info():
	print("\n=== CUSTOM TEMPLATE CREATION ===")
	print("To create custom templates:")
	print("1. Duplicate SceneTemplate.tscn")
	print("2. Modify TileMap layers for specific use case")
	print("3. Add appropriate interaction area nodes")
	print("4. Save in scenes/levels/templates/")
	print("5. Add to TEMPLATE_PATHS dictionary above")

# Helper function for batch scene creation
func create_full_3x3_grid(base_name: String = "Zone"):
	print("\n=== BATCH SCENE CREATION ===")
	var zone_names = [
		"NorthWest", "North", "NorthEast",
		"West", "Center", "East", 
		"SouthWest", "South", "SouthEast"
	]
	
	for zone in zone_names:
		var full_name = base_name + zone if base_name != "Zone" else zone
		create_scene_from_template(full_name, ZoneType.URBAN)  # Default to urban
		
	print("✅ Created complete 3x3 grid. Remember to:")
	print("- Customize each zone's template type")
	print("- Configure proper doorway connections")
	print("- Populate with appropriate biome assets") 