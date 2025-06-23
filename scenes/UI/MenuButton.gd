extends Button
class_name MenuButton

signal menu_button_pressed(button_name: String)

@export var button_id: String = ""

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	menu_button_pressed.emit(button_id) 