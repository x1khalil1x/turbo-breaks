extends Control

@onready var title_label = $ScrollContainer/VBoxContainer/TitleLabel
@onready var menu_label = $ScrollContainer/VBoxContainer/MenuLabel
@onready var dialogue_label = $ScrollContainer/VBoxContainer/DialogueLabel
@onready var racing_label = $ScrollContainer/VBoxContainer/RacingLabel
@onready var retro_label = $ScrollContainer/VBoxContainer/RetroLabel
@onready var monospace_label = $ScrollContainer/VBoxContainer/MonospaceLabel
@onready var title_font_label = $ScrollContainer/VBoxContainer/TitleFontLabel
@onready var back_button = $BackButton

func _ready():
	setup_font_examples()

func setup_font_examples():
	# Wait for FontManager to be ready
	await get_tree().process_frame
	
	if not FontManager:
		print("FontManager not available!")
		return
	
	# Title showcase using racing font
	FontManager.make_racing_text(title_label, "TURBO BREAKS FONT SHOWCASE", 42)
	
	# Menu font example
	FontManager.apply_font_to_label(menu_label, FontManager.FontType.MENU, 20)
	menu_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Dialogue font example
	FontManager.apply_font_to_label(dialogue_label, FontManager.FontType.DIALOGUE, 16)
	dialogue_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Racing font example
	FontManager.make_racing_text(racing_label, "RACING FONT: SPEED & POWER", 28)
	
	# Retro font example
	FontManager.make_retro_text(retro_label, "RETRO FONT: 8-BIT ARCADE", 18)
	
	# Monospace font example
	FontManager.apply_font_to_label(monospace_label, FontManager.FontType.MONOSPACE, 20)
	monospace_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)
	
	# Title font example
	FontManager.make_title_text(title_font_label, "TITLE FONT: BOLD HEADERS", 32)
	
	# Style the back button - USE SAME APPROACH AS WORKING LOBBY BUTTONS
	print("FontDemo: Styling back button with lobby approach")
	
	# Clear any existing overrides first
	back_button.remove_theme_font_override("font")
	back_button.remove_theme_font_size_override("font_size")
	back_button.remove_theme_color_override("font_color")
	back_button.remove_theme_color_override("font_hover_color")
	back_button.remove_theme_color_override("font_pressed_color")
	back_button.remove_theme_color_override("font_focus_color")
	
	# Use system font like the working lobby buttons
	var system_font = ThemeDB.fallback_font
	if system_font:
		back_button.add_theme_font_override("font", system_font)
		print("FontDemo: System font applied to back button")
	
	# Set explicit font size
	back_button.add_theme_font_size_override("font_size", 18)
	
	# FORCE explicit white colors (same as lobby)
	back_button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	back_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	back_button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
	back_button.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 1.0))
	
	print("FontDemo: Back button styled with white text")

func _on_back_button_pressed():
	SceneManager.change_scene_to_lobby() 
