extends Control

# References to UI elements - updated for Control-based structure
@onready var background = $Background
@onready var center_container = $CenterContainer
@onready var title_container = $CenterContainer/MainContainer/TitleContainer
@onready var button_container = $CenterContainer/MainContainer/ButtonContainer
@onready var title_label = $CenterContainer/MainContainer/TitleContainer/TitleLabel
@onready var subtitle_label = $CenterContainer/MainContainer/TitleContainer/SubtitleLabel

# Animation state
enum MenuState { SHADER_INTRO, TITLE_FADE, MENU_READY }
var current_state = MenuState.SHADER_INTRO
var intro_timer: float = 0.0
var intro_duration: float = 3.0  # 3 seconds before title appears

func _ready():
	# Enhanced logging with DebugManager (fallback to print if not available)
	if DebugManager:
		DebugManager.log_info("Lobby: _ready() started")
	else:
		print("Lobby: _ready() started")
		
	setup_initial_state()
	apply_fonts()
	fix_input_blocking()  # Fix mouse filter issues
	apply_theme_safe()
	setup_theme_change_listener()
	start_intro_sequence()

func setup_initial_state():
	# DEBUG: Check for subtitle label specifically
	if subtitle_label:
		if DebugManager:
			DebugManager.log_info("Lobby: Subtitle label found: '" + subtitle_label.text + "'")
		else:
			print("Lobby: Subtitle label found: '" + subtitle_label.text + "'")
	else:
		if DebugManager:
			DebugManager.log_error("Lobby: Subtitle label NOT FOUND!")
		else:
			print("ERROR: Lobby: Subtitle label NOT FOUND!")
	
	# TEMPORARY: Show UI immediately for debugging - skip intro
	if DebugManager and DebugManager.debug_enabled:
		# Skip intro in debug mode - show everything immediately
		title_container.modulate.a = 1.0
		button_container.modulate.a = 1.0
		current_state = MenuState.MENU_READY
		
		if DebugManager:
			DebugManager.log_info("Lobby: DEBUG MODE - Skipping intro animation")
		else:
			print("Lobby: DEBUG MODE - Skipping intro animation")
	else:
		# Hide UI elements initially for normal intro
		title_container.modulate.a = 0.0
		button_container.modulate.a = 0.0
	
	# Set music to menu mode
	if has_node("/root/MusicPlayer"):
		MusicPlayer.set_volume_mode(MusicPlayer.VolumeMode.MENU)

func start_intro_sequence():
	if DebugManager:
		DebugManager.log_info("Lobby: Starting intro sequence")
	else:
		print("Lobby: Starting intro sequence")
		
	current_state = MenuState.SHADER_INTRO
	intro_timer = 0.0
	
	# Start lobby music
	if has_node("/root/MusicPlayer"):
		MusicPlayer.play_track("lobby_music")

func _process(delta):
	match current_state:
		MenuState.SHADER_INTRO:
			handle_shader_intro(delta)
		MenuState.TITLE_FADE:
			pass  # Handled by tween
		MenuState.MENU_READY:
			pass  # Ready for interaction

func handle_shader_intro(delta):
	intro_timer += delta
	
	if intro_timer >= intro_duration:
		start_title_fade()

func start_title_fade():
	if DebugManager:
		DebugManager.log_info("Lobby: Starting title fade")
	else:
		print("Lobby: Starting title fade")
		
	current_state = MenuState.TITLE_FADE
	
	# Fade in title
	var tween = create_tween()
	tween.tween_property(title_container, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	show_menu_buttons()

func show_menu_buttons():
	if DebugManager:
		DebugManager.log_info("Lobby: Showing menu buttons")
	else:
		print("Lobby: Showing menu buttons")
		
	current_state = MenuState.MENU_READY
	
	# Fade in buttons
	var tween = create_tween()
	tween.tween_property(button_container, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)

# Button handlers (same as your original)
func _on_drive_button_pressed():
	if DebugManager:
		DebugManager.log_info("🎯 LOBBY: DRIVE BUTTON PRESSED SUCCESSFULLY! 🎯")
		DebugManager.log_info("Button press handler called at: " + str(Time.get_time_string_from_system()))
	else:
		print("🎯 LOBBY: DRIVE BUTTON PRESSED SUCCESSFULLY! 🎯")
		print("Button press handler called at: " + str(Time.get_time_string_from_system()))
	
	# Add a visible feedback to confirm button works
	var drive_button = $CenterContainer/MainContainer/ButtonContainer/DriveButton
	if drive_button:
		drive_button.text = "CLICKED! ✅"
		drive_button.modulate = Color.GREEN
		
		# Wait a moment then proceed
		await get_tree().create_timer(0.5).timeout
		
	fade_out_and_transition("menu")

func _on_explore_button_pressed():
	if DebugManager:
		DebugManager.log_info("Lobby: Explore button pressed")
	else:
		print("Lobby: Explore button pressed")
		
	fade_out_and_transition("explore")

func _on_exit_button_pressed():
	if DebugManager:
		DebugManager.log_info("Lobby: Exit button pressed")
	else:
		print("Lobby: Exit button pressed")
		
	get_tree().quit()

func fade_out_and_transition(destination: String):
	# Fade out elements
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_container, "modulate:a", 0.0, 0.4)
	tween.tween_property(button_container, "modulate:a", 0.0, 0.4)
	
	# FIXED: Use background instead of shader_background
	if background and background.material:
		tween.tween_property(background.material, "shader_parameter/fade_alpha", 0.0, 0.4)
	
	await tween.finished
	
	# Transition to destination
	match destination:
		"menu":
			SceneManager.change_scene("res://scenes/CharacterSelect.tscn")
		"drive":
			SceneManager.change_scene("res://scenes/DriveMode.tscn")
		"explore":
			SceneManager.change_scene("res://scenes/levels/outdoor/OutdoorScene.tscn") 

func apply_fonts():
	# ONLY apply fonts to labels - ignore buttons completely
	if FontManager:
		FontManager.make_title_text(title_label, "TURBO BREAKS", 48)
		# FIX: Use same font type as title for subtitle - RussoOne works!
		FontManager.make_title_text(subtitle_label, "Main Menu", 24)
		
		if DebugManager:
			DebugManager.log_info("FontManager applied to labels only - using title font for both")
		else:
			print("FontManager applied to labels only - using title font for both")
	else:
		# Fallback: Apply basic styling if FontManager not available
		if title_label:
			title_label.add_theme_font_size_override("font_size", 48)
			title_label.add_theme_color_override("font_color", Color.WHITE)
		
		if subtitle_label:
			subtitle_label.add_theme_font_size_override("font_size", 24)
			subtitle_label.add_theme_color_override("font_color", Color.WHITE)
			
		if DebugManager:
			DebugManager.log_info("Lobby: Applied fallback font styling")
		else:
			print("Lobby: Applied fallback font styling")
	
	# DO NOT touch buttons - let them keep their default text

# DEBUG: Manual input handling for troubleshooting
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				# Skip intro immediately
				skip_to_menu()
			KEY_F1:
				# Force show subtitle debug info
				debug_subtitle_visibility()
			KEY_F2:
				# Debug button properties
				debug_button_clickability()
			KEY_F3:
				# Manually fix input blocking
				fix_input_blocking()


func skip_to_menu():
	"""Skip intro animation and go straight to menu"""
	if DebugManager:
		DebugManager.log_info("Lobby: Manually skipping to menu")
	else:
		print("Lobby: Manually skipping to menu")
	
	current_state = MenuState.MENU_READY
	title_container.modulate.a = 1.0
	button_container.modulate.a = 1.0

func debug_subtitle_visibility():
	"""Debug subtitle label visibility and properties"""
	if DebugManager:
		DebugManager.log_info("=== SUBTITLE DETAILED DEBUG ===")
		DebugManager.log_info("Subtitle exists: " + str(subtitle_label != null))
		if subtitle_label:
			DebugManager.log_info("Subtitle text: '" + subtitle_label.text + "'")
			DebugManager.log_info("Subtitle visible: " + str(subtitle_label.visible))
			DebugManager.log_info("Subtitle modulate: " + str(subtitle_label.modulate))
			DebugManager.log_info("Subtitle size: " + str(subtitle_label.size))
			DebugManager.log_info("Subtitle position: " + str(subtitle_label.position))
			DebugManager.log_info("Subtitle global_position: " + str(subtitle_label.global_position))
			DebugManager.log_info("Subtitle custom_minimum_size: " + str(subtitle_label.custom_minimum_size))
			DebugManager.log_info("Subtitle clip_contents: " + str(subtitle_label.clip_contents))
			
			# Font information
			var font = subtitle_label.get_theme_font("font")
			var font_size = subtitle_label.get_theme_font_size("font_size")
			DebugManager.log_info("Subtitle font: " + str(font))
			DebugManager.log_info("Subtitle font_size: " + str(font_size))
			
			# Parent container debug
			DebugManager.log_info("Container modulate: " + str(title_container.modulate))
			DebugManager.log_info("Container size: " + str(title_container.size))
			DebugManager.log_info("Container position: " + str(title_container.position))
			DebugManager.log_info("Container clip_contents: " + str(title_container.clip_contents))
			
			# Compare with title label
			DebugManager.log_info("=== TITLE COMPARISON ===")
			DebugManager.log_info("Title text: '" + title_label.text + "'")
			DebugManager.log_info("Title visible: " + str(title_label.visible))
			DebugManager.log_info("Title size: " + str(title_label.size))
			DebugManager.log_info("Title position: " + str(title_label.position))
			
			# Force multiple visibility attempts
			subtitle_label.visible = true
			subtitle_label.modulate = Color.YELLOW
			subtitle_label.modulate.a = 1.0
			
			# Try forcing size
			subtitle_label.custom_minimum_size = Vector2(200, 30)
			
			# Try forcing font
			subtitle_label.add_theme_font_size_override("font_size", 32)
			subtitle_label.add_theme_color_override("font_color", Color.RED)
			
			DebugManager.log_info("FORCED: subtitle to yellow, red text, size 32, min size 200x30")
		DebugManager.log_info("==================")
	else:
		print("=== SUBTITLE DETAILED DEBUG ===")
		print("Subtitle exists: " + str(subtitle_label != null))
		if subtitle_label:
			print("Subtitle text: '" + subtitle_label.text + "'")
			print("Subtitle visible: " + str(subtitle_label.visible))
			print("Subtitle modulate: " + str(subtitle_label.modulate))
			print("Subtitle size: " + str(subtitle_label.size))
			print("Subtitle position: " + str(subtitle_label.position))
			print("Subtitle global_position: " + str(subtitle_label.global_position))
			print("Subtitle custom_minimum_size: " + str(subtitle_label.custom_minimum_size))
			print("Subtitle clip_contents: " + str(subtitle_label.clip_contents))
			
			# Font information
			var font = subtitle_label.get_theme_font("font")
			var font_size = subtitle_label.get_theme_font_size("font_size")
			print("Subtitle font: " + str(font))
			print("Subtitle font_size: " + str(font_size))
			
			# Parent container debug
			print("Container modulate: " + str(title_container.modulate))
			print("Container size: " + str(title_container.size))
			print("Container position: " + str(title_container.position))
			print("Container clip_contents: " + str(title_container.clip_contents))
			
			# Compare with title label
			print("=== TITLE COMPARISON ===")
			print("Title text: '" + title_label.text + "'")
			print("Title visible: " + str(title_label.visible))
			print("Title size: " + str(title_label.size))
			print("Title position: " + str(title_label.position))
			
			# Force multiple visibility attempts
			subtitle_label.visible = true
			subtitle_label.modulate = Color.YELLOW
			subtitle_label.modulate.a = 1.0
			
			# Try forcing size
			subtitle_label.custom_minimum_size = Vector2(200, 30)
			
			# Try forcing font
			subtitle_label.add_theme_font_size_override("font_size", 32)
			subtitle_label.add_theme_color_override("font_color", Color.RED)
			
			print("FORCED: subtitle to yellow, red text, size 32, min size 200x30")
		print("==================")

func debug_button_clickability():
	"""Debug why the button might not be clickable"""
	var drive_button = $CenterContainer/MainContainer/ButtonContainer/DriveButton
	
	if DebugManager:
		DebugManager.log_info("=== ENHANCED BUTTON DEBUG ===")
		DebugManager.log_info("Button exists: " + str(drive_button != null))
		if drive_button:
			DebugManager.log_info("Button visible: " + str(drive_button.visible))
			DebugManager.log_info("Button disabled: " + str(drive_button.disabled))
			DebugManager.log_info("Button modulate: " + str(drive_button.modulate))
			DebugManager.log_info("Button mouse_filter: " + str(drive_button.mouse_filter))
			DebugManager.log_info("Button size: " + str(drive_button.size))
			DebugManager.log_info("Button global_position: " + str(drive_button.global_position))
			DebugManager.log_info("Button z_index: " + str(drive_button.z_index))
			DebugManager.log_info("Button flat: " + str(drive_button.flat))
			
			# Check if button can actually receive input
			var mouse_pos = get_global_mouse_position()
			var button_rect = Rect2(drive_button.global_position, drive_button.size)
			DebugManager.log_info("Mouse position: " + str(mouse_pos))
			DebugManager.log_info("Button rect: " + str(button_rect))
			DebugManager.log_info("Mouse over button: " + str(button_rect.has_point(mouse_pos)))
			
			# Check parent containers hierarchy (stop before Window)
			var current = drive_button.get_parent()
			var depth = 0
			while current and depth < 10 and not current is Window:
				if current.has_method("get") and "mouse_filter" in current:
					DebugManager.log_info("Parent " + str(depth) + " (" + current.name + "): mouse_filter=" + str(current.mouse_filter) + ", visible=" + str(current.visible) + ", modulate=" + str(current.modulate))
				else:
					DebugManager.log_info("Parent " + str(depth) + " (" + current.name + "): visible=" + str(current.visible) + ", modulate=" + str(current.modulate))
				current = current.get_parent()
				depth += 1
			
			# Check if signals are connected properly
			var connections = drive_button.pressed.get_connections()
			DebugManager.log_info("Button signal connections: " + str(connections.size()))
			for connection in connections:
				DebugManager.log_info("Connected to: " + str(connection["callable"]))
			
			# Test if we can manually trigger the function
			DebugManager.log_info("Attempting to manually call _on_drive_button_pressed...")
			call_deferred("_on_drive_button_pressed")  # Try calling it manually
			
		DebugManager.log_info("==================")
	else:
		print("=== ENHANCED BUTTON DEBUG ===")
		print("Button exists: " + str(drive_button != null))
		if drive_button:
			print("Button visible: " + str(drive_button.visible))
			print("Button disabled: " + str(drive_button.disabled))
			print("Button modulate: " + str(drive_button.modulate))
			print("Button mouse_filter: " + str(drive_button.mouse_filter))
			print("Button size: " + str(drive_button.size))
			print("Button global_position: " + str(drive_button.global_position))
			print("Button z_index: " + str(drive_button.z_index))
			print("Button flat: " + str(drive_button.flat))
			
			# Check if button can actually receive input
			var mouse_pos = get_global_mouse_position()
			var button_rect = Rect2(drive_button.global_position, drive_button.size)
			print("Mouse position: " + str(mouse_pos))
			print("Button rect: " + str(button_rect))
			print("Mouse over button: " + str(button_rect.has_point(mouse_pos)))
			
			# Check parent containers hierarchy (stop before Window)
			var current = drive_button.get_parent()
			var depth = 0
			while current and depth < 10 and not current is Window:
				if current.has_method("get") and "mouse_filter" in current:
					print("Parent " + str(depth) + " (" + current.name + "): mouse_filter=" + str(current.mouse_filter) + ", visible=" + str(current.visible) + ", modulate=" + str(current.modulate))
				else:
					print("Parent " + str(depth) + " (" + current.name + "): visible=" + str(current.visible) + ", modulate=" + str(current.modulate))
				current = current.get_parent()
				depth += 1
			
			# Check if signals are connected properly
			var connections = drive_button.pressed.get_connections()
			print("Button signal connections: " + str(connections.size()))
			for connection in connections:
				print("Connected to: " + str(connection["callable"]))
		
		print("==================")

func fix_input_blocking():
	"""Fix potential input blocking issues"""
	if DebugManager:
		DebugManager.log_info("Lobby: Fixing potential input blocking issues")
	else:
		print("Lobby: Fixing potential input blocking issues")
	
	# Ensure all containers allow input to pass through except where we explicitly want to block it
	# Root Control should pass input through
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Background should ignore mouse (it has mouse_filter = 2 in scene which is IGNORE)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Containers should pass input through to their children
	center_container.mouse_filter = Control.MOUSE_FILTER_PASS
	title_container.mouse_filter = Control.MOUSE_FILTER_PASS
	button_container.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Get the button and ensure it can receive input
	var drive_button = $CenterContainer/MainContainer/ButtonContainer/DriveButton
	if drive_button:
		drive_button.mouse_filter = Control.MOUSE_FILTER_STOP  # Button should stop input to handle clicks
		drive_button.disabled = false  # Make sure it's not disabled
		
		if DebugManager:
			DebugManager.log_info("Lobby: Button mouse filter set to STOP, disabled = false")
		else:
			print("Lobby: Button mouse filter set to STOP, disabled = false")

func apply_theme_safe():
	# Apply UI theme with proper registration for Control-based structure
	if UIThemeManager:
		# Register the root Control node for theme application
		UIThemeManager.register_ui_component(self)
		
		# Apply theme to specific UI elements
		apply_theme_to_buttons()
		apply_theme_to_labels()
		
		if DebugManager:
			DebugManager.log_info("Lobby: UIThemeManager integration applied with Control-based registration")
		else:
			print("Lobby: UIThemeManager integration applied with Control-based registration")
	else:
		if DebugManager:
			DebugManager.log_info("Lobby: UIThemeManager not available - using default styling")
		else:
			print("Lobby: UIThemeManager not available - using default styling")

func setup_theme_change_listener():
	# Listen for theme changes to update visuals immediately
	if UIThemeManager:
		# Check if signal already connected to avoid duplicate connections
		if not UIThemeManager.theme_changed.is_connected(_on_theme_changed):
			UIThemeManager.theme_changed.connect(_on_theme_changed)
			
		if DebugManager:
			DebugManager.log_info("Lobby: Listening for theme changes")
		else:
			print("Lobby: Listening for theme changes")

func _on_theme_changed(theme_name: String, _theme_resource: Theme):
	# Called when F7 theme cycling happens
	if DebugManager:
		DebugManager.log_info("Lobby: Theme changed to " + theme_name)
	else:
		print("Lobby: Theme changed to " + theme_name)
	
	# Reapply theme to all elements
	apply_theme_to_buttons()
	apply_theme_to_labels()
	
	# Add visual feedback for theme changes
	show_theme_change_feedback(theme_name)

func show_theme_change_feedback(theme_name: String):
	# Create a temporary visual indicator of theme changes
	var feedback_label = Label.new()
	feedback_label.text = "Theme: " + theme_name
	feedback_label.position = Vector2(20, 20)
	feedback_label.modulate = Color.YELLOW
	
	# Add to scene temporarily
	add_child(feedback_label)
	
	# Fade out and remove after 2 seconds
	var tween = create_tween()
	tween.tween_property(feedback_label, "modulate:a", 0.0, 2.0)
	await tween.finished
	feedback_label.queue_free()

func apply_theme_to_buttons():
	# Apply theme to button container (better approach - let inheritance handle the rest)
	if not UIThemeManager or not button_container:
		return
		
	var current_theme = UIThemeManager.get_current_theme()
	var theme_name = UIThemeManager.get_current_theme_name()
	
	if current_theme and button_container:
		# Apply theme to parent container - much cleaner than individual button styling
		button_container.theme = current_theme
		
		# DEBUGGING: Make theme differences very obvious with container-level styling
		match theme_name:
			"default":
				button_container.modulate = Color.WHITE
			"high_contrast":
				button_container.modulate = Color(1.2, 1.2, 0.8)  # Slight yellow tint
			"mobile":
				button_container.modulate = Color(0.8, 1.0, 1.2)  # Slight cyan tint
			"retro":
				button_container.modulate = Color(0.8, 1.2, 0.8)  # Slight green tint
		
		# Apply accessibility scaling if enabled
		var accessibility_settings = UIThemeManager.get_accessibility_settings()
		if accessibility_settings.scale > 1.0:
			button_container.scale = Vector2.ONE * accessibility_settings.scale

func apply_theme_to_labels():
	# Apply theme to title container (better approach - let inheritance handle the rest)
	if not UIThemeManager or not title_container:
		return
		
	var current_theme = UIThemeManager.get_current_theme()
	var theme_name = UIThemeManager.get_current_theme_name()
	
	if current_theme and title_container:
		# Apply theme to parent container
		title_container.theme = current_theme
		
		# DEBUGGING: Make theme differences very obvious with container-level styling
		match theme_name:
			"default":
				title_container.modulate = Color.WHITE
			"high_contrast":
				title_container.modulate = Color(1.2, 1.2, 0.8)
			"mobile":
				title_container.modulate = Color(0.8, 1.0, 1.2)
			"retro":
				title_container.modulate = Color(0.8, 1.2, 0.8)
		
		# Apply accessibility scaling if enabled
		var accessibility_settings = UIThemeManager.get_accessibility_settings()
		if accessibility_settings.scale > 1.0:
			title_container.scale = Vector2.ONE * accessibility_settings.scale

# Legacy individual scaling functions removed - now using container-level scaling
