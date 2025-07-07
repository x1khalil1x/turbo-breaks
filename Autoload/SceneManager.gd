extends Node


# Removed unused signal - scene_changed

var current_scene: Node = null
var player_spawn_position: Vector2 = Vector2.ZERO

# Global transition cooldown system
var transition_cooldown: float = 0.0
const GLOBAL_TRANSITION_COOLDOWN: float = 1.5  # 1.5 seconds global cooldown

# Industry-standard fade transition system
var fade_overlay: ColorRect = null
var transition_in_progress: bool = false
const FADE_DURATION: float = 0.4

func _ready():
	print("SceneManager: Ready")
	# Get the current scene
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("SceneManager: Current scene:", str(current_scene.name) if current_scene else "none")
	
	# Create fade overlay for transitions
	setup_fade_overlay()

func setup_fade_overlay():
	"""Create global fade overlay for scene transitions"""
	fade_overlay = ColorRect.new()
	fade_overlay.name = "SceneTransitionFade"
	fade_overlay.color = Color.BLACK
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.modulate.a = 0.0
	
	# Make it cover the entire screen
	fade_overlay.anchors_preset = Control.PRESET_FULL_RECT
	fade_overlay.anchor_left = 0.0
	fade_overlay.anchor_top = 0.0
	fade_overlay.anchor_right = 1.0
	fade_overlay.anchor_bottom = 1.0
	
	# Add as highest z-index overlay
	var canvas = CanvasLayer.new()
	canvas.name = "SceneTransitionCanvas"
	canvas.layer = 100  # Very high layer to be on top
	
	# Use call_deferred to avoid "Parent node is busy setting up children" error
	canvas.call_deferred("add_child", fade_overlay)
	get_tree().root.call_deferred("add_child", canvas)
	
	# Wait for next frame to ensure setup is complete
	await get_tree().process_frame
	print("SceneManager: Fade overlay system initialized")

func _process(delta):
	if transition_cooldown > 0:
		transition_cooldown -= delta

func can_transition() -> bool:
	return transition_cooldown <= 0.0 and not transition_in_progress

func change_scene_to_file(path: String):
	if not can_transition():
		print("SceneManager: Transition blocked by global cooldown (", transition_cooldown, "s remaining)")
		return
		
	print("SceneManager: change_scene_to_file called with path:", path)
	# Start fade transition
	call_deferred("_start_fade_transition", path)
	transition_cooldown = GLOBAL_TRANSITION_COOLDOWN

# Generic method for changing to any scene
func change_scene(path: String):
	print("SceneManager: change_scene called with path:", path)
	change_scene_to_file(path)

func change_scene_with_position(path: String, spawn_position: Vector2 = Vector2.ZERO):
	if not can_transition():
		print("SceneManager: Transition with position blocked by global cooldown (", transition_cooldown, "s remaining)")
		return
		
	print("SceneManager: change_scene_with_position - ", path, " at ", spawn_position)
	player_spawn_position = spawn_position
	change_scene_to_file(path)

func _start_fade_transition(path: String):
	"""Start industry-standard fade-to-black transition"""
	if transition_in_progress:
		print("SceneManager: Transition already in progress - ignoring")
		return
	
	transition_in_progress = true
	print("SceneManager: Starting fade transition to ", path)
	
	# Clean up UI state before transition
	if UIStateManager:
		UIStateManager.prepare_for_scene_transition()
	
	# Disable player input during transition
	get_tree().paused = false  # Don't use tree pause, just disable input
	disable_player_input()
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished
	
	# Load new scene
	await _deferred_change_scene(path)
	
	# Fade from black
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(fade_overlay, "modulate:a", 0.0, FADE_DURATION)
	await fade_in_tween.finished
	
	# Re-enable input
	enable_player_input()
	transition_in_progress = false
	print("SceneManager: Fade transition completed")

func disable_player_input():
	"""Disable player input during transitions"""
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player.has_method("set_input_enabled"):
			player.set_input_enabled(false)
		else:
			player.process_mode = Node.PROCESS_MODE_DISABLED

func enable_player_input():
	"""Re-enable player input after transitions"""
	await get_tree().process_frame  # Wait one frame for scene to be ready
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player.has_method("set_input_enabled"):
			player.set_input_enabled(true)
		else:
			player.process_mode = Node.PROCESS_MODE_INHERIT

func _deferred_change_scene(path: String):
	print("SceneManager: Loading scene: ", path)
	
	# Free current scene
	if current_scene:
		current_scene.queue_free()
		await current_scene.tree_exited  # Wait for cleanup
	
	# Load new scene
	var new_scene = load(path)
	if not new_scene:
		print("SceneManager: ERROR - Failed to load scene: ", path)
		transition_in_progress = false
		return
	
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	# Position player if spawn position specified
	if player_spawn_position != Vector2.ZERO:
		call_deferred("position_player_in_new_scene")
	
	# Setup UI for the new scene
	call_deferred("setup_ui_for_scene", path)

func position_player_in_new_scene():
	await get_tree().process_frame  # Wait for scene to be fully ready
	
	var player = find_player_in_scene()
	if player:
		player.global_position = player_spawn_position
		print("SceneManager: Player positioned at: ", player_spawn_position)
		player_spawn_position = Vector2.ZERO
	else:
		print("SceneManager: WARNING - No player found in new scene!")

func find_player_in_scene() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func change_scene_to_lobby():
	print("SceneManager: change_scene_to_lobby called")
	change_scene_to_file("res://scenes/levels/lobby/Lobby.tscn")

func change_scene_to_drive_mode():
	print("SceneManager: change_scene_to_drive_mode called")
	change_scene_to_file("res://scenes/levels/drive_mode/DriveMode.tscn") 

func change_scene_to_intro():
	print("SceneManager: change_scene_to_intro called")
	change_scene_to_file("res://scenes/intro/Intro.tscn") 

func change_scene_to_overworld():
	print("SceneManager: change_scene_to_overworld called")
	change_scene_to_file("res://scenes/overworld/OverworldTemplate.tscn")

func setup_ui_for_scene(scene_path: String):
	"""Configure UI state based on the scene that was loaded"""
	await get_tree().process_frame  # Wait for scene to be ready
	
	if not UIStateManager:
		return
	
	# Determine scene type from path
	var scene_type = "exploration"  # default
	
	if "lobby" in scene_path.to_lower() or "menu" in scene_path.to_lower():
		scene_type = "lobby"
	elif "drive" in scene_path.to_lower() or "racing" in scene_path.to_lower():
		scene_type = "driving"  
	elif "indoor" in scene_path.to_lower() or "building" in scene_path.to_lower():
		scene_type = "indoor"
	else:
		scene_type = "exploration"
	
	UIStateManager.setup_ui_for_scene(scene_type)
	print("SceneManager: UI configured for scene type: ", scene_type)
