extends BaseUIPanel
class_name NotificationToast

## NotificationToast - Individual notification display component
## Based on UI_RULES.md - Component Composition and Notification System
## Displays notifications from NotificationManager with auto-dismiss and user interaction

# Component references
@onready var notification_content = $ContentContainer/Content/Body/NotificationContent
@onready var icon_container = $ContentContainer/Content/Body/NotificationContent/IconContainer
@onready var icon = $ContentContainer/Content/Body/NotificationContent/IconContainer/Icon
@onready var message_container = $ContentContainer/Content/Body/NotificationContent/MessageContainer
@onready var title_label = $ContentContainer/Content/Body/NotificationContent/MessageContainer/Title
@onready var message_label = $ContentContainer/Content/Body/NotificationContent/MessageContainer/Message
@onready var action_container = $ContentContainer/Content/Body/NotificationContent/ActionContainer
@onready var close_btn = $ContentContainer/Content/Body/NotificationContent/ActionContainer/CloseButton

# Notification configuration
@export_group("Notification Settings")
@export var notification_type: NotificationManager.NotificationType = NotificationManager.NotificationType.INFO
@export var auto_dismiss_duration: float = 4.0
@export var show_close_button: bool = true
@export var show_icon: bool = true

# Notification data
var notification_id: String = ""
var notification_data: Dictionary = {}
var dismiss_timer: Timer = null

# Type-specific styling
var type_colors = {
	NotificationManager.NotificationType.INFO: Color(0.3, 0.7, 0.9),      # Blue
	NotificationManager.NotificationType.SUCCESS: Color(0.4, 0.8, 0.4),   # Green
	NotificationManager.NotificationType.WARNING: Color(1.0, 0.8, 0.2),   # Yellow
	NotificationManager.NotificationType.ERROR: Color(0.9, 0.3, 0.3),     # Red
	NotificationManager.NotificationType.DEBUG: Color(0.7, 0.7, 0.7)      # Gray
}

# Signals following UI_RULES.md contract
signal notification_dismissed(notification_id: String)
signal notification_clicked(notification_id: String, notification_data: Dictionary)

func _ready():
	super._ready()  # Call BaseUIPanel._ready()
	
	# Setup notification-specific behavior
	setup_notification_display()
	
	# Connect signals
	setup_notification_signals()
	
	# Configure auto-dismiss
	if auto_dismiss_duration > 0:
		setup_auto_dismiss()

func setup_notification_display():
	"""Setup notification display configuration"""
	# Configure close button visibility
	if close_btn:
		close_btn.visible = show_close_button
	
	# Configure icon visibility
	if icon_container:
		icon_container.visible = show_icon
	
	# Set up notification styling based on type
	apply_notification_styling()

func setup_notification_signals():
	"""Setup notification-specific signal connections"""
	if close_btn:
		close_btn.pressed.connect(_on_close_button_pressed)
	
	# Make the entire notification clickable for interaction
	if notification_content:
		notification_content.gui_input.connect(_on_notification_clicked)

func setup_auto_dismiss():
	"""Setup automatic dismissal timer"""
	dismiss_timer = Timer.new()
	dismiss_timer.wait_time = auto_dismiss_duration
	dismiss_timer.one_shot = true
	dismiss_timer.timeout.connect(_on_auto_dismiss_timeout)
	add_child(dismiss_timer)

func apply_notification_styling():
	"""Apply styling based on notification type"""
	var type_color = type_colors.get(notification_type, type_colors[NotificationManager.NotificationType.INFO])
	
	# Apply type color to panel background with transparency
	var background_color = type_color
	background_color.a = 0.9
	
	# This will be applied through the theme system
	modulate = Color.WHITE  # Reset modulate, let theme handle colors

# Public API for NotificationManager
func configure_notification(data: Dictionary):
	"""Configure notification with data from NotificationManager"""
	notification_data = data
	notification_id = data.get("id", "")
	
	# Set notification type
	if data.has("type"):
		notification_type = data["type"]
		apply_notification_styling()
	
	# Set content
	if data.has("title") and title_label:
		title_label.text = data["title"]
		title_label.visible = true
	else:
		if title_label:
			title_label.visible = false
	
	if data.has("message") and message_label:
		message_label.text = data["message"]
	
	# Configure duration
	if data.has("duration"):
		auto_dismiss_duration = data["duration"]
		if dismiss_timer:
			dismiss_timer.wait_time = auto_dismiss_duration
	
	# Set icon if provided
	if data.has("icon_texture") and icon and show_icon:
		icon.texture = data["icon_texture"]
		icon_container.visible = true
	else:
		# Use default type-based icon (could be implemented with UI tile sheet)
		setup_default_icon()

func setup_default_icon():
	"""Setup default icon based on notification type"""
	# This would use your UI tile sheet for icons
	# For now, we'll use text-based icons
	if not icon:
		return
	
	# This is where you'd load icons from your Modern_UI_Style_2_32x32.png
	# For now, using simple text representation
	var icon_text = ""
	match notification_type:
		NotificationManager.NotificationType.INFO:
			icon_text = "ℹ"
		NotificationManager.NotificationType.SUCCESS:
			icon_text = "✓"
		NotificationManager.NotificationType.WARNING:
			icon_text = "⚠"
		NotificationManager.NotificationType.ERROR:
			icon_text = "✗"
		NotificationManager.NotificationType.DEBUG:
			icon_text = "🔧"
	
	# Create a simple label for the icon (temporary solution)
	if icon_container.get_child_count() == 1:  # Only the TextureRect
		var icon_label = Label.new()
		icon_label.text = icon_text
		icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_label.add_theme_font_size_override("font_size", 20)
		icon_container.add_child(icon_label)
		icon.visible = false  # Hide texture rect, use label

func show_notification():
	"""Display the notification with animation"""
	# Start auto-dismiss timer
	if dismiss_timer and auto_dismiss_duration > 0:
		dismiss_timer.start()
	
	# Show with animation from BaseUIPanel
	show_panel_animated()

func dismiss_notification(reason: String = "manual"):
	"""Dismiss the notification with animation"""
	# Stop auto-dismiss timer
	if dismiss_timer:
		dismiss_timer.stop()
	
	# Hide with animation from BaseUIPanel
	hide_panel_animated({"reason": reason, "id": notification_id})
	
	# Emit dismissal signal
	notification_dismissed.emit(notification_id)
	
	# Clean up after animation
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = fade_in_duration + 0.1
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(_cleanup_notification)
	add_child(cleanup_timer)
	cleanup_timer.start()

func _cleanup_notification():
	"""Clean up notification after animation completes"""
	queue_free()

# Theme Integration
func apply_theme_changes(theme_config: UIThemeConfig):
	"""Apply theme changes with notification-specific styling"""
	super.apply_theme_changes(theme_config)  # Call BaseUIPanel implementation
	
	if not theme_config:
		return
	
	# Apply notification-specific theme elements
	apply_notification_theme_colors(theme_config)
	apply_notification_typography(theme_config)

func apply_notification_theme_colors(theme_config: UIThemeConfig):
	"""Apply notification-specific color theming"""
	var base_color = type_colors.get(notification_type, theme_config.info_color)
	
	# Panel background with type color
	var bg_color = base_color
	bg_color.a = 0.95
	
	# Text colors based on contrast with background
	var text_color = theme_config.text_primary
	if get_color_luminance(bg_color) > 0.5:
		text_color = theme_config.text_inverse
	
	if title_label:
		title_label.add_theme_color_override("font_color", text_color)
	
	if message_label:
		message_label.add_theme_color_override("font_color", text_color)

func apply_notification_typography(theme_config: UIThemeConfig):
	"""Apply notification-specific typography"""
	if title_label and theme_config.font_primary:
		title_label.add_theme_font_override("font", theme_config.font_primary)
		title_label.add_theme_font_size_override("font_size", theme_config.font_size_base + 2)
	
	if message_label and theme_config.font_primary:
		message_label.add_theme_font_override("font", theme_config.font_primary)
		message_label.add_theme_font_size_override("font_size", theme_config.font_size_small)

func get_color_luminance(color: Color) -> float:
	"""Calculate color luminance for contrast checking"""
	return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b

# Input Handling
func _on_notification_clicked(event: InputEvent):
	"""Handle notification click for interaction"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		notification_clicked.emit(notification_id, notification_data)
		
		# Dismiss on click if configured
		if notification_data.get("dismiss_on_click", false):
			dismiss_notification("clicked")

func _on_close_button_pressed():
	"""Handle close button press"""
	dismiss_notification("close_button")

func _on_auto_dismiss_timeout():
	"""Handle automatic dismissal timeout"""
	dismiss_notification("auto_timeout")

# Utility Functions
func get_notification_height() -> float:
	"""Get the height needed for this notification"""
	return size.y

func is_expired() -> bool:
	"""Check if notification should be automatically dismissed"""
	return dismiss_timer and dismiss_timer.is_stopped() and auto_dismiss_duration > 0

# Debug and Validation
func get_notification_debug_info() -> Dictionary:
	"""Get debug information about this notification"""
	return {
		"id": notification_id,
		"type": NotificationManager.NotificationType.keys()[notification_type],
		"auto_dismiss": auto_dismiss_duration,
		"timer_active": dismiss_timer != null and not dismiss_timer.is_stopped(),
		"visible": visible,
		"data": notification_data
	}

# SCENE_TAG: UI_NOTIFICATION_TOAST - for notification system routing
const SCENE_TAGS = ["UI_NOTIFICATION_TOAST", "UI_ANIMATED", "UI_THEME_AWARE"] 