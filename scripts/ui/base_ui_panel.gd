extends PanelContainer
class_name BaseUIPanel

## BaseUIPanel - Foundation for all UI components
## Based on UI_RULES.md - Responsive Design and Component Composition
## Provides theming, accessibility, keyboard navigation, and responsive layout

# Component references
@onready var content_container = $ContentContainer
@onready var content = $ContentContainer/Content
@onready var header = $ContentContainer/Content/Header
@onready var title_label = $ContentContainer/Content/Header/Title
@onready var close_button = $ContentContainer/Content/Header/CloseButton
@onready var body = $ContentContainer/Content/Body
@onready var footer = $ContentContainer/Content/Footer

# Configuration following UI_RULES.md responsive design
@export_group("Layout Configuration")
@export var panel_title: String = "Panel" : set = set_panel_title
@export var show_header: bool = true : set = set_show_header
@export var show_close_button: bool = true : set = set_show_close_button
@export var show_footer: bool = false : set = set_show_footer

# Responsive design configuration
@export_group("Responsive Design")
@export var min_size: Vector2 = Vector2(320, 240)
@export var max_size: Vector2 = Vector2(1200, 800)
@export var mobile_layout_threshold: int = 800
@export var auto_adjust_margins: bool = true

# Animation and transitions
@export_group("Animation")
@export var fade_in_duration: float = 0.3
@export var slide_direction: String = "none"  # "up", "down", "left", "right", "none"
@export var scale_animation: bool = false

# Accessibility features - Following UI_RULES.md accessibility requirements
@export_group("Accessibility")
@export var keyboard_navigable: bool = true
@export var focus_highlight: bool = true
@export var screen_reader_friendly: bool = true
@export var initial_focus_target: NodePath = ""

# Panel state
var is_modal: bool = false
var current_theme_config: UIThemeConfig = null
var original_position: Vector2
var original_size: Vector2

# Signals following UI_RULES.md contract
signal panel_opened()
signal panel_closed(result: Dictionary)
signal panel_resized(new_size: Vector2)
signal focus_requested(target: Control)

func _ready():
	# Store original properties
	original_position = position
	original_size = size
	
	# Apply initial configuration
	apply_panel_configuration()
	
	# Connect signals
	setup_signal_connections()
	
	# Register with GameUI for theme updates
	register_with_game_ui()
	
	# Setup accessibility features
	setup_accessibility_features()
	
	# Apply responsive design
	apply_responsive_design()
	
	# Setup keyboard navigation
	if keyboard_navigable:
		setup_keyboard_navigation()

func apply_panel_configuration():
	"""Apply panel configuration settings"""
	set_panel_title(panel_title)
	set_show_header(show_header)
	set_show_close_button(show_close_button)
	set_show_footer(show_footer)

func setup_signal_connections():
	"""Setup internal signal connections"""
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	# Listen for size changes
	resized.connect(_on_panel_resized)

func register_with_game_ui():
	"""Register this panel with GameUI for theme updates"""
	# Find GameUI in scene tree
	var game_ui = get_node_or_null("/root/Main/GameUI")
	if not game_ui:
		game_ui = null
	if not game_ui and has_node("/root/GameUI"):
		game_ui = get_node("/root/GameUI")
	
	if game_ui and game_ui.has_method("register_ui_component"):
		game_ui.register_ui_component(self, "base_panel")

func setup_accessibility_features():
	"""Setup accessibility features following UI_RULES.md"""
	if not screen_reader_friendly:
		return
	
	# Set accessible name and description
	if title_label:
		accessible_name = title_label.text
		accessible_description = "UI Panel: " + title_label.text
	
	# Configure focus behavior
	if keyboard_navigable:
		focus_mode = Control.FOCUS_ALL
		
		# Set initial focus target
		if initial_focus_target != "":
			var focus_target = get_node_or_null(initial_focus_target)
			if focus_target and focus_target is Control:
				focus_target.call_deferred("grab_focus")

func setup_keyboard_navigation():
	"""Setup keyboard navigation support"""
	# Enable keyboard input processing
	set_process_unhandled_key_input(true)
	
	# Configure focus navigation
	focus_mode = Control.FOCUS_ALL

func apply_responsive_design():
	"""Apply responsive design based on screen size"""
	var viewport_size = get_viewport().size
	
	# Adjust for mobile layout
	if viewport_size.x < mobile_layout_threshold:
		apply_mobile_layout()
	else:
		apply_desktop_layout()
	
	# Auto-adjust margins if enabled
	if auto_adjust_margins:
		adjust_margins_for_screen_size(viewport_size)

func apply_mobile_layout():
	"""Apply mobile-optimized layout"""
	# Increase touch targets
	if close_button:
		close_button.custom_minimum_size = Vector2(44, 44)  # iOS/Android touch target minimum
	
	# Adjust margins for mobile
	if content_container:
		content_container.add_theme_constant_override("margin_left", 16)
		content_container.add_theme_constant_override("margin_right", 16)
		content_container.add_theme_constant_override("margin_top", 16)
		content_container.add_theme_constant_override("margin_bottom", 16)

func apply_desktop_layout():
	"""Apply desktop-optimized layout"""
	# Standard desktop touch targets
	if close_button:
		close_button.custom_minimum_size = Vector2(32, 32)
	
	# Standard desktop margins
	if content_container:
		content_container.add_theme_constant_override("margin_left", 12)
		content_container.add_theme_constant_override("margin_right", 12)
		content_container.add_theme_constant_override("margin_top", 12)
		content_container.add_theme_constant_override("margin_bottom", 12)

func adjust_margins_for_screen_size(viewport_size: Vector2):
	"""Adjust margins based on screen size"""
	var margin_scale = clamp(viewport_size.x / 1280.0, 0.5, 2.0)  # Scale based on 1280px reference
	var base_margin = 12
	var scaled_margin = int(base_margin * margin_scale)
	
	if content_container:
		content_container.add_theme_constant_override("margin_left", scaled_margin)
		content_container.add_theme_constant_override("margin_right", scaled_margin)
		content_container.add_theme_constant_override("margin_top", scaled_margin)
		content_container.add_theme_constant_override("margin_bottom", scaled_margin)

# Theme Application - Following UI_RULES.md theme system
func apply_theme_changes(theme_config: UIThemeConfig):
	"""Apply theme changes from UIThemeManager - REQUIRED by UI_RULES.md contract"""
	if not theme_config:
		return
	
	current_theme_config = theme_config
	
	# Apply colors
	apply_theme_colors(theme_config)
	
	# Apply typography
	apply_theme_typography(theme_config)
	
	# Apply spacing and layout
	apply_theme_layout(theme_config)
	
	# Apply accessibility features
	apply_theme_accessibility(theme_config)

func apply_theme_colors(theme_config: UIThemeConfig):
	"""Apply color scheme from theme"""
	# Panel background
	add_theme_color_override("bg_color", theme_config.background_color)
	
	# Title text color
	if title_label:
		title_label.add_theme_color_override("font_color", theme_config.text_primary)
	
	# Close button styling will be handled by the theme system

func apply_theme_typography(theme_config: UIThemeConfig):
	"""Apply typography from theme"""
	if title_label and theme_config.font_primary:
		title_label.add_theme_font_override("font", theme_config.font_primary)
		title_label.add_theme_font_size_override("font_size", theme_config.font_size_large)

func apply_theme_layout(theme_config: UIThemeConfig):
	"""Apply layout and spacing from theme"""
	# Apply UI scaling
	if theme_config.ui_scale != 1.0:
		scale = Vector2.ONE * theme_config.ui_scale
	
	# Apply spacing
	if header:
		header.add_theme_constant_override("separation", theme_config.spacing_medium)
	
	if footer:
		footer.add_theme_constant_override("separation", theme_config.spacing_medium)

func apply_theme_accessibility(theme_config: UIThemeConfig):
	"""Apply accessibility features from theme"""
	if theme_config.large_text_mode:
		# Increase text scaling beyond base theme
		if title_label:
			var current_size = title_label.get_theme_font_size("font_size")
			title_label.add_theme_font_size_override("font_size", int(current_size * 1.2))
	
	if theme_config.high_contrast_mode:
		# Apply high contrast styling
		if title_label:
			title_label.add_theme_color_override("font_shadow_color", Color.BLACK)
			title_label.add_theme_constant_override("shadow_offset_x", 1)
			title_label.add_theme_constant_override("shadow_offset_y", 1)

# Animation Functions
func show_panel_animated():
	"""Show panel with animation based on configuration"""
	panel_opened.emit()
	
	if fade_in_duration <= 0:
		visible = true
		return
	
	# Fade in animation
	modulate.a = 0.0
	visible = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	
	# Scale animation if enabled
	if scale_animation:
		scale = Vector2.ZERO
		tween.parallel().tween_property(self, "scale", Vector2.ONE, fade_in_duration)
		tween.tween_callback(func(): scale = Vector2.ONE)  # Ensure final scale is exact
	
	# Slide animation
	if slide_direction != "none":
		apply_slide_animation()

func apply_slide_animation():
	"""Apply slide-in animation based on direction"""
	var slide_offset = Vector2.ZERO
	var viewport_size = get_viewport().size
	
	match slide_direction:
		"up":
			slide_offset = Vector2(0, viewport_size.y)
		"down":
			slide_offset = Vector2(0, -viewport_size.y)
		"left":
			slide_offset = Vector2(viewport_size.x, 0)
		"right":
			slide_offset = Vector2(-viewport_size.x, 0)
	
	position = original_position + slide_offset
	
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, fade_in_duration)

func hide_panel_animated(result: Dictionary = {}):
	"""Hide panel with animation"""
	var tween = create_tween()
	
	if fade_in_duration > 0:
		tween.tween_property(self, "modulate:a", 0.0, fade_in_duration * 0.5)
		
		if scale_animation:
			tween.parallel().tween_property(self, "scale", Vector2.ZERO, fade_in_duration * 0.5)
	
	tween.tween_callback(func(): 
		visible = false
		panel_closed.emit(result)
		modulate.a = 1.0
		scale = Vector2.ONE
	)

# Property Setters
func set_panel_title(value: String):
	panel_title = value
	if title_label:
		title_label.text = value
		accessible_name = value

func set_show_header(value: bool):
	show_header = value
	if header:
		header.visible = value

func set_show_close_button(value: bool):
	show_close_button = value
	if close_button:
		close_button.visible = value

func set_show_footer(value: bool):
	show_footer = value
	if footer:
		footer.visible = value

# Input Handling
func _unhandled_key_input(event):
	if not keyboard_navigable or not visible:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if show_close_button:
					_on_close_button_pressed()
				accept_event()
			KEY_TAB:
				# Handle tab navigation
				handle_tab_navigation(event.shift_pressed)
				accept_event()

func handle_tab_navigation(reverse: bool = false):
	"""Handle tab-based keyboard navigation"""
	# This will be enhanced when we add more focusable elements
	if close_button and close_button.visible:
		close_button.grab_focus()

# Signal Handlers
func _on_close_button_pressed():
	"""Handle close button press"""
	hide_panel_animated({"action": "close", "source": "close_button"})

func _on_panel_resized():
	"""Handle panel resize"""
	panel_resized.emit(size)
	
	# Reapply responsive design if size changed significantly
	if abs(size.x - original_size.x) > 100:
		apply_responsive_design()

# Utility Functions
func get_body_container() -> Control:
	"""Get the body container for adding custom content"""
	return body

func get_header_container() -> HBoxContainer:
	"""Get the header container for adding custom header elements"""
	return header

func get_footer_container() -> HBoxContainer:
	"""Get the footer container for adding custom footer elements"""
	return footer

func set_modal_mode(modal: bool):
	"""Configure panel for modal or non-modal behavior"""
	is_modal = modal
	
	if modal:
		# Modal configuration
		mouse_filter = Control.MOUSE_FILTER_STOP
		set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
	else:
		# Non-modal configuration
		mouse_filter = Control.MOUSE_FILTER_PASS
		set_process_mode(Node.PROCESS_MODE_INHERIT)

# Validation and Debug
func validate_panel_structure() -> bool:
	"""Validate panel structure integrity"""
	var validation_passed = true
	
	if not content_container:
		DebugManager.log_error("BaseUIPanel: Missing ContentContainer")
		validation_passed = false
	
	if show_header and not header:
		DebugManager.log_error("BaseUIPanel: Header enabled but not found")
		validation_passed = false
	
	if show_close_button and not close_button:
		DebugManager.log_error("BaseUIPanel: Close button enabled but not found")
		validation_passed = false
	
	return validation_passed

# SCENE_TAG: UI_BASE_COMPONENT - foundation for all UI elements
const SCENE_TAGS = ["UI_BASE_COMPONENT", "UI_RESPONSIVE", "UI_THEME_AWARE"] 