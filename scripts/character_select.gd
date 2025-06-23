extends Control
class_name CharacterSelect

## Character Selection Scene Controller
## Handles character creation, selection, and equipment management

# Character data structure
var current_character_data = {
	"name": "New Character",
	"level": 1,
	"experience": 0,
	"max_experience": 100,
	"equipped_weapon": null,
	"equipped_armor": null,
	"equipped_accessory": null,
	"attack_chip": null,
	"defense_chip": null,
	"utility_chip": null
}

# UI References
@onready var character_sprite = $MainContainer/LeftPanel/CharacterPortrait/PortraitFrame/CharacterSprite
@onready var name_label = $MainContainer/LeftPanel/CharacterInfo/NamePanel/NameLabel
@onready var level_value = $MainContainer/LeftPanel/CharacterInfo/StatsPanel/StatsGrid/LevelValue
@onready var exp_value = $MainContainer/LeftPanel/CharacterInfo/StatsPanel/StatsGrid/ExpValue

# Equipment slots
@onready var weapon_slot = $MainContainer/RightPanel/EquipmentSection/EquipmentGrid/WeaponSlot
@onready var armor_slot = $MainContainer/RightPanel/EquipmentSection/EquipmentGrid/ArmorSlot
@onready var accessory_slot = $MainContainer/RightPanel/EquipmentSection/EquipmentGrid/AccessorySlot

# Module slots
@onready var attack_chip = $MainContainer/RightPanel/ModuleSection/ModuleContainer/AttackChip
@onready var defense_chip = $MainContainer/RightPanel/ModuleSection/ModuleContainer/DefenseChip
@onready var utility_chip = $MainContainer/RightPanel/ModuleSection/ModuleContainer/UtilityChip

# Navigation buttons
@onready var back_button = $NavigationPanel/BackButton
@onready var confirm_button = $NavigationPanel/ConfirmButton
@onready var create_button = $NavigationPanel/CreateButton

# Background shader material
@onready var background = $Background

func _ready():
	print("CharacterSelect: Initializing character selection scene")
	setup_ui()
	connect_signals()
	load_character_data()
	apply_character_styling()

func setup_ui():
	"""Initialize UI components and styling"""
	# Apply font styling if FontManager is available
	if FontManager:
		FontManager.apply_font_to_control(name_label, FontManager.FontType.TITLE, 18)
		FontManager.apply_font_to_control(level_value, FontManager.FontType.MENU, 14)
		FontManager.apply_font_to_control(exp_value, FontManager.FontType.MENU, 14)
	
	# Setup equipment slot styling
	setup_equipment_slots()
	
	# Setup module chip styling
	setup_module_slots()

func setup_equipment_slots():
	"""Configure equipment slot appearance and behavior"""
	var slot_style = StyleBoxFlat.new()
	slot_style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
	slot_style.border_color = Color(0.5, 0.5, 0.7, 1.0)
	slot_style.border_width_top = 2
	slot_style.border_width_bottom = 2
	slot_style.border_width_left = 2
	slot_style.border_width_right = 2
	slot_style.corner_radius_top_left = 4
	slot_style.corner_radius_top_right = 4
	slot_style.corner_radius_bottom_left = 4
	slot_style.corner_radius_bottom_right = 4
	
	weapon_slot.add_theme_stylebox_override("panel", slot_style)
	armor_slot.add_theme_stylebox_override("panel", slot_style.duplicate())
	accessory_slot.add_theme_stylebox_override("panel", slot_style.duplicate())

func setup_module_slots():
	"""Configure module chip slot appearance with color coding"""
	# Attack chip - Red theme
	var attack_style = StyleBoxFlat.new()
	attack_style.bg_color = Color(0.3, 0.1, 0.1, 0.8)
	attack_style.border_color = Color(0.8, 0.2, 0.2, 1.0)
	attack_style.border_width_top = 2
	attack_style.border_width_bottom = 2
	attack_style.border_width_left = 2
	attack_style.border_width_right = 2
	attack_style.corner_radius_top_left = 4
	attack_style.corner_radius_top_right = 4
	attack_style.corner_radius_bottom_left = 4
	attack_style.corner_radius_bottom_right = 4
	attack_chip.add_theme_stylebox_override("panel", attack_style)
	
	# Defense chip - Blue theme
	var defense_style = attack_style.duplicate()
	defense_style.bg_color = Color(0.1, 0.1, 0.3, 0.8)
	defense_style.border_color = Color(0.2, 0.5, 0.8, 1.0)
	defense_chip.add_theme_stylebox_override("panel", defense_style)
	
	# Utility chip - Green theme
	var utility_style = attack_style.duplicate()
	utility_style.bg_color = Color(0.1, 0.3, 0.1, 0.8)
	utility_style.border_color = Color(0.2, 0.8, 0.2, 1.0)
	utility_chip.add_theme_stylebox_override("panel", utility_style)

func connect_signals():
	"""Connect UI signals for user interaction"""
	back_button.pressed.connect(_on_back_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	create_button.pressed.connect(_on_create_new_pressed)
	
	# Connect equipment slot signals for click handling
	weapon_slot.gui_input.connect(_on_equipment_slot_clicked.bind("weapon"))
	armor_slot.gui_input.connect(_on_equipment_slot_clicked.bind("armor"))
	accessory_slot.gui_input.connect(_on_equipment_slot_clicked.bind("accessory"))
	
	# Connect module slot signals
	attack_chip.gui_input.connect(_on_module_slot_clicked.bind("attack"))
	defense_chip.gui_input.connect(_on_module_slot_clicked.bind("defense"))
	utility_chip.gui_input.connect(_on_module_slot_clicked.bind("utility"))

func apply_character_styling():
	"""Apply Anno Mutationem inspired styling"""
	# Animate background shader parameters
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(update_shader_time, 0.0, 1.0, 2.0)

func update_shader_time(value: float):
	"""Update shader animation parameters"""
	if background and background.material:
		background.material.set_shader_parameter("fade_alpha", 0.85 + sin(value * PI) * 0.1)

func load_character_data():
	"""Load and display current character information"""
	name_label.text = current_character_data.name
	level_value.text = str(current_character_data.level)
	exp_value.text = str(current_character_data.experience) + "/" + str(current_character_data.max_experience)
	
	# TODO: Load character sprite based on data
	print("CharacterSelect: Character data loaded")

func _on_equipment_slot_clicked(event: InputEvent, slot_type: String):
	"""Handle equipment slot interactions"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("CharacterSelect: Equipment slot clicked: ", slot_type)
		# TODO: Open equipment selection menu
		show_equipment_selection(slot_type)

func _on_module_slot_clicked(event: InputEvent, module_type: String):
	"""Handle module slot interactions"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("CharacterSelect: Module slot clicked: ", module_type)
		# TODO: Open module selection menu
		show_module_selection(module_type)

func show_equipment_selection(slot_type: String):
	"""Display equipment selection interface"""
	print("CharacterSelect: Opening equipment selection for: ", slot_type)
	# TODO: Implement equipment selection popup

func show_module_selection(module_type: String):
	"""Display module selection interface"""
	print("CharacterSelect: Opening module selection for: ", module_type)
	# TODO: Implement module selection popup

func _on_back_pressed():
	"""Handle back button - return to main menu"""
	print("CharacterSelect: Back button pressed")
	SceneManager.change_scene_to_lobby()

func _on_confirm_pressed():
	var validation = validate_character_state()
	if not validation.valid:
		debug_log("Validation failed: " + str(validation.issues), "ERROR")
		show_validation_errors(validation.issues)
		return
	
	debug_log("Character confirmed - transitioning to game")
	SceneManager.change_scene("res://scenes/environment/OutdoorScene.tscn")

func _on_create_new_pressed():
	"""Handle create new character button"""
	print("CharacterSelect: Create new character pressed")
	# TODO: Open character creation interface
	reset_character_data()

func reset_character_data():
	"""Reset character data for new character creation"""
	current_character_data = {
		"name": "New Character",
		"level": 1,
		"experience": 0,
		"max_experience": 100,
		"equipped_weapon": null,
		"equipped_armor": null,
		"equipped_accessory": null,
		"attack_chip": null,
		"defense_chip": null,
		"utility_chip": null
	}
	load_character_data() 

func debug_log(message: String, level: String = "INFO"):
	if OS.is_debug_build():
		print("[CHAR_SELECT][", level, "] ", message)

func validate_character_state() -> Dictionary:
	var issues = []
	
	if current_character_data.name.is_empty():
		issues.append("Character name is empty")
	
	if current_character_data.level < 1:
		issues.append("Invalid character level")
	
	if not current_character_data.equipped_weapon and requires_weapon():
		issues.append("No weapon equipped")
	
	return {
		"valid": issues.is_empty(),
		"issues": issues
	}

func show_validation_errors(issues: Array):
	var error_popup = AcceptDialog.new()
	error_popup.title = "Character Selection Issues"
	error_popup.dialog_text = "Please fix the following:\n\n" + "\n".join(issues)
	add_child(error_popup)
	error_popup.popup_centered()
	error_popup.confirmed.connect(error_popup.queue_free)

func requires_weapon() -> bool:
	# Implement the logic to determine if a weapon is required
	return false

func show_equipment_tooltip(slot_type: String):
	var tooltip = PanelContainer.new()
	var label = Label.new()
	
	match slot_type:
		"weapon":
			label.text = "Equip a weapon to deal damage to enemies"
		"armor": 
			label.text = "Armor reduces incoming damage"
		"accessory":
			label.text = "Accessories provide special abilities"
	
	tooltip.add_child(label)
	add_child(tooltip)
	
	# Position near mouse
	tooltip.position = get_global_mouse_position() + Vector2(10, 10)
	
	# Auto-remove after delay
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.timeout.connect(tooltip.queue_free)
	tooltip.add_child(timer)
	timer.start()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_back_pressed()
