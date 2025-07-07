extends Control
class_name MainMenuController

## MainMenuController - Self-Sufficient Main Menu
## Independent controller that handles menu logic without relying on potentially unstable managers
## Directly manages theme switching, scene transitions, and UI effects

# Menu Components (will be assigned from scene)
@onready var background: Control = $Background
@onready var main_container: HBoxContainer = $MainContainer
@onready var left_panel: Control = $MainContainer/LeftPanel
@onready var aircraft_list: VBoxContainer = $MainContainer/LeftPanel/AircraftList
@onready var right_panel: Control = $MainContainer/RightPanel
@onready var specs_container: VBoxContainer = $MainContainer/RightPanel/SpecsContainer
@onready var stats_container: VBoxContainer = $MainContainer/RightPanel/StatsContainer

# Menu state
var current_theme: String = "tech"
var selected_aircraft: int = 0
var aircraft_data: Array[Dictionary] = []
var menu_items: Array[Control] = []

# Signals
signal aircraft_selected(aircraft_index: int)
signal menu_action(action: String, data: Dictionary)
signal theme_switched(theme_name: String)

func _ready():
	print("MainMenuController: Initializing independent main menu")
	
	# Setup menu data
	initialize_aircraft_data()
	
	# Setup background effects
	setup_dynamic_background()
	
	# Build menu UI
	build_menu_interface()
	
	# Apply initial theme independently
	apply_theme_direct()
	
	# Setup input handling
	setup_input_handling()
	
	print("MainMenuController: Main menu ready")

func initialize_aircraft_data():
	"""Initialize aircraft data for the menu (example data)"""
	aircraft_data = [
		{
			"name": "Typhoon",
			"type": "Multirole Fighter",
			"speed": 85,
			"mobility": 78,
			"stability": 82,
			"air_to_air": 90,
			"air_to_ground": 75,
			"defense": 80
		},
		{
			"name": "Gripen E", 
			"type": "Light Fighter",
			"speed": 82,
			"mobility": 95,
			"stability": 88,
			"air_to_air": 85,
			"air_to_ground": 70,
			"defense": 75
		},
		{
			"name": "Su-47",
			"type": "Experimental Fighter",
			"speed": 95,
			"mobility": 85,
			"stability": 70,
			"air_to_air": 88,
			"air_to_ground": 82,
			"defense": 78
		}
	]

func setup_dynamic_background():
	"""Setup the animated tech background"""
	if not background:
		return
	
	# Create a ColorRect for the background
	var bg_rect = ColorRect.new()
	bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_rect.color = Color(0.05, 0.1, 0.15, 1.0)
	background.add_child(bg_rect)
	
	# Try to apply the shader if available
	var shader_material = ShaderMaterial.new()
	var tech_shader = load("res://assets/shaders/tech_background.gdshader")
	
	if tech_shader:
		shader_material.shader = tech_shader
		# Configure shader parameters
		shader_material.set_shader_parameter("grid_scale", 0.5)
		shader_material.set_shader_parameter("scroll_speed", 0.3)
		shader_material.set_shader_parameter("grid_opacity", 0.2)
		shader_material.set_shader_parameter("grid_color", Color(0.0, 0.8, 1.0, 1.0))
		shader_material.set_shader_parameter("glow_intensity", 1.5)
		
		bg_rect.material = shader_material
		print("MainMenuController: Tech background shader applied")
	else:
		print("MainMenuController: Shader not found, using solid background")

func build_menu_interface():
	"""Build the main menu interface"""
	# Clear existing items
	for child in aircraft_list.get_children():
		child.queue_free()
	
	# Create aircraft selection items
	for i in range(aircraft_data.size()):
		var aircraft = aircraft_data[i]
		var menu_item = create_aircraft_menu_item(aircraft, i)
		aircraft_list.add_child(menu_item)
		menu_items.append(menu_item)
	
	# Build specs display
	update_specs_display()
	
	# Select first aircraft by default
	if menu_items.size() > 0:
		select_aircraft(0)

func create_aircraft_menu_item(aircraft: Dictionary, index: int) -> Control:
	"""Create a menu item for aircraft selection"""
	var item = Button.new()
	item.text = aircraft["name"]
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.custom_minimum_size = Vector2(200, 40)
	
	# Style the button
	apply_tech_button_style(item)
	
	# Connect selection
	item.pressed.connect(func(): select_aircraft(index))
	
	# Add hover effects
	item.mouse_entered.connect(func(): on_item_hover(item, true))
	item.mouse_exited.connect(func(): on_item_hover(item, false))
	
	return item

func apply_tech_button_style(button: Button):
	"""Apply tech theme styling to buttons"""
	# Create tech-style button appearance
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.1, 0.15, 0.2, 0.8)
	style_normal.border_color = Color(0.0, 0.6, 0.8, 1.0)
	style_normal.border_width_left = 1
	style_normal.border_width_right = 1
	style_normal.border_width_top = 1
	style_normal.border_width_bottom = 1
	style_normal.corner_radius_top_left = 2
	style_normal.corner_radius_top_right = 2
	style_normal.corner_radius_bottom_left = 2
	style_normal.corner_radius_bottom_right = 2
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.15, 0.2, 0.25, 0.9)
	style_hover.border_color = Color(0.0, 0.8, 1.0, 1.0)
	style_hover.border_width_left = 2
	style_hover.border_width_right = 2
	style_hover.border_width_top = 2
	style_hover.border_width_bottom = 2
	style_hover.corner_radius_top_left = 2
	style_hover.corner_radius_top_right = 2
	style_hover.corner_radius_bottom_left = 2
	style_hover.corner_radius_bottom_right = 2
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_hover)
	button.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))

func on_item_hover(item: Control, is_hovering: bool):
	"""Handle hover effects for menu items"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	if is_hovering:
		# Lift and glow effect
		tween.tween_property(item, "position:y", item.position.y - 3, 0.12)
		tween.tween_property(item, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.12)
	else:
		# Return to normal
		tween.tween_property(item, "position:y", item.position.y + 3, 0.12)
		tween.tween_property(item, "modulate", Color.WHITE, 0.12)

func select_aircraft(index: int):
	"""Select an aircraft and update display"""
	if index < 0 or index >= aircraft_data.size():
		return
	
	selected_aircraft = index
	
	# Update visual selection
	for i in range(menu_items.size()):
		var item = menu_items[i]
		if i == index:
			# Highlight selected
			item.add_theme_color_override("font_color", Color(0.0, 0.8, 1.0))
		else:
			# Normal color
			item.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	
	# Update specs display
	update_specs_display()
	
	# Emit signal
	aircraft_selected.emit(index)

func update_specs_display():
	"""Update the specifications display panel"""
	if not specs_container or aircraft_data.is_empty():
		return
	
	# Clear existing specs
	for child in specs_container.get_children():
		child.queue_free()
	
	var aircraft = aircraft_data[selected_aircraft]
	
	# Aircraft name and type
	var name_label = Label.new()
	name_label.text = aircraft["name"]
	name_label.add_theme_color_override("font_color", Color(0.0, 0.8, 1.0))
	name_label.add_theme_font_size_override("font_size", 24)
	specs_container.add_child(name_label)
	
	var type_label = Label.new()
	type_label.text = aircraft["type"]
	type_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	specs_container.add_child(type_label)
	
	# Stats
	var stats_to_show = ["speed", "mobility", "stability", "air_to_air", "air_to_ground", "defense"]
	
	for stat in stats_to_show:
		if stat in aircraft:
			var stat_container = create_stat_bar(stat.capitalize().replace("_", "-"), aircraft[stat])
			specs_container.add_child(stat_container)

func create_stat_bar(stat_name: String, value: int) -> Control:
	"""Create a tech-style stat bar"""
	var container = HBoxContainer.new()
	container.custom_minimum_size.y = 25
	
	# Stat name
	var label = Label.new()
	label.text = stat_name.to_upper()
	label.custom_minimum_size.x = 120
	label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	label.add_theme_font_size_override("font_size", 12)
	container.add_child(label)
	
	# Stat bar background
	var bg_rect = ColorRect.new()
	bg_rect.custom_minimum_size = Vector2(200, 16)
	bg_rect.color = Color(0.1, 0.15, 0.2, 0.8)
	container.add_child(bg_rect)
	
	# Stat bar fill
	var fill_rect = ColorRect.new()
	fill_rect.custom_minimum_size = Vector2(200 * (value / 100.0), 16)
	fill_rect.color = Color(0.0, 0.8, 1.0, 0.9)
	fill_rect.position = bg_rect.position
	bg_rect.add_child(fill_rect)
	
	return container

func apply_theme_direct():
	"""Apply theme directly without relying on managers"""
	# This is called when managers might not be available
	# Apply tech theme colors and effects directly
	
	# Set overall theme colors
	modulate = Color.WHITE
	
	# Apply to main container if available
	if main_container:
		main_container.add_theme_constant_override("separation", 40)

func setup_input_handling():
	"""Setup independent input handling"""
	# Handle navigation keys
	set_process_unhandled_key_input(true)

func _unhandled_key_input(event):
	"""Handle keyboard input for menu navigation"""
	if event.pressed:
		match event.keycode:
			KEY_UP:
				navigate_aircraft(-1)
			KEY_DOWN:
				navigate_aircraft(1)
			KEY_ENTER:
				confirm_selection()
			KEY_ESCAPE:
				handle_back()
			KEY_F1:
				switch_theme_cycle()

func navigate_aircraft(direction: int):
	"""Navigate aircraft selection with keyboard"""
	var new_index = selected_aircraft + direction
	new_index = clamp(new_index, 0, aircraft_data.size() - 1)
	select_aircraft(new_index)

func confirm_selection():
	"""Confirm aircraft selection"""
	print("MainMenuController: Aircraft confirmed - ", aircraft_data[selected_aircraft]["name"])
	menu_action.emit("confirm_aircraft", aircraft_data[selected_aircraft])

func handle_back():
	"""Handle back/exit action"""
	print("MainMenuController: Back pressed")
	menu_action.emit("back", {})

func switch_theme_cycle():
	"""Cycle through available themes independently"""
	var themes = ["default", "tech", "retro", "high_contrast"]
	var current_index = themes.find(current_theme)
	var next_index = (current_index + 1) % themes.size()
	var next_theme = themes[next_index]
	
	switch_theme(next_theme)

func switch_theme(theme_name: String):
	"""Switch theme independently"""
	current_theme = theme_name
	
	# Try to use UIThemeManager if available, otherwise fallback
	if UIThemeManager and UIThemeManager.has_method("switch_theme"):
		UIThemeManager.switch_theme(theme_name)
		print("MainMenuController: Switched to theme via UIThemeManager: ", theme_name)
	else:
		# Fallback: apply theme directly
		apply_theme_fallback(theme_name)
		print("MainMenuController: Applied theme fallback: ", theme_name)
	
	theme_switched.emit(theme_name)

func apply_theme_fallback(theme_name: String):
	"""Apply theme without UIThemeManager"""
	match theme_name:
		"tech":
			apply_tech_theme()
		"default":
			apply_default_theme()
		_:
			apply_tech_theme()  # Default to tech

func apply_tech_theme():
	"""Apply tech theme styling manually"""
	# Update background shader if possible
	setup_dynamic_background()
	
	# Update button styles
	for item in menu_items:
		if item is Button:
			apply_tech_button_style(item)

func apply_default_theme():
	"""Apply default theme styling manually"""
	# Basic default styling
	for item in menu_items:
		if item is Button:
			item.add_theme_color_override("font_color", Color.WHITE)

# Public API
func get_selected_aircraft() -> Dictionary:
	"""Get currently selected aircraft data"""
	if selected_aircraft < aircraft_data.size():
		return aircraft_data[selected_aircraft]
	return {}

func set_aircraft_data(new_data: Array[Dictionary]):
	"""Set aircraft data and rebuild interface"""
	aircraft_data = new_data
	build_menu_interface()

# Connect to scene transition when ready
func transition_to_game():
	"""Transition to main game (when SceneManager is stable)"""
	if SceneManager and SceneManager.has_method("change_scene"):
		SceneManager.change_scene("res://scenes/main_game.tscn")
	else:
		# Fallback scene transition
		get_tree().change_scene_to_file("res://scenes/main_game.tscn") 