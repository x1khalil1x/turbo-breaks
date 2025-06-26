extends Node

## UIThemeManager - Phase 1 Implementation
## Runtime theme switching, accessibility features, and UI styling coordination
## Based on UI_RULES.md - Foundation First Approach

# Theme system
var current_theme_name: String = "default"
var available_themes: Dictionary = {}  # theme_name -> theme_resource_path
var current_theme: Theme = null
var current_theme_config: UIThemeConfig = null  # Phase 2B: Store theme configuration

# Accessibility settings
var accessibility_scale: float = 1.0
var high_contrast_enabled: bool = false
var reduced_motion_enabled: bool = false
var screen_reader_enabled: bool = false

# Theme application tracking
var registered_ui_components: Array[Node] = []

# Signals for theme changes
signal theme_changed(theme_name: String, theme_resource: Theme)
signal theme_config_changed(theme_config: UIThemeConfig)  # Phase 2B: New signal for config changes
signal accessibility_settings_changed(settings: Dictionary)

func _ready():
	print("UIThemeManager: Phase 1 initialized")
	
	# Initialize default themes
	initialize_default_themes()
	
	# Load default theme
	switch_theme("default")
	
	# Connect to existing systems - wait for next frame to ensure autoloads are ready
	await get_tree().process_frame
	if DebugManager:
		DebugManager.log_info("UIThemeManager: Theme system ready")
	else:
		print("UIThemeManager: DebugManager not available - continuing without logging")

func initialize_default_themes():
	"""Initialize built-in theme definitions"""
	# For Phase 1: Define theme resource paths
	# TODO Phase 2: Load actual .tres resources from data/ui/themes/
	
	available_themes = {
		"default": "res://data/ui/themes/default_theme.tres",
		"high_contrast": "res://data/ui/themes/high_contrast.tres", 
		"mobile": "res://data/ui/themes/mobile_theme.tres",
		"retro": "res://data/ui/themes/retro_theme.tres"
	}
	
	DebugManager.log_info("UIThemeManager: Initialized " + str(available_themes.size()) + " theme definitions")

func load_theme_config(theme_path: String) -> UIThemeConfig:
	"""Load UIThemeConfig resource from file path"""
	if not FileAccess.file_exists(theme_path):
		DebugManager.log_error("UIThemeManager: Theme file not found: " + theme_path)
		return null
	
	var resource = load(theme_path)
	if resource is UIThemeConfig:
		DebugManager.log_info("UIThemeManager: Loaded theme config from " + theme_path)
		return resource
	else:
		DebugManager.log_error("UIThemeManager: Invalid theme resource type at " + theme_path)
		return null

func apply_theme_accessibility_settings(theme_config: UIThemeConfig):
	"""Apply accessibility settings from theme configuration"""
	if theme_config.high_contrast_mode != high_contrast_enabled:
		high_contrast_enabled = theme_config.high_contrast_mode
	
	if theme_config.large_text_mode != (accessibility_scale > 1.0):
		accessibility_scale = 1.2 if theme_config.large_text_mode else 1.0
	
	if theme_config.reduced_motion != reduced_motion_enabled:
		reduced_motion_enabled = theme_config.reduced_motion
	
	# Emit accessibility change signal
	emit_accessibility_changed()
	
	DebugManager.log_info("UIThemeManager: Applied accessibility settings from theme")

func switch_theme(theme_name: String) -> bool:
	"""Switch to a different theme with validation"""
	if not theme_name in available_themes:
		DebugManager.log_warning("UIThemeManager: Unknown theme requested: " + theme_name)
		return false
	
	var theme_path = available_themes[theme_name]
	
	# Phase 2B: Load from actual UIThemeConfig resource files
	var theme_config = load_theme_config(theme_path)
	if not theme_config:
		DebugManager.log_warning("UIThemeManager: Failed to load theme config, using fallback")
		var fallback_theme = create_fallback_theme(theme_name)
		if fallback_theme:
			current_theme = fallback_theme
			current_theme_name = theme_name
			apply_theme_to_components()
			theme_changed.emit(theme_name, current_theme)
			return true
		return false
	
	# Validate theme config
	if not theme_config.is_valid():
		var errors = theme_config.get_validation_errors()
		DebugManager.log_error("UIThemeManager: Theme validation failed: " + str(errors))
		return false
	
	# Create Godot Theme from UIThemeConfig
	var new_theme = theme_config.create_theme_resource()
	if new_theme:
		current_theme = new_theme
		current_theme_name = theme_name
		
		# Store the config for advanced features
		current_theme_config = theme_config
		
		# Apply accessibility settings from theme
		apply_theme_accessibility_settings(theme_config)
		
		# Apply to all registered components
		apply_theme_to_components()
		
		# Emit change signal with both theme and config
		theme_changed.emit(theme_name, current_theme)
		theme_config_changed.emit(theme_config)
		
		DebugManager.log_info("UIThemeManager: Switched to theme '" + theme_name + "' (Phase 2B)")
		return true
	else:
		DebugManager.log_error("UIThemeManager: Failed to create theme resource from config")
		return false

func create_fallback_theme(theme_name: String) -> Theme:
	"""Create a basic theme programmatically for Phase 1"""
	var theme = Theme.new()
	
	# Base colors for different themes
	var color_schemes = {
		"default": {
			"background": Color(0.2, 0.2, 0.3, 0.9),
			"primary": Color(0.4, 0.6, 0.8),
			"text": Color.WHITE,
			"accent": Color(0.8, 0.6, 0.2)
		},
		"high_contrast": {
			"background": Color.BLACK,
			"primary": Color.WHITE,
			"text": Color.WHITE,
			"accent": Color.YELLOW
		},
		"mobile": {
			"background": Color(0.15, 0.15, 0.2, 0.95),
			"primary": Color(0.3, 0.7, 0.9),
			"text": Color.WHITE,
			"accent": Color(0.9, 0.5, 0.3)
		},
		"retro": {
			"background": Color(0.1, 0.3, 0.1),
			"primary": Color(0.2, 0.8, 0.2),
			"text": Color(0.8, 1.0, 0.8),
			"accent": Color(1.0, 0.8, 0.2)
		}
	}
	
	var colors = color_schemes.get(theme_name, color_schemes["default"])
	
	# Apply basic styling
	apply_basic_theme_colors(theme, colors)
	
	return theme

func apply_basic_theme_colors(theme: Theme, colors: Dictionary):
	"""Apply color scheme to theme resource"""
	# Button styling
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = colors["primary"]
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	
	theme.set_stylebox("normal", "Button", button_style)
	theme.set_color("font_color", "Button", colors["text"])
	
	# Panel styling
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = colors["background"]
	theme.set_stylebox("panel", "Panel", panel_style)
	
	# Label styling
	theme.set_color("font_color", "Label", colors["text"])

func register_ui_component(component: Node):
	"""Register UI component for theme updates"""
	if not component in registered_ui_components:
		registered_ui_components.append(component)
		
		# Apply current theme immediately
		apply_theme_to_component(component)
		
		DebugManager.log_debug("UIThemeManager: Registered component " + component.name)

func unregister_ui_component(component: Node):
	"""Unregister UI component"""
	if component in registered_ui_components:
		registered_ui_components.erase(component)
		DebugManager.log_debug("UIThemeManager: Unregistered component " + component.name)

func apply_theme_to_components():
	"""Apply current theme to all registered components"""
	var applied_count = 0
	
	for component in registered_ui_components:
		if is_instance_valid(component):
			apply_theme_to_component(component)
			applied_count += 1
		else:
			# Remove invalid references
			registered_ui_components.erase(component)
	
	DebugManager.log_info("UIThemeManager: Applied theme to " + str(applied_count) + " components")

func apply_theme_to_component(component: Node):
	"""Apply current theme to a specific component"""
	if not current_theme:
		return
	
	# Apply theme based on component type
	if component is Control:
		component.theme = current_theme
		
		# Handle accessibility scaling
		if accessibility_scale != 1.0:
			apply_accessibility_scaling(component)
		
		# Call component's theme update method if it exists
		if component.has_method("apply_theme_changes"):
			component.apply_theme_changes(current_theme)

func apply_accessibility_scaling(control: Control):
	"""Apply accessibility scaling to UI component"""
	if control is Label:
		# Scale font size
		var original_size = control.get_theme_font_size("font_size")
		if original_size > 0:
			control.add_theme_font_size_override("font_size", int(original_size * accessibility_scale))
	
	if control is Button:
		# Scale button elements
		var original_size = control.get_theme_font_size("font_size")
		if original_size > 0:
			control.add_theme_font_size_override("font_size", int(original_size * accessibility_scale))

# Accessibility management
func set_accessibility_scale(scale: float):
	"""Set UI scaling for accessibility"""
	accessibility_scale = clamp(scale, 0.5, 2.0)
	apply_theme_to_components()  # Reapply to update scaling
	
	emit_accessibility_changed()
	DebugManager.log_info("UIThemeManager: Accessibility scale set to " + str(accessibility_scale))

func set_high_contrast(enabled: bool):
	"""Enable/disable high contrast mode"""
	high_contrast_enabled = enabled
	
	if enabled and current_theme_name != "high_contrast":
		switch_theme("high_contrast")
	elif not enabled and current_theme_name == "high_contrast":
		switch_theme("default")
	
	emit_accessibility_changed()

func set_reduced_motion(enabled: bool):
	"""Enable/disable reduced motion for accessibility"""
	reduced_motion_enabled = enabled
	emit_accessibility_changed()
	DebugManager.log_info("UIThemeManager: Reduced motion " + ("enabled" if enabled else "disabled"))

func emit_accessibility_changed():
	"""Emit accessibility settings change signal"""
	var settings = {
		"scale": accessibility_scale,
		"high_contrast": high_contrast_enabled,
		"reduced_motion": reduced_motion_enabled,
		"screen_reader": screen_reader_enabled
	}
	accessibility_settings_changed.emit(settings)

# Public API
func get_available_themes() -> Array[String]:
	"""Get list of available theme names"""
	return available_themes.keys()

func get_current_theme_name() -> String:
	"""Get current theme name"""
	return current_theme_name

func get_current_theme() -> Theme:
	"""Get current theme resource"""
	return current_theme

func get_current_theme_config() -> UIThemeConfig:
	"""Get current theme configuration (Phase 2B)"""
	return current_theme_config

func get_accessibility_settings() -> Dictionary:
	"""Get current accessibility settings"""
	return {
		"scale": accessibility_scale,
		"high_contrast": high_contrast_enabled,
		"reduced_motion": reduced_motion_enabled,
		"screen_reader": screen_reader_enabled
	}

# Debug and validation
func validate_theme_system():
	"""Validate theme system integrity"""
	DebugManager.log_info("=== UI THEME VALIDATION (Phase 2B) ===")
	
	DebugManager.log_info("Current theme: " + current_theme_name)
	DebugManager.log_info("Available themes: " + str(available_themes.keys()))
	DebugManager.log_info("Registered components: " + str(registered_ui_components.size()))
	DebugManager.log_info("Accessibility scale: " + str(accessibility_scale))
	DebugManager.log_info("High contrast: " + str(high_contrast_enabled))
	
	# Validate current theme config
	if current_theme_config:
		DebugManager.log_info("Theme config loaded: " + current_theme_config.theme_name)
		DebugManager.log_info("Theme valid: " + str(current_theme_config.is_valid()))
		
		var errors = current_theme_config.get_validation_errors()
		if errors.size() > 0:
			DebugManager.log_warning("Theme validation errors: " + str(errors))
		
		# Log theme debug info
		var debug_info = current_theme_config.get_debug_info()
		DebugManager.log_info("Theme debug info: " + str(debug_info))
	else:
		DebugManager.log_warning("No theme config loaded (using fallback)")
	
	# Validate all available theme files
	for theme_name in available_themes.keys():
		var theme_path = available_themes[theme_name]
		if FileAccess.file_exists(theme_path):
			DebugManager.log_info("Theme file exists: " + theme_name + " -> " + theme_path)
		else:
			DebugManager.log_error("Theme file missing: " + theme_name + " -> " + theme_path)
	
	# Validate component references
	var valid_components = 0
	for component in registered_ui_components:
		if is_instance_valid(component):
			valid_components += 1
	
	if valid_components != registered_ui_components.size():
		DebugManager.log_warning("Some registered components are invalid")
	
	DebugManager.log_info("=== UI THEME VALIDATION COMPLETE ===")

# Development helpers
func cycle_themes_for_testing():
	"""Debug function to cycle through themes"""
	var theme_names = get_available_themes()
	var current_index = theme_names.find(current_theme_name)
	var next_index = (current_index + 1) % theme_names.size()
	
	switch_theme(theme_names[next_index])
	DebugManager.log_info("UIThemeManager: Cycled to theme " + theme_names[next_index]) 