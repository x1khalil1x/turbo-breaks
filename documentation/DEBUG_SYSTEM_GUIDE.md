# Debug System Guide: How to Use Debug Commands Effectively

## 🎯 **How Debug Commands Work in Godot**

### **1. Input Event Capture**
Debug commands use Godot's input system to capture keypresses:

```gdscript
func _input(event):  # Captures ALL input events
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F1:
                debug_function_1()

func _unhandled_input(event):  # Only captures input NOT consumed by UI
    # Better for debug commands - UI won't interfere
```

### **2. Autoload Accessibility**
Debug managers are **autoloads**, so they're accessible from any scene:
- Always available globally
- Persistent across scene changes
- Can monitor the entire game state

### **3. Signal-Based Communication**
Debug systems use signals to communicate between components:
```gdscript
# In DebugManager
signal debug_mode_toggled(enabled: bool)

# In any scene
DebugManager.debug_mode_toggled.connect(_on_debug_mode_toggled)
```

## 🔧 **Your Enhanced Debug System**

### **Built-in Debug Commands (Available Everywhere)**

Press these keys **anytime** during gameplay:

```
F3  = Toggle Debug Panel (visual overlay)
F4  = Validate Current Scene (check for issues)
F5  = Reset Debug State (clean slate)
F6  = Validate All Systems (autoload health check)
F7  = Cycle UI Themes (test theme switching)
F8  = Test IndustrialSceneManager (new system)
F9  = Show UI Pool Status (performance monitoring)
F10 = Test Transition Safety (cooldown verification)
```

### **Enhanced Debug Commands (Scene-Specific)**

When `enhanced_debug_controller.gd` is attached to a scene:

```
1-4 = Test your core scenes (Center, West, NorthWest, MainBuilding)
Q   = Quick scene validation (fast health check)
W   = Show all autoload status (system overview)
E   = Test UI pooling efficiency (performance comparison)
R   = Performance benchmark (comprehensive testing)
T   = Toggle all debug features (on/off switch)
```

## 📊 **Understanding Debug Output**

### **Log Levels**
Your DebugManager uses categorized logging:
```gdscript
LogLevel.INFO    = General information
LogLevel.WARNING = Potential issues
LogLevel.ERROR   = Critical problems
LogLevel.DEBUG   = Detailed diagnostics
```

### **Example Debug Session**
```
[2024-01-15 10:30:15] [INFO] === DEBUG KEYS AVAILABLE ===
[2024-01-15 10:30:15] [INFO] F4 = Validate Current Scene
🔍 === QUICK SCENE VALIDATION ===
📍 Scene: Center
🎮 Players: 1 (should be 1)
🚪 Doorways: 4
🖥️ UI Components: 12
✅ Scene transition completed: Center
```

## 🛠️ **How to Add Debug to Your Scenes**

### **Method 1: Use Existing DebugManager**
Every scene automatically has access to F3-F10 commands via the DebugManager autoload.

### **Method 2: Add Enhanced Debug Controller**
For comprehensive testing, attach `enhanced_debug_controller.gd` to key scenes:

1. In Godot editor, select your scene's root node
2. Click "Attach Script"
3. Choose `enhanced_debug_controller.gd`
4. Save the scene

### **Method 3: Create Custom Debug Functions**
Add debug commands to any script:

```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F12:  # Use unused function keys
                custom_debug_function()

func custom_debug_function():
    # Use DebugManager for consistent logging
    DebugManager.log_info("Custom debug function executed")
    
    # Your debug logic here
    var player = get_tree().get_first_node_in_group("player")
    if player:
        DebugManager.log_info("Player position: " + str(player.global_position))
```

## 🎮 **Best Practices for Debug Usage**

### **1. Start with Built-in Commands**
Always try these first:
- **F4** - Validate current scene (finds most issues)
- **F6** - Validate all systems (checks autoloads)
- **F9** - Show UI pool status (performance insights)

### **2. Test Scene Transitions**
- **F8** - Test IndustrialSceneManager
- **1-4** - Test your core scenes directly
- **F10** - Verify transition safety/cooldown

### **3. Performance Monitoring**
- **E** - Test UI pooling efficiency (with enhanced controller)
- **R** - Run performance benchmarks
- **W** - Check autoload health

### **4. Systematic Debugging**
When troubleshooting crashes:
1. **F6** - Check all autoload status
2. **F4** - Validate current scene
3. **Q** - Quick scene validation
4. **1-4** - Test specific scene transitions

## 🔍 **Reading Debug Output**

### **Scene Validation Output**
```
🔍 === QUICK SCENE VALIDATION ===
📍 Scene: Center                    # Current scene name
🎮 Players: 1 (should be 1)        # Player count (should always be 1)
🚪 Doorways: 4                     # Number of doorway transitions
🖥️ UI Components: 12               # UI elements in scene
⚠️ Doorway 'exit_north' issues: ["No target scene set"]  # Problems found
```

### **Autoload Status Output**
```
🔧 === AUTOLOAD STATUS ===
  DebugManager: ✅ Available        # Working properly
  UIThemeManager: ❌ Missing        # Not loaded/crashed
    └─ Theme status: Theme loaded   # Additional health info
```

### **Performance Output**
```
📊 Pooled UI: 15ms                 # Time for pooled UI operations
📊 Traditional UI: 89ms            # Time for traditional operations
📊 Efficiency gain: 5.9x faster    # Performance improvement
```

## 🚀 **Advanced Debug Techniques**

### **1. Custom Validation Functions**
```gdscript
# Add to any scene script
func validate_scene_specific_requirements():
    var required_nodes = ["Player", "GameUI", "CameraController"]
    for node_name in required_nodes:
        var node = get_node_or_null(node_name)
        if not node:
            DebugManager.log_error("Missing required node: " + node_name)
```

### **2. Performance Profiling**
```gdscript
func profile_expensive_operation():
    var start_time = Time.get_ticks_msec()
    
    # Your expensive operation here
    expensive_function()
    
    var elapsed = Time.get_ticks_msec() - start_time
    DebugManager.log_info("Operation took: " + str(elapsed) + "ms")
```

### **3. State Monitoring**
```gdscript
# Monitor critical game state
func _ready():
    # Connect to important signals for debugging
    player.health_changed.connect(_debug_health_changed)
    SceneManager.scene_changed.connect(_debug_scene_changed)

func _debug_health_changed(new_health):
    DebugManager.log_debug("Player health: " + str(new_health))
```

## 🎯 **Why This Debug System is Industry-Standard**

### **1. Centralized Management**
- All debug functionality in one autoload
- Consistent interface across the entire game
- Easy to enable/disable for releases

### **2. Non-Intrusive**
- Debug commands don't interfere with gameplay
- Can be completely disabled with one flag
- Uses `_unhandled_input()` to avoid UI conflicts

### **3. Comprehensive Coverage**
- Scene validation
- Performance monitoring  
- System health checks
- Transition testing
- UI pooling verification

### **4. Professional Output**
- Categorized logging (INFO/WARNING/ERROR)
- Timestamped messages
- Structured validation reports
- Performance metrics

This debug system gives you the same level of diagnostic capability that AAA games use internally! 