# TURBO BREAKS - Font Guide

## 🎯 Available Fonts

Your game now has 6 carefully selected fonts for different purposes. The `FontManager` singleton makes it easy to use them consistently throughout your game.

## 📚 Font Categories

### 1. **MENU** - Exo 2 (Variable Weight)
- **Use for:** Main UI, menus, buttons, body text
- **Style:** Clean, modern, futuristic but readable
- **Why it's perfect:** Highly legible at all sizes, supports variable weights

### 2. **DIALOGUE** - Share Tech Mono
- **Use for:** Code displays, tech readouts, monospace needs
- **Style:** Clean monospace with a tech feel
- **Why it's perfect:** Easy to read for longer text, fits the tech theme

### 3. **TITLE** - Russo One
- **Use for:** Large titles, headers, impact text
- **Style:** Bold, strong, attention-grabbing
- **Why it's perfect:** Perfect for main titles and headers that need impact

### 4. **RETRO** - Press Start 2P
- **Use for:** Retro gaming UI, score displays, pixel-style elements
- **Style:** Classic 8-bit pixel font
- **Why it's perfect:** Authentic retro gaming feel, nostalgic

### 5. **RACING** - Michroma
- **Use for:** Racing-themed text, speed displays, futuristic elements
- **Style:** Angular, fast, automotive-inspired
- **Why it's perfect:** Captures the speed and energy of racing games

### 6. **MONOSPACE** - Orbitron
- **Use for:** HUD elements, data displays, sci-fi interfaces
- **Style:** Geometric, futuristic, space-age
- **Why it's perfect:** Great for technical displays and futuristic UIs

## 🛠️ How to Use

### Quick Methods (Presets)
```gdscript
# Apply racing style with cyan color
FontManager.make_racing_text(label, "TURBO BREAKS", 48)

# Apply retro style with lime green color  
FontManager.make_retro_text(label, "HIGH SCORE: 12345", 24)

# Apply title style with white color
FontManager.make_title_text(label, "GAME OVER", 64)

# Apply menu style with white color
FontManager.make_menu_text(label, "Start Game", 18)
```

### Custom Applications
```gdscript
# Apply any font with custom size
FontManager.apply_font_to_label(label, FontManager.FontType.RACING, 32)

# Apply to buttons or other controls
FontManager.apply_font_to_control(button, FontManager.FontType.MENU, 16)

# Get font resource directly
var racing_font = FontManager.get_font(FontManager.FontType.RACING)
```

## 🎨 Color Recommendations

- **Racing text:** Cyan (#00FFFF) for speed/energy
- **Retro text:** Lime Green (#00FF00) for classic arcade feel  
- **Title text:** White (#FFFFFF) for maximum impact
- **Menu text:** White or Light Gray for readability
- **Tech/Monospace:** Light Blue (#ADD8E6) for sci-fi feel

## 🚀 Getting Started

1. Use `FontManager.make_racing_text()` for your main game title
2. Use `FontManager.FontType.MENU` for all UI buttons and menus
3. Use `FontManager.FontType.RETRO` for score displays and arcade elements
4. Use `FontManager.FontType.MONOSPACE` for HUD data and technical readouts

The fonts are now fully integrated into your project and ready to use! 