extends Node

# Font categories for different use cases
enum FontType {
	MENU,        # Clean, readable fonts for menus and UI
	DIALOGUE,    # Easy to read for dialogue and body text
	TITLE,       # Big, bold fonts for titles and headers
	RETRO,       # Pixel/arcade style fonts
	RACING,      # Fast, futuristic racing fonts
	MONOSPACE    # Code/tech style monospace fonts
}

# Font resources - loaded at startup
var fonts = {}

func _ready():
	load_fonts()

func load_fonts():
	# Menu/UI fonts (clean and readable)
	fonts[FontType.MENU] = load("res://fonts/Exo2-VariableFont_wght.ttf")
	fonts[FontType.DIALOGUE] = load("res://fonts/Share-Tech-Mono-Regular.ttf")
	
	# Title fonts (big and bold)
	fonts[FontType.TITLE] = load("res://fonts/RussoOne-Regular.ttf")
	
	# Retro gaming fonts
	fonts[FontType.RETRO] = load("res://fonts/PressStart2P-Regular.ttf")
	
	# Racing/futuristic fonts
	fonts[FontType.RACING] = load("res://fonts/Michroma-Regular.ttf")
	
	# Monospace/tech fonts
	fonts[FontType.MONOSPACE] = load("res://fonts/Orbitron.ttf")
	
	print("Fonts loaded successfully!")

# Get a font by type
func get_font(font_type: FontType) -> Font:
	if font_type in fonts:
		return fonts[font_type]
	else:
		print("Font type not found: ", font_type)
		return null

# Apply font to a label with size
func apply_font_to_label(label: Label, font_type: FontType, size: int = 16):
	var font = get_font(font_type)
	if font and label:
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", size)

# Apply font to any control that supports fonts
func apply_font_to_control(control: Control, font_type: FontType, size: int = 16):
	var font = get_font(font_type)
	if font and control:
		control.add_theme_font_override("font", font)
		control.add_theme_font_size_override("font_size", size)

# Create a theme override for buttons with specific font
func create_button_theme(font_type: FontType, size: int = 16) -> Theme:
	var theme = Theme.new()
	var font = get_font(font_type)
	if font:
		theme.set_font("font", "Button", font)
		theme.set_font_size("font_size", "Button", size)
	return theme

# Convenient preset functions for common uses
func make_title_text(label: Label, text: String, size: int = 48):
	label.text = text
	apply_font_to_label(label, FontType.TITLE, size)
	label.add_theme_color_override("font_color", Color.WHITE)

func make_racing_text(label: Label, text: String, size: int = 32):
	label.text = text
	apply_font_to_label(label, FontType.RACING, size)
	label.add_theme_color_override("font_color", Color.CYAN)

func make_retro_text(label: Label, text: String, size: int = 24):
	label.text = text
	apply_font_to_label(label, FontType.RETRO, size)
	label.add_theme_color_override("font_color", Color.LIME_GREEN)

func make_menu_text(label: Label, text: String, size: int = 18):
	label.text = text
	apply_font_to_label(label, FontType.MENU, size)
	label.add_theme_color_override("font_color", Color.WHITE) 
