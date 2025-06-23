extends Panel
class_name EquipmentSlot

## Reusable Equipment Slot Component
## Handles equipment display, interaction, and visual feedback

signal slot_clicked(slot_type: String)
signal slot_hovered(slot_type: String, is_hovered: bool)

@export var slot_type: String = "weapon"
@export var slot_label: String = "WEAPON"
@export var equipped_item: Resource = null

@onready var item_icon = $ItemIcon
@onready var label = $SlotLabel
@onready var hover_effect = $HoverEffect

var is_mouse_over: bool = false

func _ready():
	# Setup slot appearance
	label.text = slot_label.to_upper()
	hover_effect.modulate.a = 0.0
	
	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_slot_input)
	
	# Update display
	update_slot_display()

func _on_mouse_entered():
	is_mouse_over = true
	animate_hover(true)
	slot_hovered.emit(slot_type, true)

func _on_mouse_exited():
	is_mouse_over = false
	animate_hover(false)
	slot_hovered.emit(slot_type, false)

func _on_slot_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			animate_click()
			slot_clicked.emit(slot_type)

func animate_hover(hover_in: bool):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	if hover_in:
		tween.tween_property(hover_effect, "modulate:a", 0.3, 0.2)
		tween.parallel().tween_property(self, "scale", Vector2(1.05, 1.05), 0.2)
	else:
		tween.tween_property(hover_effect, "modulate:a", 0.0, 0.2)
		tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func animate_click():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func equip_item(item: Resource):
	equipped_item = item
	update_slot_display()

func unequip_item():
	equipped_item = null
	update_slot_display()

func update_slot_display():
	if equipped_item and equipped_item.has_method("get_icon"):
		item_icon.texture = equipped_item.get_icon()
		item_icon.modulate = Color.WHITE
	else:
		item_icon.texture = null
		item_icon.modulate = Color(0.5, 0.5, 0.5, 0.5)

func set_slot_theme_color(color: Color):
	var style = get_theme_stylebox("panel").duplicate()
	style.border_color = color
	add_theme_stylebox_override("panel", style) 