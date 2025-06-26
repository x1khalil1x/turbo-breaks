extends Resource
class_name UIThemeConfig

## UIThemeConfig - Theme Resource Definition
## Based on UI_RULES.md - Foundation First UI System
## Comprehensive theme configuration for runtime theme switching

# Theme identification
@export var theme_name: String = ""
@export var theme_description: String = ""
@export var is_accessibility_theme: bool = false

# Color scheme - Primary colors
@export_group("Primary Colors")
@export var primary_color: Color = Color(0.557, 0.808, 0.902)      # Main accent color
@export var secondary_color: Color = Color(0.251, 0.471, 0.549)    # Secondary elements
@export var background_color: Color = Color(0.102, 0.102, 0.102)   # Panel backgrounds
@export var surface_color: Color = Color(0.15, 0.15, 0.15)         # Card/container surfaces

# Color scheme - Text colors
@export_group("Text Colors")
@export var text_primary: Color = Color.WHITE                      # Primary text
@export var text_secondary: Color = Color(0.8, 0.8, 0.8)           # Secondary text
@export var text_disabled: Color = Color(0.5, 0.5, 0.5)            # Disabled text
@export var text_inverse: Color = Color.BLACK                      # Text on light backgrounds

# Color scheme - State colors
@export_group("State Colors")
@export var success_color: Color = Color(0.4, 0.8, 0.4)            # Success states
@export var warning_color: Color = Color(1.0, 0.8, 0.2)            # Warning states
@export var error_color: Color = Color(0.9, 0.3, 0.3)              # Error states
@export var info_color: Color = Color(0.3, 0.7, 0.9)               # Info states

# Color scheme - Interactive colors
@export_group("Interactive Colors")
@export var button_normal: Color = Color(0.4, 0.6, 0.8)            # Button default
@export var button_hover: Color = Color(0.5, 0.7, 0.9)             # Button hover
@export var button_pressed: Color = Color(0.3, 0.5, 0.7)           # Button pressed
@export var button_disabled: Color = Color(0.3, 0.3, 0.3)          # Button disabled

# Typography
@export_group("Typography")
@export var font_primary: FontFile                                  # Main UI font
@export var font_secondary: FontFile                               # Secondary/accent font
@export var font_monospace: FontFile                               # Code/debug font

# Font sizes following UI_RULES.md scale
@export var font_size_small: int = 12                              # Small text
@export var font_size_base: int = 16                               # Body text
@export var font_size_large: int = 24                              # Headings
@export var font_size_title: int = 32                              # Page titles
@export var font_size_display: int = 48                            # Hero text

# Layout and spacing - Following UI_RULES.md responsive design
@export_group("Layout & Spacing")
@export var ui_scale: float = 1.0                                  # Overall UI scaling
@export var panel_radius: int = 8                                  # Corner radius for panels
@export var button_radius: int = 4                                 # Corner radius for buttons

# Spacing scale
@export var spacing_tiny: int = 2                                  # Minimal spacing
@export var spacing_small: int = 4                                 # Small spacing
@export var spacing_medium: int = 8                                # Standard spacing
@export var spacing_large: int = 16                                # Large spacing
@export var spacing_xlarge: int = 24                               # Extra large spacing

# Component dimensions
@export var button_height: int = 40                                # Standard button height
@export var input_height: int = 36                                 # Input field height
@export var default_margin: int = 16                               # Default container margin

# Animation and transitions - Following UI_RULES.md performance targets
@export_group("Animation")
@export var animation_speed_multiplier: float = 1.0                # Global animation speed
@export var transition_duration_fast: float = 0.15                 # Quick transitions
@export var transition_duration_normal: float = 0.3                # Standard transitions
@export var transition_duration_slow: float = 0.5                  # Slow transitions

# Accessibility features - Following UI_RULES.md accessibility requirements
@export_group("Accessibility")
@export var high_contrast_mode: bool = false                       # Enhanced contrast
@export var large_text_mode: bool = false                          # Increased font sizes
@export var reduced_motion: bool = false                           # Minimal animations
@export var focus_outline_width: int = 2                           # Focus indicator width
@export var focus_outline_color: Color = Color.CYAN                # Focus indicator color

# Platform adaptations
@export_group("Platform")
@export var mobile_optimized: bool = false                         # Touch-friendly sizing
@export var gamepad_optimized: bool = false                        # Controller navigation
@export var desktop_optimized: bool = true                         # Mouse/keyboard

# Validation and helpers
func is_valid() -> bool:
	"""Validate theme configuration completeness"""
	if theme_name.is_empty():
		return false
	
	if not font_primary:
		return false
	
	# Validate color contrast for accessibility
	if is_accessibility_theme:
		return validate_accessibility_compliance()
	
	return true

func validate_accessibility_compliance() -> bool:
	"""Validate accessibility compliance for high contrast themes"""
	# Check contrast ratios (simplified validation)
	var bg_luminance = get_color_luminance(background_color)
	var text_luminance = get_color_luminance(text_primary)
	
	# WCAG AA requires 4.5:1 contrast ratio for normal text
	var contrast_ratio = (max(bg_luminance, text_luminance) + 0.05) / (min(bg_luminance, text_luminance) + 0.05)
	
	return contrast_ratio >= 4.5

func get_color_luminance(color: Color) -> float:
	"""Calculate relative luminance of a color for contrast checking"""
	# Simplified luminance calculation
	return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b

func get_validation_errors() -> Array[String]:
	"""Get list of validation errors for debugging"""
	var errors: Array[String] = []
	
	if theme_name.is_empty():
		errors.append("Theme name is required")
	
	if not font_primary:
		errors.append("Primary font is required")
	
	if is_accessibility_theme and not validate_accessibility_compliance():
		errors.append("Accessibility theme does not meet contrast requirements")
	
	return errors

func get_debug_info() -> Dictionary:
	"""Get comprehensive theme information for debugging"""
	return {
		"theme_name": theme_name,
		"is_valid": is_valid(),
		"validation_errors": get_validation_errors(),
		"color_scheme": {
			"primary": primary_color,
			"background": background_color,
			"text": text_primary
		},
		"typography": {
			"font_primary": font_primary.resource_path if font_primary else "none",
			"base_size": font_size_base
		},
		"accessibility": {
			"high_contrast": high_contrast_mode,
			"large_text": large_text_mode,
			"reduced_motion": reduced_motion
		},
		"platform": {
			"mobile": mobile_optimized,
			"desktop": desktop_optimized
		}
	}

# Theme application helpers
func get_button_style_normal() -> StyleBoxFlat:
	"""Create button normal state StyleBox from theme colors"""
	var style = StyleBoxFlat.new()
	style.bg_color = button_normal
	style.corner_radius_top_left = button_radius
	style.corner_radius_top_right = button_radius
	style.corner_radius_bottom_left = button_radius
	style.corner_radius_bottom_right = button_radius
	return style

func get_button_style_hover() -> StyleBoxFlat:
	"""Create button hover state StyleBox from theme colors"""
	var style = StyleBoxFlat.new()
	style.bg_color = button_hover
	style.corner_radius_top_left = button_radius
	style.corner_radius_top_right = button_radius
	style.corner_radius_bottom_left = button_radius
	style.corner_radius_bottom_right = button_radius
	return style

func get_button_style_pressed() -> StyleBoxFlat:
	"""Create button pressed state StyleBox from theme colors"""
	var style = StyleBoxFlat.new()
	style.bg_color = button_pressed
	style.corner_radius_top_left = button_radius
	style.corner_radius_top_right = button_radius
	style.corner_radius_bottom_left = button_radius
	style.corner_radius_bottom_right = button_radius
	return style

func get_panel_style() -> StyleBoxFlat:
	"""Create panel StyleBox from theme colors"""
	var style = StyleBoxFlat.new()
	style.bg_color = background_color
	style.corner_radius_top_left = panel_radius
	style.corner_radius_top_right = panel_radius
	style.corner_radius_bottom_left = panel_radius
	style.corner_radius_bottom_right = panel_radius
	return style

func create_theme_resource() -> Theme:
	"""Create Godot Theme resource from UIThemeConfig settings"""
	var theme = Theme.new()
	
	# Apply button styles
	theme.set_stylebox("normal", "Button", get_button_style_normal())
	theme.set_stylebox("hover", "Button", get_button_style_hover())
	theme.set_stylebox("pressed", "Button", get_button_style_pressed())
	theme.set_color("font_color", "Button", text_primary)
	
	# Apply panel styles
	theme.set_stylebox("panel", "Panel", get_panel_style())
	
	# Apply label styles
	theme.set_color("font_color", "Label", text_primary)
	if font_primary:
		theme.set_font("font", "Label", font_primary)
		theme.set_font_size("font_size", "Label", font_size_base)
	
	# Apply input styles
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = surface_color
	input_style.border_color = primary_color
	input_style.border_width_left = 1
	input_style.border_width_right = 1
	input_style.border_width_top = 1
	input_style.border_width_bottom = 1
	input_style.corner_radius_top_left = button_radius
	input_style.corner_radius_top_right = button_radius
	input_style.corner_radius_bottom_left = button_radius
	input_style.corner_radius_bottom_right = button_radius
	
	theme.set_stylebox("normal", "LineEdit", input_style)
	theme.set_color("font_color", "LineEdit", text_primary)
	
	return theme 