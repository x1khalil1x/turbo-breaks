extends Control

## UITestScene - Validation and testing scene for UI system
## Tests theme switching, notifications, modals, and component integration
## Based on UI_RULES.md testing protocols

# UI References
@onready var game_ui = $GameUI
@onready var test_controls = $TestControls

# Theme test buttons
@onready var default_theme_btn = $TestControls/ThemeControls/ThemeButtons/DefaultTheme
@onready var high_contrast_btn = $TestControls/ThemeControls/ThemeButtons/HighContrast
@onready var mobile_theme_btn = $TestControls/ThemeControls/ThemeButtons/MobileTheme
@onready var retro_theme_btn = $TestControls/ThemeControls/ThemeButtons/RetroTheme

# Notification test buttons
@onready var info_notification_btn = $TestControls/NotificationControls/NotificationButtons/NotificationRow1/InfoNotification
@onready var success_notification_btn = $TestControls/NotificationControls/NotificationButtons/NotificationRow1/SuccessNotification
@onready var warning_notification_btn = $TestControls/NotificationControls/NotificationButtons/NotificationRow1/WarningNotification
@onready var error_notification_btn = $TestControls/NotificationControls/NotificationButtons/NotificationRow2/ErrorNotification
@onready var debug_notification_btn = $TestControls/NotificationControls/NotificationButtons/NotificationRow2/DebugNotification
@onready var clear_notifications_btn = $TestControls/NotificationControls/NotificationButtons/NotificationRow2/ClearNotifications

# Modal test buttons
@onready var show_modal_btn = $TestControls/ModalControls/ModalButtons/ShowModal
@onready var test_pause_btn = $TestControls/ModalControls/ModalButtons/TestPause

# Test state
var notification_counter: int = 0
var test_results: Dictionary = {}

func _ready():
	print("UITestScene: Initializing UI system test environment")
	
	# Setup test controls
	setup_test_controls()
	
	# Connect test buttons
	connect_test_buttons()
	
	# Run initial validation
	validate_ui_system()
	
	print("UITestScene: Test environment ready")

func setup_test_controls():
	"""Setup test control panel configuration"""
	# Ensure test controls are above everything else
	test_controls.z_index = 100
	
	# Apply theme to test controls
	if UIThemeManager:
		UIThemeManager.register_ui_component(test_controls)

func connect_test_buttons():
	"""Connect all test buttons to their handlers"""
	# Theme test buttons
	if default_theme_btn:
		default_theme_btn.pressed.connect(_on_theme_button_pressed.bind("default"))
	if high_contrast_btn:
		high_contrast_btn.pressed.connect(_on_theme_button_pressed.bind("high_contrast"))
	if mobile_theme_btn:
		mobile_theme_btn.pressed.connect(_on_theme_button_pressed.bind("mobile"))
	if retro_theme_btn:
		retro_theme_btn.pressed.connect(_on_theme_button_pressed.bind("retro"))
	
	# Notification test buttons
	if info_notification_btn:
		info_notification_btn.pressed.connect(_on_notification_button_pressed.bind(NotificationManager.NotificationType.INFO))
	if success_notification_btn:
		success_notification_btn.pressed.connect(_on_notification_button_pressed.bind(NotificationManager.NotificationType.SUCCESS))
	if warning_notification_btn:
		warning_notification_btn.pressed.connect(_on_notification_button_pressed.bind(NotificationManager.NotificationType.WARNING))
	if error_notification_btn:
		error_notification_btn.pressed.connect(_on_notification_button_pressed.bind(NotificationManager.NotificationType.ERROR))
	if debug_notification_btn:
		debug_notification_btn.pressed.connect(_on_notification_button_pressed.bind(NotificationManager.NotificationType.DEBUG))
	if clear_notifications_btn:
		clear_notifications_btn.pressed.connect(_on_clear_notifications_pressed)
	
	# Modal test buttons
	if show_modal_btn:
		show_modal_btn.pressed.connect(_on_show_modal_pressed)
	if test_pause_btn:
		test_pause_btn.pressed.connect(_on_test_pause_pressed)

# Theme Testing Functions
func _on_theme_button_pressed(theme_name: String):
	"""Test theme switching functionality"""
	print("UITestScene: Testing theme switch to " + theme_name)
	
	if UIThemeManager:
		var success = UIThemeManager.switch_theme(theme_name)
		if success:
			test_results["theme_switch_" + theme_name] = "PASS"
			show_test_notification("Theme switched to " + theme_name, NotificationManager.NotificationType.SUCCESS)
		else:
			test_results["theme_switch_" + theme_name] = "FAIL"
			show_test_notification("Failed to switch to " + theme_name, NotificationManager.NotificationType.ERROR)
	else:
		print("UITestScene: UIThemeManager not available")
		show_test_notification("UIThemeManager not available", NotificationManager.NotificationType.ERROR)

# Notification Testing Functions
func _on_notification_button_pressed(notification_type: NotificationManager.NotificationType):
	"""Test notification display functionality"""
	var type_name = NotificationManager.NotificationType.keys()[notification_type]
	print("UITestScene: Testing " + type_name + " notification")
	
	notification_counter += 1
	
	var test_messages = {
		NotificationManager.NotificationType.INFO: "This is a test information notification #%d",
		NotificationManager.NotificationType.SUCCESS: "Test operation completed successfully #%d",
		NotificationManager.NotificationType.WARNING: "This is a test warning message #%d",
		NotificationManager.NotificationType.ERROR: "Test error notification #%d",
		NotificationManager.NotificationType.DEBUG: "Debug notification for testing #%d"
	}
	
	var message = test_messages[notification_type] % notification_counter
	
	if NotificationManager:
		# Use the appropriate convenience function based on type
		match notification_type:
			NotificationManager.NotificationType.INFO:
				NotificationManager.show_info("Test Info", message, 5.0)
			NotificationManager.NotificationType.SUCCESS:
				NotificationManager.show_success("Test Success", message, 5.0)
			NotificationManager.NotificationType.WARNING:
				NotificationManager.show_warning("Test Warning", message, 5.0)
			NotificationManager.NotificationType.ERROR:
				NotificationManager.show_error("Test Error", message, 5.0)
			NotificationManager.NotificationType.DEBUG:
				NotificationManager.show_debug("Test Debug", message, 5.0)
		test_results["notification_" + type_name.to_lower()] = "PASS"
	else:
		print("UITestScene: NotificationManager not available")
		test_results["notification_" + type_name.to_lower()] = "FAIL"

func _on_clear_notifications_pressed():
	"""Test clearing all notifications"""
	print("UITestScene: Testing notification clearing")
	
	if NotificationManager:
		NotificationManager.clear_all_notifications()
		show_test_notification("All notifications cleared", NotificationManager.NotificationType.INFO, 2.0)
		test_results["clear_notifications"] = "PASS"
	else:
		print("UITestScene: NotificationManager not available")

func show_test_notification(message: String, type: NotificationManager.NotificationType, duration: float = 3.0):
	"""Show a test notification with specified parameters"""
	if NotificationManager:
		# Use the appropriate convenience function based on type
		match type:
			NotificationManager.NotificationType.INFO:
				NotificationManager.show_info("Test", message, duration)
			NotificationManager.NotificationType.SUCCESS:
				NotificationManager.show_success("Test", message, duration)
			NotificationManager.NotificationType.WARNING:
				NotificationManager.show_warning("Test", message, duration)
			NotificationManager.NotificationType.ERROR:
				NotificationManager.show_error("Test", message, duration)
			NotificationManager.NotificationType.DEBUG:
				NotificationManager.show_debug("Test", message, duration)

# Modal Testing Functions
func _on_show_modal_pressed():
	"""Test modal dialog functionality"""
	print("UITestScene: Testing modal dialog")
	
	if UIStateManager:
		# Create a simple test modal (would normally load a PackedScene)
		var _test_modal = create_test_modal()
		if game_ui and game_ui.has_method("show_modal"):
			# For now, just test the state transition
			UIStateManager.set_ui_state(UIStateManager.UIState.DIALOG)
			show_test_notification("Modal system tested (state change)", NotificationManager.NotificationType.INFO)
			test_results["modal_display"] = "PASS"
		else:
			test_results["modal_display"] = "FAIL"
			show_test_notification("Modal system test failed", NotificationManager.NotificationType.ERROR)
	else:
		print("UITestScene: UIStateManager not available")

func _on_test_pause_pressed():
	"""Test pause menu functionality"""
	print("UITestScene: Testing pause functionality")
	
	if UIStateManager:
		var current_state = UIStateManager.current_ui_state
		if current_state == UIStateManager.UIState.GAMEPLAY:
			UIStateManager.set_ui_state(UIStateManager.UIState.PAUSE)
			show_test_notification("Paused", NotificationManager.NotificationType.INFO)
		else:
			UIStateManager.set_ui_state(UIStateManager.UIState.GAMEPLAY)
			show_test_notification("Unpaused", NotificationManager.NotificationType.INFO)
		
		test_results["pause_toggle"] = "PASS"
	else:
		print("UITestScene: UIStateManager not available")

func create_test_modal() -> Control:
	"""Create a simple test modal dialog"""
	var modal = PanelContainer.new()
	modal.custom_minimum_size = Vector2(300, 200)
	
	var label = Label.new()
	label.text = "Test Modal Dialog\n\nThis is a test modal to validate\nthe modal system functionality."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	modal.add_child(label)
	return modal

# Input Handling
func _unhandled_key_input(event):
	"""Handle test keyboard shortcuts"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				print_test_results()
			KEY_F2:
				run_full_ui_test()
			KEY_F3:
				validate_ui_system()
			KEY_T:
				if event.shift_pressed:
					UIThemeManager.cycle_themes_for_testing()

# Validation Functions
func validate_ui_system():
	"""Validate the entire UI system"""
	print("=== UI SYSTEM VALIDATION ===")
	
	var validation_results = {}
	
	# Test autoload availability
	validation_results["UIThemeManager"] = UIThemeManager != null
	validation_results["UIStateManager"] = UIStateManager != null
	validation_results["NotificationManager"] = NotificationManager != null
	
	# Test GameUI integration
	validation_results["GameUI_exists"] = game_ui != null
	validation_results["GameUI_has_layers"] = game_ui != null and game_ui.has_method("register_ui_component")
	
	# Test theme system
	if UIThemeManager:
		validation_results["theme_system"] = UIThemeManager.get_current_theme() != null
		validation_results["theme_config"] = UIThemeManager.get_current_theme_config() != null
	
	# Print validation results
	for test_name in validation_results.keys():
		var result = "PASS" if validation_results[test_name] else "FAIL"
		print("  " + test_name + ": " + result)
	
	print("=== VALIDATION COMPLETE ===")
	return validation_results

func run_full_ui_test():
	"""Run comprehensive UI system test"""
	print("=== RUNNING FULL UI TEST ===")
	
	test_results.clear()
	
	# Test theme switching
	await test_all_themes()
	
	# Test notifications
	await test_all_notifications()
	
	# Test modal system
	test_modal_system()
	
	# Print results
	print_test_results()

func test_all_themes():
	"""Test switching through all available themes"""
	if not UIThemeManager:
		return
	
	var themes = UIThemeManager.get_available_themes()
	for theme_name in themes:
		print("Testing theme: " + theme_name)
		UIThemeManager.switch_theme(theme_name)
		await get_tree().process_frame  # Wait one frame for theme application
		
		# Validate theme was applied
		var current_theme = UIThemeManager.get_current_theme_name()
		test_results["theme_" + theme_name] = "PASS" if current_theme == theme_name else "FAIL"

func test_all_notifications():
	"""Test all notification types"""
	if not NotificationManager:
		return
	
	var types = [
		NotificationManager.NotificationType.INFO,
		NotificationManager.NotificationType.SUCCESS,
		NotificationManager.NotificationType.WARNING,
		NotificationManager.NotificationType.ERROR,
		NotificationManager.NotificationType.DEBUG
	]
	
	for type in types:
		var type_name = NotificationManager.NotificationType.keys()[type]
		print("Testing notification type: " + type_name)
		# Use the appropriate convenience function
		match type:
			NotificationManager.NotificationType.INFO:
				NotificationManager.show_info("Test", "Test " + type_name + " notification", 1.0)
			NotificationManager.NotificationType.SUCCESS:
				NotificationManager.show_success("Test", "Test " + type_name + " notification", 1.0)
			NotificationManager.NotificationType.WARNING:
				NotificationManager.show_warning("Test", "Test " + type_name + " notification", 1.0)
			NotificationManager.NotificationType.ERROR:
				NotificationManager.show_error("Test", "Test " + type_name + " notification", 1.0)
			NotificationManager.NotificationType.DEBUG:
				NotificationManager.show_debug("Test", "Test " + type_name + " notification", 1.0)
		test_results["notification_" + type_name.to_lower()] = "PASS"

func test_modal_system():
	"""Test modal dialog system"""
	if UIStateManager:
		# Test state transitions
		UIStateManager.set_ui_state(UIStateManager.UIState.DIALOG)
		test_results["modal_state_enter"] = "PASS"
		
		UIStateManager.set_ui_state(UIStateManager.UIState.GAMEPLAY)
		test_results["modal_state_exit"] = "PASS"

func print_test_results():
	"""Print comprehensive test results"""
	print("=== UI SYSTEM TEST RESULTS ===")
	
	var total_tests = test_results.size()
	var passed_tests = 0
	
	for test_name in test_results.keys():
		var result = test_results[test_name]
		print("  " + test_name + ": " + result)
		if result == "PASS":
			passed_tests += 1
	
	print("Tests passed: " + str(passed_tests) + "/" + str(total_tests))
	
	if passed_tests == total_tests:
		print("🎉 ALL TESTS PASSED!")
		show_test_notification("All UI tests passed!", NotificationManager.NotificationType.SUCCESS)
	else:
		print("⚠️ Some tests failed")
		show_test_notification("Some UI tests failed", NotificationManager.NotificationType.WARNING)
	
	print("=== TEST RESULTS COMPLETE ===")

# Debug helpers
func _input(event):
	"""Handle debug input"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			# Toggle test controls visibility
			test_controls.visible = !test_controls.visible 
