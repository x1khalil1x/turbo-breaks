extends Node

## IndustrialSceneManager - Industry-Standard Scene Management
## Non-destructive implementation that works alongside existing SceneManager
## Handles UI lifecycle, resource pooling, and dependency injection properly

signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_completed(scene_name: String)
signal scene_ui_ready(scene_name: String)

# Core state management
var current_scene_ref: WeakRef
var scene_ui_pool: Dictionary = {}  # scene_type -> UI instance pool
var transition_in_progress: bool = false
var last_transition_time: float = 0.0

# Configuration
const MIN_TRANSITION_DELAY: float = 0.5
const UI_POOL_SIZE: int = 3
const SUPPORTED_SCENE_TYPES: Array[String] = ["outdoor", "indoor", "menu", "drive"]

# Dependency tracking
var ui_manager_ready: bool = false
var theme_manager_ready: bool = false

func _ready():
	print("IndustrialSceneManager: Initializing...")
	
	# Wait for next frame to ensure other autoloads are ready
	await get_tree().process_frame
	
	# Initialize dependency tracking
	await initialize_dependencies()
	
	# Pre-warm UI pools
	await initialize_ui_pools()
	
	# Connect to existing systems
	connect_to_existing_systems()
	
	print("IndustrialSceneManager: Ready - Industry-standard scene management online")

func initialize_dependencies() -> void:
	"""Initialize and validate dependencies with graceful fallbacks"""
	
	# Check UIThemeManager
	if UIThemeManager:
		theme_manager_ready = true
		print("IndustrialSceneManager: UIThemeManager integration enabled")
		
		# Connect to theme changes
		if UIThemeManager.has_signal("theme_changed"):
			UIThemeManager.theme_changed.connect(_on_theme_changed)
	else:
		print("IndustrialSceneManager: UIThemeManager not available - using fallback themes")
	
	# Initialize UI management
	ui_manager_ready = true
	print("IndustrialSceneManager: UI management system ready")

func initialize_ui_pools() -> void:
	"""Pre-create UI instances for different scene types"""
	print("IndustrialSceneManager: Initializing UI pools...")
	
	var ui_scene_path = "res://scenes/UI/GameUI.tscn"
	if not FileAccess.file_exists(ui_scene_path):
		print("IndustrialSceneManager: GameUI scene not found - UI pooling disabled")
		return
	
	var ui_scene = load(ui_scene_path)
	if not ui_scene:
		print("IndustrialSceneManager: Failed to load GameUI scene")
		return
	
	# Create UI pools for each supported scene type
	for scene_type in SUPPORTED_SCENE_TYPES:
		scene_ui_pool[scene_type] = []
		
		# Pre-create UI instances (kept inactive until needed)
		for i in range(UI_POOL_SIZE):
			var ui_instance = ui_scene.instantiate()
			ui_instance.name = "PooledUI_" + scene_type + "_" + str(i)
			ui_instance.visible = false
			ui_instance.process_mode = Node.PROCESS_MODE_DISABLED
			
			# Add to a pooling container, not to scene tree yet
			scene_ui_pool[scene_type].append(ui_instance)
		
		print("IndustrialSceneManager: Created UI pool for ", scene_type, " (", UI_POOL_SIZE, " instances)")

func connect_to_existing_systems() -> void:
	"""Connect to existing SceneManager and other systems"""
	if SceneManager:
		print("IndustrialSceneManager: Integrated with existing SceneManager")
		# Don't override SceneManager, work alongside it
	else:
		print("IndustrialSceneManager: No existing SceneManager found")

# PUBLIC API - Industry-standard scene management
func transition_scene_safe(target_scene: String, spawn_position: Vector2 = Vector2.ZERO, scene_type: String = "outdoor") -> bool:
	"""Safe scene transition with proper UI lifecycle management"""
	
	# Respect transition cooldown
	var current_time = Time.get_time_dict_from_system()
	var time_since_last = (current_time.hour * 3600 + current_time.minute * 60 + current_time.second) - last_transition_time
	
	if transition_in_progress:
		print("IndustrialSceneManager: Transition already in progress - ignoring request")
		return false
	
	if time_since_last < MIN_TRANSITION_DELAY:
		print("IndustrialSceneManager: Transition too soon - enforcing cooldown")
		return false
	
	print("IndustrialSceneManager: Starting safe transition to ", target_scene)
	transition_in_progress = true
	
	# Get current scene info
	var current_scene = get_tree().current_scene
	var from_scene_name = current_scene.name if current_scene else "unknown"
	
	# Emit transition start signal
	scene_transition_started.emit(from_scene_name, target_scene.get_file().get_basename())
	
	# Perform transition
	await _perform_safe_transition(target_scene, spawn_position, scene_type)
	
	# Update state
	transition_in_progress = false
	last_transition_time = current_time.hour * 3600 + current_time.minute * 60 + current_time.second
	
	print("IndustrialSceneManager: Transition completed successfully")
	return true

func _perform_safe_transition(target_scene: String, spawn_position: Vector2, scene_type: String) -> void:
	"""Perform the actual scene transition with proper resource management"""
	
	# 1. Prepare UI for new scene
	var ui_instance = acquire_ui_for_scene(scene_type)
	
	# 2. Load target scene
	var scene_resource = load(target_scene)
	if not scene_resource:
		print("IndustrialSceneManager: ERROR - Failed to load scene: ", target_scene)
		transition_in_progress = false
		return
	
	# 3. Clean up current scene UI properly
	cleanup_current_scene_ui()
	
	# 4. Instantiate new scene
	var new_scene = scene_resource.instantiate()
	
	# 5. Remove UI from scene (we'll manage it centrally)
	remove_embedded_ui_from_scene(new_scene)
	
	# 6. Perform scene switch using existing SceneManager
	if SceneManager:
		SceneManager.change_scene_with_position(target_scene, spawn_position)
	else:
		# Fallback direct implementation
		_direct_scene_switch(new_scene, spawn_position)
	
	# 7. Attach managed UI
	await get_tree().process_frame
	attach_ui_to_scene(ui_instance, scene_type)
	
	# 8. Emit completion signal
	scene_transition_completed.emit(target_scene.get_file().get_basename())

func acquire_ui_for_scene(scene_type: String) -> Node:
	"""Get a UI instance for the scene type from the pool"""
	if scene_type not in scene_ui_pool or scene_ui_pool[scene_type].is_empty():
		print("IndustrialSceneManager: No UI available for scene type ", scene_type, " - creating new instance")
		return create_emergency_ui_instance()
	
	var ui_instance = scene_ui_pool[scene_type].pop_back()
	print("IndustrialSceneManager: Acquired pooled UI for scene type ", scene_type)
	return ui_instance

func return_ui_to_pool(ui_instance: Node, scene_type: String) -> void:
	"""Return a UI instance to the pool for reuse"""
	if scene_type in scene_ui_pool and scene_ui_pool[scene_type].size() < UI_POOL_SIZE:
		# Clean up the UI instance
		ui_instance.visible = false
		ui_instance.process_mode = Node.PROCESS_MODE_DISABLED
		
		# Reset UI state
		if ui_instance.has_method("reset_ui_state"):
			ui_instance.reset_ui_state()
		
		# Return to pool
		scene_ui_pool[scene_type].append(ui_instance)
		print("IndustrialSceneManager: Returned UI to ", scene_type, " pool")
	else:
		# Pool full or invalid type - dispose of instance
		ui_instance.queue_free()
		print("IndustrialSceneManager: Disposed of excess UI instance")

func cleanup_current_scene_ui() -> void:
	"""Safely clean up UI from the current scene"""
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
	
	# Find and remove any embedded UI
	var ui_nodes = []
	find_ui_nodes_recursive(current_scene, ui_nodes)
	
	for ui_node in ui_nodes:
		if ui_node.name.begins_with("GameUi") or ui_node.name.begins_with("PooledUI"):
			# Determine scene type
			var scene_type = determine_scene_type(current_scene)
			
			# Return to pool or dispose
			return_ui_to_pool(ui_node, scene_type)
			
			# Remove from scene tree
			if ui_node.get_parent():
				ui_node.get_parent().remove_child(ui_node)

func remove_embedded_ui_from_scene(scene: Node) -> void:
	"""Remove embedded UI nodes from a scene to prevent conflicts"""
	var ui_nodes = []
	find_ui_nodes_recursive(scene, ui_nodes)
	
	for ui_node in ui_nodes:
		if ui_node.name.begins_with("GameUi"):
			print("IndustrialSceneManager: Removing embedded UI from scene: ", ui_node.name)
			ui_node.queue_free()

func attach_ui_to_scene(ui_instance: Node, scene_type: String) -> void:
	"""Attach a managed UI instance to the current scene"""
	var current_scene = get_tree().current_scene
	if not current_scene:
		print("IndustrialSceneManager: No current scene to attach UI to")
		return
	
	# Find or create UI container
	var ui_container = current_scene.get_node_or_null("UI")
	if not ui_container:
		ui_container = CanvasLayer.new()
		ui_container.name = "UI"
		current_scene.add_child(ui_container)
	
	# Attach UI instance
	ui_container.add_child(ui_instance)
	ui_instance.visible = true
	ui_instance.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Initialize UI for this scene
	if ui_instance.has_method("initialize_for_scene"):
		ui_instance.initialize_for_scene(scene_type)
	
	# Apply theme if available
	apply_theme_to_ui(ui_instance)
	
	scene_ui_ready.emit(current_scene.name)
	print("IndustrialSceneManager: UI attached and ready for scene type ", scene_type)

# UTILITY FUNCTIONS
func determine_scene_type(scene: Node) -> String:
	"""Determine the type of a scene node"""
	if scene.has_method("get") and "scene_type" in scene:
		return scene.scene_type
	
	# Fallback to name-based detection
	var scene_name = scene.name.to_lower()
	if "outdoor" in scene_name:
		return "outdoor"
	elif "indoor" in scene_name or "building" in scene_name:
		return "indoor"
	elif "drive" in scene_name:
		return "drive"
	else:
		return "outdoor"  # Default

func find_ui_nodes_recursive(node: Node, ui_nodes: Array) -> void:
	"""Find UI-related nodes recursively"""
	if node.name.begins_with("GameUi") or node.name.begins_with("PooledUI") or (node is CanvasLayer and node.name == "UI"):
		ui_nodes.append(node)
	
	for child in node.get_children():
		find_ui_nodes_recursive(child, ui_nodes)

func create_emergency_ui_instance() -> Node:
	"""Create an emergency UI instance when pool is empty"""
	var ui_scene_path = "res://scenes/UI/GameUI.tscn"
	var ui_scene = load(ui_scene_path)
	
	if ui_scene:
		var ui_instance = ui_scene.instantiate()
		ui_instance.name = "EmergencyUI_" + str(Time.get_ticks_msec())
		print("IndustrialSceneManager: Created emergency UI instance")
		return ui_instance
	
	print("IndustrialSceneManager: Failed to create emergency UI")
	return null

func _direct_scene_switch(new_scene: Node, spawn_position: Vector2) -> void:
	"""Direct scene switch implementation when SceneManager isn't available"""
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	# Position player if spawn position specified
	if spawn_position != Vector2.ZERO:
		call_deferred("_position_player_direct", spawn_position)

func _position_player_direct(spawn_position: Vector2) -> void:
	"""Position player in new scene (direct implementation)"""
	await get_tree().process_frame
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].global_position = spawn_position
		print("IndustrialSceneManager: Player positioned at ", spawn_position)

func apply_theme_to_ui(ui_instance: Node) -> void:
	"""Apply current theme to UI instance"""
	if not theme_manager_ready or not UIThemeManager:
		return
	
	if UIThemeManager.has_method("apply_theme_to_component"):
		UIThemeManager.apply_theme_to_component(ui_instance)
	elif ui_instance.has_method("apply_current_theme"):
		ui_instance.apply_current_theme()

# EVENT HANDLERS
func _on_theme_changed() -> void:
	"""Handle theme changes across all active UI instances"""
	print("IndustrialSceneManager: Theme changed - updating all UI instances")
	
	# Update current scene UI
	var current_scene = get_tree().current_scene
	if current_scene:
		var ui_container = current_scene.get_node_or_null("UI")
		if ui_container:
			for ui_child in ui_container.get_children():
				apply_theme_to_ui(ui_child)

# DEBUG AND TESTING SUPPORT
func get_ui_pool_status() -> Dictionary:
	"""Get status of UI pools for debugging"""
	var status = {}
	for scene_type in scene_ui_pool:
		status[scene_type] = scene_ui_pool[scene_type].size()
	return status

func force_ui_pool_cleanup() -> void:
	"""Force cleanup of all UI pools (for testing)"""
	print("IndustrialSceneManager: Force cleaning UI pools")
	for scene_type in scene_ui_pool:
		for ui_instance in scene_ui_pool[scene_type]:
			ui_instance.queue_free()
		scene_ui_pool[scene_type].clear() 