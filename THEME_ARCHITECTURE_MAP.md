# 🎨 Theme Architecture Map

## 📍 WHERE THEMES LIVE

### 1. **Theme Definitions** (Source of Truth)
- **Location**: `Autoload/UIThemeManager.gd`
- **Functions**: `create_default_theme()`, `create_high_contrast_theme()`, `create_mobile_theme()`, `create_retro_theme()`
- **What**: Code-based theme configurations with colors, fonts, sizing
- **Access**: Private - only called during initialization

### 2. **Active Theme Storage** (Runtime State)
- **Location**: `UIThemeManager` autoload
- **Variables**: 
  - `current_theme_config: UIThemeConfig` - Current theme data
  - `current_theme: Theme` - Applied Godot theme resource
  - `available_themes: Dictionary` - Registry of all themes
- **What**: Single source of truth for currently active theme
- **Access**: Public via getter functions

### 3. **Applied Themes** (UI Components)
- **Location**: Each UI component (`GameUI`, `BaseUIPanel`, etc.)
- **Property**: `component.theme` - Godot's built-in theme property
- **What**: Theme applied to individual UI elements
- **Access**: Automatic via theme system

## 🔄 WHERE THEMES ARE CALLED

### 1. **Theme Switching** (User Actions)
```gdscript
UIThemeManager.switch_theme("high_contrast")
```
- **Called from**: UI buttons, settings menus, accessibility features
- **What happens**: Changes active theme and applies to all components

### 2. **Theme Access** (Getting Current Theme)
```gdscript
var current = UIThemeManager.get_current_theme_config()
var theme_name = UIThemeManager.get_current_theme_name()
```
- **Called from**: UI components, settings displays, validation

### 3. **Component Registration** (Auto-Apply)
```gdscript
UIThemeManager.register_ui_component(self)
```
- **Called from**: `GameUI.register_ui_component()`, component `_ready()` functions
- **What happens**: Component gets current theme applied automatically

### 4. **Theme Application** (Internal)
```gdscript
GameUI.apply_theme_to_component(component, theme)
component.apply_theme_changes(theme_config)
```
- **Called from**: Theme manager internally, component updates
- **What happens**: Theme colors/fonts applied to specific UI elements

## 🚀 FLOW DIAGRAM

```
Theme Definitions (Code)
        ↓
UIThemeManager.initialize_default_themes()
        ↓
available_themes Dictionary
        ↓
switch_theme() → current_theme_config
        ↓
apply_theme_to_components() → All UI Components
        ↓
component.apply_theme_changes() → Visual Updates
```

## 🎯 KEY AUTOLOADS USING THEMES

1. **UIThemeManager** - Theme creation, switching, registration
2. **GameUI** - Theme application to components  
3. **NotificationManager** - Uses themes for notification styling
4. **Individual Scenes** - Register with theme system via GameUI

## 💡 ADDING NEW THEMES

1. Create `create_new_theme()` function in `UIThemeManager.gd`
2. Add to `initialize_default_themes()`: `available_themes["new"] = create_new_theme()`
3. Theme automatically available via `switch_theme("new")`

**No .tres files, no external dependencies, no loading issues!** 