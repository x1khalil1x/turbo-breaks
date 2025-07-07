extends Node

## UIThemeManager - Production Implementation
## Runtime theme switching with code-based theme configurations
## Fixes all issues that caused the fallback system

# Theme system
var current_theme_name: String = "default"
var available_themes: Dictionary = {}  # theme_name -> theme_resource_path
var current_theme: Theme = null
var current_theme_config: UIThemeConfig = null

# Accessibility settings
var accessibility_scale: float = 1.0
var high_contrast_enabled: bool = false
var reduced_motion_enabled: bool = false
var screen_reader_enabled: bool = false

# Component registration with safety guards
var registered_ui_components: Array[Node] = []
var registration_in_progress: bool = false
var pending_registrations: Array[Node] = []
var theme_application_in_progress: bool = false

# Signals for theme changes - FIXED: Restored missing signal
signal theme_changed(theme_name: String, theme_resource: Theme)
signal theme_config_changed(theme_config: UIThemeConfig)  # RESTORED: This was missing and causing crashes
signal accessibility_settings_changed(settings: Dictionary)

func _ready():
	print("UIThemeManager: Production implementation initializing...")
	
	# Initialize available themes
	initialize_default_themes()
	
	# Load default theme with comprehensive error handling
	print("UIThemeManager: Loading default theme with code-based system...")
	var success = switch_theme("default")
	if not success:
		print("UIThemeManager: ERROR - Code-based theme loading failed!")
		# This shouldn't happen with code-based themes
		current_theme = Theme.new()
		current_theme_name = "error"
		print("UIThemeManager: Emergency fallback theme created")
	
	# Connect to existing systems - wait for next frame to ensure autoloads are ready
	await get_tree().process_frame
	
	# Process any pending registrations
	process_pending_registrations()
	
	if DebugManager:
		DebugManager.log_info("UIThemeManager: Production theme system ready")
	else:
		print("UIThemeManager: Production theme system ready")

func initialize_default_themes():
	"""Initialize code-based theme configurations"""
	available_themes = {}
	
	# Create all theme configurations in code
	available_themes["default"] = create_default_theme()
	available_themes["high_contrast"] = create_high_contrast_theme()
	available_themes["mobile"] = create_mobile_theme()
	available_themes["retro"] = create_retro_theme()
	available_themes["tech"] = create_tech_theme()
	
	if DebugManager:
		DebugManager.log_info("UIThemeManager: Created " + str(available_themes.size()) + " code-based themes")
	else:
		print("UIThemeManager: Created " + str(available_themes.size()) + " code-based themes")

func switch_theme(theme_name: String) -> bool:
	"""Switch to a different theme using code-based configurations"""
	if not theme_name in available_themes:
		if DebugManager:
			DebugManager.log_warning("UIThemeManager: Unknown theme requested: " + theme_name)
		else:
			print("UIThemeManager: Unknown theme requested: " + theme_name)
		return false
	
	# Get theme configuration from code-based themes
	var theme_config = available_themes[theme_name]
	
	if theme_config and theme_config.is_valid():
		print("UIThemeManager: Applying code-based theme: " + theme_config.theme_name)
		current_theme_config = theme_config
		current_theme = theme_config.create_theme_resource()
		current_theme_name = theme_name
		
		# Apply accessibility settings from theme
		apply_theme_accessibility_settings(theme_config)
		
		# Apply theme to all registered components (async but don't block)
		apply_theme_to_components_async()
		
		# Emit signals
		theme_changed.emit(theme_name, current_theme)
		theme_config_changed.emit(theme_config)
		
		print("UIThemeManager: Successfully applied theme: " + theme_name)
		return true
	else:
		print("UIThemeManager: Invalid theme configuration for: " + theme_name)
		return false

# CODE-BASED THEME CREATION FUNCTIONS

func create_default_theme() -> UIThemeConfig:
	"""Create the default theme configuration"""
	var theme = UIThemeConfig.new()
	theme.theme_name = "default"
	theme.theme_description = "Default theme with blue accent colors"
	
	# Primary colors
	theme.primary_color = Color(0.557, 0.808, 0.902)      # Light blue
	theme.secondary_color = Color(0.251, 0.471, 0.549)    # Dark blue
	theme.background_color = Color(0.102, 0.102, 0.102)   # Dark gray
	theme.surface_color = Color(0.15, 0.15, 0.15)         # Light gray
	
	# Text colors
	theme.text_primary = Color.WHITE
	theme.text_secondary = Color(0.8, 0.8, 0.8)
	theme.text_disabled = Color(0.5, 0.5, 0.5)
	theme.text_inverse = Color.BLACK
	
	# Interactive colors
	theme.button_normal = Color(0.4, 0.6, 0.8)
	theme.button_hover = Color(0.5, 0.7, 0.9)
	theme.button_pressed = Color(0.3, 0.5, 0.7)
	theme.button_disabled = Color(0.3, 0.3, 0.3)
	
	# Load font
	theme.font_primary = load("res://fonts/Exo2-VariableFont_wght.ttf")
	
	return theme

func create_high_contrast_theme() -> UIThemeConfig:
	"""Create high contrast theme for accessibility"""
	var theme = UIThemeConfig.new()
	theme.theme_name = "high_contrast"
	theme.theme_description = "High contrast theme for accessibility"
	theme.is_accessibility_theme = true
	theme.high_contrast_mode = true
	
	# High contrast colors
	theme.primary_color = Color.CYAN
	theme.secondary_color = Color.YELLOW
	theme.background_color = Color.BLACK
	theme.surface_color = Color(0.1, 0.1, 0.1)
	
	# High contrast text
	theme.text_primary = Color.WHITE
	theme.text_secondary = Color.CYAN
	theme.text_disabled = Color.GRAY
	theme.text_inverse = Color.BLACK
	
	# High contrast interactive
	theme.button_normal = Color.WHITE
	theme.button_hover = Color.CYAN
	theme.button_pressed = Color.YELLOW
	theme.button_disabled = Color.GRAY
	
	# Load font
	theme.font_primary = load("res://fonts/Exo2-VariableFont_wght.ttf")
	
	return theme

func create_mobile_theme() -> UIThemeConfig:
	"""Create mobile-optimized theme"""
	var theme = UIThemeConfig.new()
	theme.theme_name = "mobile"
	theme.theme_description = "Mobile-optimized theme with larger touch targets"
	theme.mobile_optimized = true
	
	# Mobile-friendly colors
	theme.primary_color = Color(0.3, 0.7, 0.9)
	theme.secondary_color = Color(0.2, 0.5, 0.7)
	theme.background_color = Color(0.1, 0.1, 0.1)
	theme.surface_color = Color(0.15, 0.15, 0.15)
	
	# Standard text colors
	theme.text_primary = Color.WHITE
	theme.text_secondary = Color(0.8, 0.8, 0.8)
	theme.text_disabled = Color(0.5, 0.5, 0.5)
	theme.text_inverse = Color.BLACK
	
	# Interactive colors
	theme.button_normal = Color(0.3, 0.7, 0.9)
	theme.button_hover = Color(0.4, 0.8, 1.0)
	theme.button_pressed = Color(0.2, 0.6, 0.8)
	theme.button_disabled = Color(0.3, 0.3, 0.3)
	
	# Mobile-specific sizing
	theme.button_height = 48  # Larger touch targets
	theme.input_height = 44
	theme.ui_scale = 1.2
	
	# Load font
	theme.font_primary = load("res://fonts/Exo2-VariableFont_wght.ttf")
	
	return theme

func create_retro_theme() -> UIThemeConfig:
	"""Create retro-style theme"""
	var theme = UIThemeConfig.new()
	theme.theme_name = "retro"
	theme.theme_description = "Retro-style theme with classic colors"
	
	# Retro colors
	theme.primary_color = Color(0.8, 0.6, 0.2)      # Gold
	theme.secondary_color = Color(0.6, 0.4, 0.1)    # Brown
	theme.background_color = Color(0.05, 0.05, 0.05) # Near black
	theme.surface_color = Color(0.1, 0.08, 0.06)    # Dark brown
	
	# Text colors
	theme.text_primary = Color(0.9, 0.85, 0.7)      # Cream
	theme.text_secondary = Color(0.7, 0.6, 0.4)     # Tan
	theme.text_disabled = Color(0.4, 0.3, 0.2)      # Dark tan
	theme.text_inverse = Color.BLACK
	
	# Interactive colors
	theme.button_normal = Color(0.6, 0.4, 0.1)
	theme.button_hover = Color(0.8, 0.6, 0.2)
	theme.button_pressed = Color(0.4, 0.3, 0.1)
	theme.button_disabled = Color(0.3, 0.2, 0.1)
	
	# Load font
	theme.font_primary = load("res://fonts/Exo2-VariableFont_wght.ttf")
	
	return theme

func create_tech_theme() -> UIThemeConfig:
	"""Create tech/military theme matching the aircraft selection inspiration"""
	var theme = UIThemeConfig.new()
	theme.theme_name = "tech"
	theme.theme_description = "Modern tech/military theme with cyan accents and geometric design"
	
	# Tech/military colors inspired by the aircraft selection UI
	theme.primary_color = Color(0.0, 0.8, 1.0)      # Bright cyan
	theme.secondary_color = Color(0.0, 0.6, 0.8)    # Darker cyan
	theme.background_color = Color(0.05, 0.1, 0.15) # Dark blue-gray
	theme.surface_color = Color(0.1, 0.15, 0.2)     # Lighter blue-gray
	
	# Text colors - high contrast for readability
	theme.text_primary = Color(0.9, 0.95, 1.0)      # Cool white
	theme.text_secondary = Color(0.7, 0.8, 0.9)     # Light blue-gray
	theme.text_disabled = Color(0.4, 0.5, 0.6)      # Muted blue-gray
	theme.text_inverse = Color(0.1, 0.2, 0.3)       # Dark blue
	
	# State colors - tech/military palette
	theme.success_color = Color(0.0, 1.0, 0.6)      # Bright green
	theme.warning_color = Color(1.0, 0.8, 0.0)      # Amber
	theme.error_color = Color(1.0, 0.3, 0.2)        # Red alert
	theme.info_color = Color(0.0, 0.8, 1.0)         # Cyan info
	
	# Interactive colors - glowing effects
	theme.button_normal = Color(0.0, 0.6, 0.8)
	theme.button_hover = Color(0.0, 0.8, 1.0)       # Bright glow
	theme.button_pressed = Color(0.0, 0.4, 0.6)
	theme.button_disabled = Color(0.2, 0.3, 0.4)
	
	# Tech styling
	theme.panel_radius = 2                          # Sharp, geometric
	theme.button_radius = 2                         # Sharp buttons
	theme.ui_scale = 1.0
	
	# Enhanced spacing for modern look
	theme.spacing_medium = 12
	theme.spacing_large = 20
	theme.button_height = 42
	theme.input_height = 38
	
	# Modern UI effects - Enable for tech theme
	theme.glow_enabled = true
	theme.glow_color = Color(0.0, 0.8, 1.0)         # Cyan glow
	theme.glow_size = 6.0
	theme.glow_intensity = 2.0
	
	# Enhanced hover effects
	theme.hover_enabled = true
	theme.hover_lift_amount = 3.0                   # Subtle lift
	theme.hover_scale_factor = 1.03                 # Slight scale
	theme.hover_glow_boost = 1.5                    # Brighter glow on hover
	theme.hover_duration = 0.12                     # Snappy response
	
	# Dynamic background
	theme.background_effects_enabled = true
	theme.background_scroll_speed = 0.3
	theme.background_grid_opacity = 0.2
	
	# Load font
	theme.font_primary = load("res://fonts/Exo2-VariableFont_wght.ttf")
	
	return theme

func apply_theme_accessibility_settings(theme_config: UIThemeConfig):
	"""Apply accessibility settings from theme configuration"""
	if not theme_config:
		return
	
	var settings_changed = false
	
	if theme_config.high_contrast_mode != high_contrast_enabled:
		high_contrast_enabled = theme_config.high_contrast_mode
		settings_changed = true
	
	if theme_config.large_text_mode != (accessibility_scale > 1.0):
		accessibility_scale = 1.2 if theme_config.large_text_mode else 1.0
		settings_changed = true
	
	if theme_config.reduced_motion != reduced_motion_enabled:
		reduced_motion_enabled = theme_config.reduced_motion
		settings_changed = true
	
	if settings_changed:
		emit_accessibility_changed()
		if DebugManager:
			DebugManager.log_info("UIThemeManager: Applied accessibility settings from theme")
		else:
			print("UIThemeManager: Applied accessibility settings from theme")

func register_ui_component(component: Node):
	"""Register UI component with safety guards to prevent infinite loops"""
	if not component or not is_instance_valid(component):
		print("UIThemeManager: Attempted to register invalid component")
		return
	
	if component in registered_ui_components:
		return  # Already registered, prevent duplicates
	
	# SAFETY GUARD: Prevent registration during theme application
	if registration_in_progress or theme_application_in_progress:
		if not component in pending_registrations:
			pending_registrations.append(component)
			print("UIThemeManager: Queued component registration during theme application")
		return
	
	# Mark registration in progress to prevent circular calls
	registration_in_progress = true
	
	registered_ui_components.append(component)
	
	# Apply current theme immediately if available
	if current_theme:
		apply_theme_to_component_safe(component)
	
	registration_in_progress = false
	
	if DebugManager:
		DebugManager.log_debug("UIThemeManager: Registered component " + component.name)
	else:
		print("UIThemeManager: Registered component " + component.name)

func unregister_ui_component(component: Node):
	"""Unregister UI component with cleanup"""
	if component in registered_ui_components:
		registered_ui_components.erase(component)
	
	if component in pending_registrations:
		pending_registrations.erase(component)
	
	if DebugManager:
		@warning_ignore("incompatible_ternary")
		DebugManager.log_debug("UIThemeManager: Unregistered component " + (component.name if is_instance_valid(component) else "invalid"))

func apply_theme_to_components_async():
	"""Apply current theme to all registered components asynchronously"""
	if theme_application_in_progress:
		return  # Prevent recursive calls
	
	_apply_theme_to_components_internal()

func _apply_theme_to_components_internal():
	"""Internal async theme application"""
	theme_application_in_progress = true
	var applied_count = 0
	
	# Clean up invalid references first
	for i in range(registered_ui_components.size() - 1, -1, -1):
		var component = registered_ui_components[i]
		if not is_instance_valid(component):
			registered_ui_components.remove_at(i)
	
	# Apply theme to valid components
	for component in registered_ui_components:
		apply_theme_to_component_safe(component)
		applied_count += 1
	
	theme_application_in_progress = false
	
	# Process any pending registrations
	process_pending_registrations()
	
	if DebugManager:
		DebugManager.log_info("UIThemeManager: Applied theme to " + str(applied_count) + " components")
	else:
		print("UIThemeManager: Applied theme to " + str(applied_count) + " components")

func apply_theme_to_component_safe(component: Node):
	"""Apply current theme to a specific component with error handling"""
	if not is_instance_valid(component) or not current_theme:
		return
	
	# Apply theme based on component type
	if component is Control:
		component.theme = current_theme
		
		# Handle accessibility scaling
		if accessibility_scale != 1.0:
			apply_accessibility_scaling(component)
		
		# Handle RichTextLabel specific theming
		if component is RichTextLabel:
			apply_richtextlabel_theming(component)
		
		# Apply glow effects if enabled
		if current_theme_config and current_theme_config.glow_enabled:
			apply_glow_effects(component)
		
		# Call component's theme update method if it exists
		if component.has_method("apply_theme_changes"):
			if current_theme_config:
				component.apply_theme_changes(current_theme_config)
			else:
				component.apply_theme_changes(current_theme)

func apply_richtextlabel_theming(rtl: RichTextLabel):
	"""Apply enhanced theming to RichTextLabel components"""
	if not current_theme_config:
		return
	
	# Apply primary colors
	rtl.add_theme_color_override("default_color", current_theme_config.text_primary)
	rtl.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	
	# Apply font if available
	if current_theme_config.font_primary:
		rtl.add_theme_font_override("normal_font", current_theme_config.font_primary)
		rtl.add_theme_font_size_override("normal_font_size", current_theme_config.font_size_base)
	
	# Enhanced styling for RichTextLabel
	rtl.add_theme_color_override("selection_color", current_theme_config.primary_color)
	rtl.add_theme_color_override("font_outline_color", current_theme_config.secondary_color)

func apply_glow_effects(component: Control):
	"""Apply glow effects to UI components when enabled"""
	if not current_theme_config or not current_theme_config.glow_enabled:
		return
	
	# Apply glow via shadow/outline effects
	if component is Label or component is RichTextLabel:
		# Add subtle text glow
		component.add_theme_color_override("font_shadow_color", current_theme_config.glow_color)
		component.add_theme_constant_override("shadow_offset_x", 0)
		component.add_theme_constant_override("shadow_offset_y", 0)
		component.add_theme_constant_override("shadow_outline_size", int(current_theme_config.glow_size))
		
		# Add outline glow
		component.add_theme_color_override("font_outline_color", current_theme_config.glow_color)
		component.add_theme_constant_override("outline_size", max(1, int(current_theme_config.glow_size / 2)))
	
	elif component is Button:
		# Create glow effect for buttons using StyleBoxFlat
		var style_normal = component.get_theme_stylebox("normal")
		var style_hover = component.get_theme_stylebox("hover")
		
		if style_normal is StyleBoxFlat:
			var glow_style = style_normal.duplicate()
			glow_style.shadow_color = current_theme_config.glow_color
			glow_style.shadow_size = int(current_theme_config.glow_size)
			glow_style.shadow_offset = Vector2.ZERO
			component.add_theme_stylebox_override("normal", glow_style)
		
		if style_hover is StyleBoxFlat:
			var glow_style = style_hover.duplicate()
			glow_style.shadow_color = current_theme_config.glow_color * current_theme_config.glow_intensity
			glow_style.shadow_size = int(current_theme_config.glow_size * current_theme_config.hover_glow_boost)
			glow_style.shadow_offset = Vector2.ZERO
			component.add_theme_stylebox_override("hover", glow_style)
	
	elif component is Panel:
		# Apply glow to panels
		var style = component.get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			var glow_style = style.duplicate()
			glow_style.shadow_color = current_theme_config.glow_color
			glow_style.shadow_size = int(current_theme_config.glow_size)
			glow_style.shadow_offset = Vector2.ZERO
			component.add_theme_stylebox_override("panel", glow_style)

func process_pending_registrations():
	"""Process any registrations that were queued during theme application"""
	while pending_registrations.size() > 0:
		var component = pending_registrations.pop_front()
		if is_instance_valid(component) and not component in registered_ui_components:
			register_ui_component(component)

func apply_accessibility_scaling(control: Control):
	"""Apply accessibility scaling to UI component"""
	if control is Label:
		var original_size = control.get_theme_font_size("font_size")
		if original_size > 0:
			control.add_theme_font_size_override("font_size", int(original_size * accessibility_scale))
	
	if control is Button:
		var original_size = control.get_theme_font_size("font_size")
		if original_size > 0:
			control.add_theme_font_size_override("font_size", int(original_size * accessibility_scale))

# REMOVED: Old fallback theme functions - no longer needed with code-based themes

# Accessibility management
func set_accessibility_scale(scale: float):
	"""Set UI scaling for accessibility"""
	accessibility_scale = clamp(scale, 0.5, 2.0)
	apply_theme_to_components_async()  # Reapply to update scaling
	
	emit_accessibility_changed()
	if DebugManager:
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
	if DebugManager:
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
	var theme_names: Array[String] = []
	for key in available_themes.keys():
		theme_names.append(str(key))
	return theme_names

func get_current_theme_name() -> String:
	"""Get current theme name"""
	return current_theme_name

func get_current_theme() -> Theme:
	"""Get current theme resource"""
	return current_theme

func get_current_theme_config() -> UIThemeConfig:
	"""Get current theme configuration"""
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
	if DebugManager:
		DebugManager.log_info("=== UI THEME VALIDATION (Production) ===")
		DebugManager.log_info("Current theme: " + current_theme_name)
		DebugManager.log_info("Available themes: " + str(available_themes.keys()))
		DebugManager.log_info("Registered components: " + str(registered_ui_components.size()))
		DebugManager.log_info("Pending registrations: " + str(pending_registrations.size()))
		DebugManager.log_info("Theme config loaded: " + str(current_theme_config != null))
		
		if current_theme_config:
			DebugManager.log_info("Theme config valid: " + str(current_theme_config.is_valid()))
			var errors = current_theme_config.get_validation_errors()
			if errors.size() > 0:
				DebugManager.log_warning("Theme validation errors: " + str(errors))
		
		# Validate theme configurations
		for theme_name in available_themes.keys():
			var theme_config = available_themes[theme_name]
			if theme_config and theme_config.is_valid():
				DebugManager.log_info("Theme config valid: " + theme_name)
			else:
				DebugManager.log_error("Theme config invalid: " + theme_name)
		
		DebugManager.log_info("=== UI THEME VALIDATION COMPLETE ===")

# Development helpers
func cycle_themes_for_testing():
	"""Debug function to cycle through themes"""
	var theme_names = get_available_themes()
	var current_index = theme_names.find(current_theme_name)
	var next_index = (current_index + 1) % theme_names.size()
	
	switch_theme(theme_names[next_index])
	if DebugManager:
		DebugManager.log_info("UIThemeManager: Cycled to theme " + theme_names[next_index])
	else:
		print("UIThemeManager: Cycled to theme " + theme_names[next_index])

func force_reload_current_theme():
	"""Force reload the current theme for testing"""
	var theme_name = current_theme_name
	switch_theme(theme_name)

func test_code_based_themes():
	"""Test code-based theme system functionality"""
	print("=== CODE-BASED THEME SYSTEM TEST ===")
	
	# Test theme creation
	print("1. Testing theme creation...")
	var theme_names = ["default", "high_contrast", "mobile", "retro"]
	
	for theme_name in theme_names:
		if theme_name in available_themes:
			var theme_config = available_themes[theme_name]
			if theme_config and theme_config.is_valid():
				print("  ✅ " + theme_name + " theme created and valid")
			else:
				print("  ❌ " + theme_name + " theme invalid")
				if theme_config:
					print("    Errors: " + str(theme_config.get_validation_errors()))
		else:
			print("  ❌ " + theme_name + " theme not found in available_themes")
	
	# Test theme switching
	print("2. Testing theme switching...")
	var current_name = current_theme_name
	
	for theme_name in theme_names:
		if switch_theme(theme_name):
			print("  ✅ Successfully switched to " + theme_name)
		else:
			print("  ❌ Failed to switch to " + theme_name)
	
	# Restore original theme
	switch_theme(current_name)
	
	print("=== CODE-BASED THEME SYSTEM TEST COMPLETE ===")

func debug_class_registration():
	"""Debug function to check if UIThemeConfig is properly registered"""
	print("=== CLASS REGISTRATION DEBUG ===")
	
	# Test if we can create UIThemeConfig directly
	var test_config = UIThemeConfig.new()
	if test_config:
		test_config.theme_name = "test"
		print("✅ UIThemeConfig class creation: SUCCESS")
		print("✅ UIThemeConfig.new() works")
		print("✅ Setting properties works: " + test_config.theme_name)
	else:
		print("❌ UIThemeConfig class creation: FAILED")
	
	print("=== CLASS DEBUG COMPLETE ===")
	return test_config != null 
