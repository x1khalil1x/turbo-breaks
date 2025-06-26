extends Node

## NotificationManager - Phase 1 Implementation
## Global message queue, toast notifications, and alert system
## Based on UI_RULES.md - Notification and Alert Management

# Notification types and priorities
enum NotificationType { INFO, SUCCESS, WARNING, ERROR, DEBUG }
enum NotificationPriority { LOW, NORMAL, HIGH, URGENT }

# Notification data structure
class NotificationData:
	var id: String
	var type: NotificationType
	var priority: NotificationPriority
	var title: String
	var message: String
	var duration: float
	var timestamp: float
	var data: Dictionary
	var dismissible: bool
	
	func _init(p_id: String, p_type: NotificationType, p_title: String, p_message: String, p_duration: float = 3.0):
		id = p_id
		type = p_type
		title = p_title
		message = p_message
		duration = p_duration
		timestamp = Time.get_time_dict_from_system()["unix"]
		data = {}
		dismissible = true
		priority = NotificationPriority.NORMAL

# Notification queue and tracking
var notification_queue: Array[NotificationData] = []
var active_notifications: Dictionary = {}  # id -> NotificationData
var notification_history: Array[NotificationData] = []
var next_notification_id: int = 0

# Display settings
var max_concurrent_notifications: int = 5
var default_notification_duration: float = 3.0
var notification_pause_on_focus: bool = true

# UI integration
var notification_ui_component: Node = null
var notifications_enabled: bool = true

# Signals for UI updates
signal notification_added(notification: NotificationData)
signal notification_removed(notification: NotificationData)
# Removed unused signal - notification_updated
signal notification_queue_changed(queue_size: int)

func _ready():
	print("NotificationManager: Phase 1 initialized")
	
	# Set up notification processing
	set_process(true)
	
	# Connect to existing systems - wait for next frame to ensure autoloads are ready
	await get_tree().process_frame
	if DebugManager:
		DebugManager.log_info("NotificationManager: Global notification system ready")
	else:
		print("NotificationManager: DebugManager not available - continuing without logging")
	
	# Connect to UI state changes
	if UIStateManager:
		UIStateManager.ui_state_changed.connect(_on_ui_state_changed)
	else:
		print("NotificationManager: UIStateManager not available - UI state integration disabled")

func _process(_delta):
	"""Process notification queue and handle timeouts"""
	if not notifications_enabled:
		return
	
	# Process active notifications for expiration
	var notifications_to_remove = []
	for notification_id in active_notifications:
		var notif_data = active_notifications[notification_id]
		var current_time = Time.get_time_dict_from_system()["unix"]
		
		# Check if notification has expired
		if notif_data.duration > 0 and (current_time - notif_data.timestamp) >= notif_data.duration:
			notifications_to_remove.append(notification_id)
	
	# Remove expired notifications
	for notification_id in notifications_to_remove:
		remove_notification(notification_id)
	
	# Process queue to show new notifications
	process_notification_queue()

func process_notification_queue():
	"""Move notifications from queue to active display"""
	while notification_queue.size() > 0 and active_notifications.size() < max_concurrent_notifications:
		var notif_data = notification_queue.pop_front()
		show_notification(notif_data)
		
		notification_queue_changed.emit(notification_queue.size())

# Public notification API
func show_info(title: String, message: String, duration: float = -1) -> String:
	"""Show info notification"""
	return add_notification(NotificationType.INFO, title, message, duration)

func show_success(title: String, message: String, duration: float = -1) -> String:
	"""Show success notification"""
	return add_notification(NotificationType.SUCCESS, title, message, duration)

func show_warning(title: String, message: String, duration: float = -1) -> String:
	"""Show warning notification"""
	return add_notification(NotificationType.WARNING, title, message, duration)

func show_error(title: String, message: String, duration: float = -1) -> String:
	"""Show error notification"""
	return add_notification(NotificationType.ERROR, title, message, duration)

func show_debug(title: String, message: String, duration: float = -1) -> String:
	"""Show debug notification (only if debug enabled)"""
	if DebugManager and DebugManager.debug_enabled:
		return add_notification(NotificationType.DEBUG, title, message, duration)
	return ""

func add_notification(type: NotificationType, title: String, message: String, duration: float = -1, data: Dictionary = {}) -> String:
	"""Add notification to queue with validation"""
	if not notifications_enabled:
		return ""
	
	# Use default duration if not specified
	if duration < 0:
		duration = default_notification_duration
	
	# Generate unique ID
	var notification_id = "notif_" + str(next_notification_id)
	next_notification_id += 1
	
	# Create notification data
	var notif_data = NotificationData.new(notification_id, type, title, message, duration)
	notif_data.data = data
	
	# Set priority based on type
	match type:
		NotificationType.ERROR:
			notif_data.priority = NotificationPriority.URGENT
		NotificationType.WARNING:
			notif_data.priority = NotificationPriority.HIGH
		NotificationType.SUCCESS:
			notif_data.priority = NotificationPriority.NORMAL
		NotificationType.INFO:
			notif_data.priority = NotificationPriority.NORMAL
		NotificationType.DEBUG:
			notif_data.priority = NotificationPriority.LOW
	
	# Add to queue (sorted by priority)
	insert_notification_by_priority(notif_data)
	
	# Log for debugging
	DebugManager.log_info("NotificationManager: Added " + NotificationType.keys()[type] + " notification - " + title)
	
	notification_added.emit(notif_data)
	notification_queue_changed.emit(notification_queue.size())
	
	return notification_id

func insert_notification_by_priority(notif_data: NotificationData):
	"""Insert notification into queue based on priority"""
	var inserted = false
	
	for i in range(notification_queue.size()):
		if notif_data.priority > notification_queue[i].priority:
			notification_queue.insert(i, notif_data)
			inserted = true
			break
	
	if not inserted:
		notification_queue.append(notif_data)

func show_notification(notif_data: NotificationData):
	"""Display notification in active list"""
	active_notifications[notif_data.id] = notif_data
	
	# Update timestamp for display start
	notif_data.timestamp = Time.get_time_dict_from_system()["unix"]
	
	# Send to UI for display
	if notification_ui_component and notification_ui_component.has_method("display_notification"):
		notification_ui_component.display_notification(notif_data)
	
	DebugManager.log_info("NotificationManager: Showing notification - " + notif_data.title)

func remove_notification(notification_id: String) -> bool:
	"""Remove notification from display"""
	if not notification_id in active_notifications:
		return false
	
	var notif_data = active_notifications[notification_id]
	active_notifications.erase(notification_id)
	
	# Add to history
	notification_history.append(notif_data)
	
	# Keep history size manageable
	if notification_history.size() > 100:
		notification_history.pop_front()
	
	# Notify UI to remove display
	if notification_ui_component and notification_ui_component.has_method("remove_notification"):
		notification_ui_component.remove_notification(notification_id)
	
	notification_removed.emit(notif_data)
	DebugManager.log_debug("NotificationManager: Removed notification - " + notif_data.title)
	return true

func dismiss_notification(notification_id: String) -> bool:
	"""Manually dismiss a notification"""
	if notification_id in active_notifications:
		var notif_data = active_notifications[notification_id]
		if notif_data.dismissible:
			return remove_notification(notification_id)
	return false

func clear_all_notifications():
	"""Clear all active notifications"""
	var notifications_to_clear = active_notifications.keys()
	for notification_id in notifications_to_clear:
		remove_notification(notification_id)
	
	DebugManager.log_info("NotificationManager: Cleared all notifications")

# UI Integration
func register_notification_ui(ui_component: Node):
	"""Register UI component for notification display"""
	notification_ui_component = ui_component
	DebugManager.log_info("NotificationManager: Registered UI component for notifications")

func unregister_notification_ui():
	"""Unregister notification UI component"""
	notification_ui_component = null

# Settings and Configuration
func set_notifications_enabled(enabled: bool):
	"""Enable/disable notification system"""
	notifications_enabled = enabled
	
	if not enabled:
		clear_all_notifications()
		notification_queue.clear()
	
	DebugManager.log_info("NotificationManager: Notifications " + ("enabled" if enabled else "disabled"))

func set_max_concurrent_notifications(max_count: int):
	"""Set maximum concurrent notifications"""
	max_concurrent_notifications = clamp(max_count, 1, 10)
	DebugManager.log_info("NotificationManager: Max concurrent notifications set to " + str(max_concurrent_notifications))

func set_default_duration(duration: float):
	"""Set default notification duration"""
	default_notification_duration = clamp(duration, 1.0, 10.0)

# System Integration
func _on_ui_state_changed(new_state: UIStateManager.UIState, _previous_state: UIStateManager.UIState):
	"""Handle UI state changes for notification behavior"""
	match new_state:
		UIStateManager.UIState.LOADING:
			# Pause notifications during loading
			notification_pause_on_focus = true
		UIStateManager.UIState.GAMEPLAY:
			# Resume normal notification behavior
			notification_pause_on_focus = false
		UIStateManager.UIState.PAUSE:
			# Keep notifications visible but pause timers
			notification_pause_on_focus = true

# Zone discovery integration
func show_zone_discovered(zone_name: String, _discovery_method: String):
	"""Show zone discovery notification"""
	var title = "New Zone Discovered!"
	var message = "You have discovered: " + zone_name
	
	show_success(title, message, 5.0)

# Driving system integration
func show_checkpoint_reached(checkpoint_name: String, time: String):
	"""Show checkpoint notification for driving mode"""
	var title = "Checkpoint Reached"
	var message = checkpoint_name + " - Time: " + time
	
	show_info(title, message, 3.0)

# Public API
func get_active_notifications() -> Array[NotificationData]:
	"""Get all currently active notifications"""
	return active_notifications.values()

func get_notification_history() -> Array[NotificationData]:
	"""Get notification history"""
	return notification_history.duplicate()

func get_queue_size() -> int:
	"""Get current queue size"""
	return notification_queue.size()

func is_notification_active(notification_id: String) -> bool:
	"""Check if notification is currently active"""
	return notification_id in active_notifications

# Debug and validation
func validate_notification_system():
	"""Validate notification system integrity"""
	DebugManager.log_info("=== NOTIFICATION VALIDATION ===")
	
	DebugManager.log_info("Notifications enabled: " + str(notifications_enabled))
	DebugManager.log_info("Active notifications: " + str(active_notifications.size()))
	DebugManager.log_info("Queued notifications: " + str(notification_queue.size()))
	DebugManager.log_info("Notification history: " + str(notification_history.size()))
	DebugManager.log_info("UI component registered: " + str(notification_ui_component != null))
	
	# Check for notification timing issues
	var current_time = Time.get_time_dict_from_system()["unix"]
	for notification_id in active_notifications:
		var notif_data = active_notifications[notification_id]
		var elapsed = current_time - notif_data.timestamp
		if elapsed > notif_data.duration + 1.0:  # 1 second grace period
			DebugManager.log_warning("Notification may be stuck: " + notification_id)
	
	DebugManager.log_info("=== NOTIFICATION VALIDATION COMPLETE ===")

# Development helpers
func test_all_notification_types():
	"""Debug function to test all notification types"""
	show_info("Test Info", "This is an info notification")
	show_success("Test Success", "This is a success notification")
	show_warning("Test Warning", "This is a warning notification")
	show_error("Test Error", "This is an error notification")
	show_debug("Test Debug", "This is a debug notification")
	
	DebugManager.log_info("NotificationManager: Tested all notification types") 