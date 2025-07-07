extends Button
class_name GlowButton

## GlowButton - Reusable button with theme-aware glow and hover effects
## Integrates with UIThemeConfig for consistent styling across all UI
## Perfect for transparent menu items with lift + glow on hover

# Configuration
@export_group("Glow Configuration")
@export var use_transparent_background: bool = true
@export var border_glow_only: bool = false
@export var custom_glow_color: Color = Color.TRANSPARENT  # Override theme glow color if needed

# State tracking
var current_theme_config: UIThemeConfig = null
var original_position: Vector2
var is_hovering: bool = false
var hover_tween: Tween

# Signals
signal glow_button_pressed(button: GlowButton)
signal glow_button_hovered(button: GlowButton, is_hover: bool)

func _ready():
	# Store original position for hover effects
	original_position = position
	
	# Connect button signals
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Apply initial styling
	apply_glow_button_styling()
	
	# Register with UIThemeManager if available
	register_with_theme_manager()

func register_with_theme_manager():
	"""Register with UIThemeManager for theme updates"""
	if UIThemeManager and UIThemeManager.has_method("register_ui_component"):
		UIThemeManager.register_ui_component(self)
	elif UIThemeManager:
		# Connect to theme change signal if available
		if UIThemeManager.has_signal("theme_changed"):
			UIThemeManager.theme_changed.connect(_on_theme_changed)

func apply_glow_button_styling():
	"""Apply initial glow button styling based on current theme"""
	if UIThemeManager and UIThemeManager.current_theme_config:
		current_theme_config = UIThemeManager.current_theme_config
		apply_theme_changes(current_theme_config)
	else:
		# Apply fallback styling
		apply_fallback_styling()

func apply_theme_changes(theme_config: UIThemeConfig):
	"""Apply theme changes - called by UIThemeManager"""
	if not theme_config:
		return
	
	current_theme_config = theme_config
	
	# Create normal state style
	var style_normal = create_glow_style(theme_config, false)
	add_theme_stylebox_override("normal", style_normal)
	
	# Create hover state style
	var style_hover = create_glow_style(theme_config, true)
	add_theme_stylebox_override("hover", style_hover)
	
	# Create pressed state style
	var style_pressed = create_glow_style(theme_config, true)
	style_pressed.bg_color = theme_config.button_pressed
	add_theme_stylebox_override("pressed", style_pressed)
	
	# Apply text color
	add_theme_color_override("font_color", theme_config.text_primary)
	
	# Apply font if available
	if theme_config.font_primary:
		add_theme_font_override("font", theme_config.font_primary)
		add_theme_font_size_override("font_size", theme_config.font_size_base)

func create_glow_style(theme_config: UIThemeConfig, is_active_state: bool) -> StyleBoxFlat:
	"""Create StyleBoxFlat with glow effects based on theme config"""
	var style = StyleBoxFlat.new()
	
	# Background color - transparent or semi-transparent for menu items
	if use_transparent_background:
		var bg_color = theme_config.surface_color
		bg_color.a = 0.1 if not is_active_state else 0.2
		style.bg_color = bg_color
	else:
		style.bg_color = theme_config.button_normal if not is_active_state else theme_config.button_hover
	
	# Glow effect via border
	if theme_config.glow_enabled or border_glow_only:
		var glow_color = custom_glow_color if custom_glow_color != Color.TRANSPARENT else theme_config.glow_color
		var glow_intensity = theme_config.glow_intensity
		
		if is_active_state and theme_config.hover_enabled:
			glow_intensity *= theme_config.hover_glow_boost
		
		# Apply glow as colored border
		style.border_color = glow_color
		style.border_color.a = glow_intensity * 0.8
		
		var border_width = int(theme_config.glow_size * 0.5) if is_active_state else 1
		style.border_width_left = border_width
		style.border_width_right = border_width
		style.border_width_top = border_width
		style.border_width_bottom = border_width
	
	# Corner radius
	var radius = theme_config.button_radius
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	
	return style

func apply_fallback_styling():
	"""Apply fallback styling when theme system is unavailable"""
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.1, 0.15, 0.2, 0.1)  # Transparent tech background
	style_normal.border_color = Color(0.0, 0.6, 0.8, 0.8)  # Tech blue border
	style_normal.border_width_left = 1
	style_normal.border_width_right = 1
	style_normal.border_width_top = 1
	style_normal.border_width_bottom = 1
	style_normal.corner_radius_top_left = 4
	style_normal.corner_radius_top_right = 4
	style_normal.corner_radius_bottom_left = 4
	style_normal.corner_radius_bottom_right = 4
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.15, 0.2, 0.25, 0.2)
	style_hover.border_color = Color(0.0, 0.8, 1.0, 1.0)
	style_hover.border_width_left = 2
	style_hover.border_width_right = 2
	style_hover.border_width_top = 2
	style_hover.border_width_bottom = 2
	
	add_theme_stylebox_override("normal", style_normal)
	add_theme_stylebox_override("hover", style_hover)
	add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))

# Hover Effects Implementation
func _on_mouse_entered():
	"""Handle mouse enter - start hover effects"""
	if is_hovering:
		return
	
	is_hovering = true
	start_hover_effects()
	glow_button_hovered.emit(self, true)

func _on_mouse_exited():
	"""Handle mouse exit - end hover effects"""
	if not is_hovering:
		return
	
	is_hovering = false
	end_hover_effects()
	glow_button_hovered.emit(self, false)

func start_hover_effects():
	"""Start hover lift and glow effects"""
	if not current_theme_config or not current_theme_config.hover_enabled:
		return
	
	# Stop any existing tween
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	
	# Lift effect
	if current_theme_config.hover_lift_amount > 0:
		var target_pos = original_position - Vector2(0, current_theme_config.hover_lift_amount)
		hover_tween.tween_property(self, "position", target_pos, current_theme_config.hover_duration)
	
	# Scale effect (subtle)
	if current_theme_config.hover_scale_factor > 1.0:
		var target_scale = Vector2.ONE * current_theme_config.hover_scale_factor
		hover_tween.tween_property(self, "scale", target_scale, current_theme_config.hover_duration)
	
	# Glow effect via modulate
	if current_theme_config.glow_enabled:
		var glow_boost = current_theme_config.hover_glow_boost
		hover_tween.tween_property(self, "modulate", Color(glow_boost, glow_boost, glow_boost, 1.0), current_theme_config.hover_duration)

func end_hover_effects():
	"""End hover effects and return to normal state"""
	if not current_theme_config:
		return
	
	# Stop any existing tween
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	
	# Return to original position
	hover_tween.tween_property(self, "position", original_position, current_theme_config.hover_duration)
	
	# Return to original scale
	hover_tween.tween_property(self, "scale", Vector2.ONE, current_theme_config.hover_duration)
	
	# Return to normal modulate
	hover_tween.tween_property(self, "modulate", Color.WHITE, current_theme_config.hover_duration)

func _on_button_pressed():
	"""Handle button press"""
	glow_button_pressed.emit(self)

# Public API
func set_glow_color(color: Color):
	"""Override the theme glow color for this button"""
	custom_glow_color = color
	if current_theme_config:
		apply_theme_changes(current_theme_config)

func force_hover_state(enable: bool):
	"""Force hover state on/off programmatically"""
	if enable and not is_hovering:
		is_hovering = true
		start_hover_effects()
	elif not enable and is_hovering:
		is_hovering = false
		end_hover_effects()

func update_original_position():
	"""Update the original position reference (call after moving button)"""
	original_position = position

# Theme system integration
func _on_theme_changed(_theme_name: String, _theme_resource: Theme):
	"""Handle theme changes from UIThemeManager"""
	if UIThemeManager and UIThemeManager.current_theme_config:
		apply_theme_changes(UIThemeManager.current_theme_config)

# SCENE_TAG: UI_COMPONENT - enables theme-aware styling
const SCENE_TAGS = ["UI_COMPONENT", "GLOW_BUTTON", "THEME_AWARE"] 