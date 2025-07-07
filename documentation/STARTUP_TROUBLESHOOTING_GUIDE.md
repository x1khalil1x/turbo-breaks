# TURBO BREAKS: Startup Troubleshooting Guide

🏁 **Systematic Approach to Diagnosing and Fixing Startup Issues**

## 🎯 **SYSTEM CRITICALITY MATRIX**

### **🔴 STARTUP-CRITICAL** (Game won't run without these)
```
Main.tscn → Lobby.tscn → SceneManager.change_scene_to_lobby()
├── DebugManager ✅ (Foundation - loads first)
├── SceneManager ✅ (Core scene transitions)
├── MusicPlayer ✅ (Audio system)
├── FontManager ✅ (UI text rendering)
└── Basic Scene Structure (Player, Camera, UI)
```

**Autoload Dependency Order (CRITICAL)**:
```
1. DebugManager        # No dependencies - logs everything
2. SceneManager        # Depends on DebugManager
3. MusicPlayer         # Independent
4. FontManager         # Independent
5. MapManager          # Depends on DebugManager
```

### **🟡 FEATURE-DEPENDENT** (Advanced functionality)
```
├── UIThemeManager ✅ (Theme switching)
├── UIStateManager ✅ (Modal management)
├── MapManager ✅ (3x3 world navigation)
├── NotificationManager ✅ (Toast messages)
└── DrivingConfigManager ✅ (Driving mode)
```

### **🟢 NON-CRITICAL** (Future features, can be disabled)
```
├── WorldMapManager (Zone discovery)
├── SceneEdgeTransition (Alternative navigation)
├── Advanced cartography features
├── Save/load systems
└── Placeholder content systems
```

## 🔧 **IMMEDIATE FIXES NEEDED**

### **Fix #1: Remove Unused Signal**
**Problem**: `SceneEdgeTransition.gd` declares `player_entered_edge` signal but never uses it

**Solution**: Clean up the signal declaration

### **Fix #2: Validate Autoload Methods**
**Problem**: Some autoloads may call methods that don't exist on dependencies

**Solution**: Add null-safe method checking

### **Fix #3: Scene Loading Validation**
**Problem**: Ensure Main.tscn → Lobby.tscn transition works reliably

## 📋 **STARTUP DEBUGGING WORKFLOW**

### **Step 1: Basic System Validation**
1. ✅ **Test autoload loading order** - F6 key (DebugManager.validate_new_systems())
2. ✅ **Test main scene loading** - Main.tscn should immediately load Lobby.tscn
3. ✅ **Test SceneManager functionality** - Scene transitions should work
4. ✅ **Test basic input** - WASD movement should work in game scenes

### **Step 2: Progressive Feature Testing**
1. **Disable non-critical autoloads** temporarily
2. **Test core game loop**: Main → Lobby → CharacterSelect → OutdoorScene
3. **Re-enable features one by one** to isolate issues

### **Step 3: Error Pattern Analysis**
| Error Type | Likely Cause | Quick Fix |
|------------|--------------|-----------|
| Parse errors | Script syntax issues | Check GDScript syntax |
| Null reference | Missing autoload dependencies | Add null checks |
| Signal connection | Missing signal/method | Validate signal names |
| Scene loading | Missing scene files | Check file paths |
| Resource loading | Missing .tres files | Validate resource paths |

## 🛠️ **SYSTEM CLEANUP STRATEGY**

### **Phase 1: Core Stability** (Do First)
```gdscript
# 1. Clean up SceneEdgeTransition signal
# 2. Validate all autoload method calls
# 3. Test basic scene flow: Main → Lobby → Game
# 4. Ensure DebugManager logging works
```

### **Phase 2: Feature Validation** (Do After Core Works)
```gdscript
# 1. Test UI theme system
# 2. Test doorway navigation 
# 3. Test 3x3 world navigation
# 4. Test modal dialogs and notifications
```

### **Phase 3: Advanced Features** (Optional)
```gdscript
# 1. Enable WorldMapManager discovery
# 2. Enable driving mode systems
# 3. Add save/load functionality
# 4. Test performance optimizations
```

## 🚨 **EMERGENCY STARTUP FIXES**

### **If Game Won't Start At All**:
1. **Comment out non-critical autoloads** in project.godot
2. **Test with minimal Main.tscn**
3. **Check for parse errors** in all autoload scripts
4. **Validate Main.tscn → Lobby.tscn path**

### **If Scenes Load But Crash**:
1. **Use F4 (validate current scene)** to check scene structure
2. **Check Player and Camera setup** in problematic scenes
3. **Validate doorway configurations** and target paths
4. **Test with UI disabled** (set visible=false on UI CanvasLayer)

### **If Autoloads Fail**:
1. **Check dependency order** in project.godot [autoload] section
2. **Add await get_tree().process_frame** in autoload _ready() functions
3. **Use null checks** before calling autoload methods
4. **Test autoloads individually** by commenting others out

## 📊 **STARTUP VALIDATION CHECKLIST**

### **Before Every Development Session**:
- [ ] **F6**: Validate all systems (DebugManager.validate_new_systems())
- [ ] **F4**: Validate current scene structure
- [ ] **F3**: Toggle debug panel (should show no errors)
- [ ] **Test basic movement** in OutdoorScene.tscn
- [ ] **Test scene transitions** (doorways working)

### **After Making Changes**:
- [ ] **Parse errors resolved** (GDScript editor shows no red)
- [ ] **Autoload order maintained** (DebugManager first)
- [ ] **Signal connections validated** (no "unused signal" warnings)
- [ ] **Scene paths verified** (all target_scene paths exist)
- [ ] **Basic game loop functional** (Main → Lobby → Game works)

## 🔍 **DIAGNOSTIC COMMANDS**

### **Debug Key Bindings** (Built into DebugManager):
```
F3 - Toggle debug panel visibility
F4 - Validate current scene structure  
F5 - Reset debug state
F6 - Validate all systems (NEW - tests autoloads)
F7 - Cycle UI themes (if UIThemeManager working)
```

### **Console Commands** (Use DebugManager in scripts):
```gdscript
# Test specific systems
DebugManager.validate_current_scene()
DebugManager.validate_new_systems() 
DebugManager.log_info("Test message")

# Test scene transitions
SceneManager.change_scene_to_lobby()
SceneManager.change_scene("res://scenes/levels/outdoor/Center.tscn")

# Test autoload availability
print("UIThemeManager available: ", UIThemeManager != null)
print("WorldMapManager available: ", WorldMapManager != null)
```

## 🎯 **SUCCESS INDICATORS**

### **Minimal Working State**:
- ✅ **Game starts** without parse errors
- ✅ **Main.tscn loads** and immediately transitions to Lobby.tscn
- ✅ **Lobby music plays** and menu buttons work
- ✅ **Character select loads** and confirms to OutdoorScene.tscn
- ✅ **Player movement works** with WASD keys
- ✅ **Debug keys respond** (F3, F4, F5, F6)

### **Full Working State**:
- ✅ **All autoloads load** without dependency errors
- ✅ **Scene transitions work** between all 3x3 world scenes
- ✅ **UI themes apply** correctly across all scenes
- ✅ **Notifications display** without blocking gameplay
- ✅ **Modal dialogs work** with proper input blocking
- ✅ **Debug validation passes** on all systems

## 🚀 **RECOVERY PROCEDURES**

### **If Everything Breaks**:
1. **Revert to working commit** (git reset --hard)
2. **Use SceneTemplate.tscn** as base for new scenes
3. **Test each autoload individually** by commenting others
4. **Build up complexity gradually** starting with Main → Lobby

### **Nuclear Option** (Last Resort):
1. **Comment out all autoloads** except DebugManager and SceneManager
2. **Test basic scene transitions** manually
3. **Add autoloads back one by one** until you find the problem
4. **Use minimal scenes** (Player + Camera only) for testing

## Common Startup Issues and Solutions

### 1. GameUI Script Errors (RESOLVED)
**Issue**: Duplicate function declaration for `handle_transition_complete`
**Error**: `Parser Error: Function "handle_transition_complete" already exists in class`
**Solution**: Removed duplicate function declaration in `scripts/ui/game_ui.gd` at line 45

### 2. UIThemeManager Class Recognition Issues (RESOLVED)
**Issue**: Godot cannot recognize `UIThemeConfig` class during startup
**Error**: 
- `Cannot get class 'UIThemeConfig'`
- `Parse Error: Can't create sub resource of type 'UIThemeConfig'`
- `Failed loading resource: res://data/ui/themes/default_theme.tres`

**Root Cause**: Class registration timing issues during Godot startup

**Solution**: Modified `Autoload/UIThemeManager.gd` to handle class recognition gracefully:
- Removed strict type hints for `UIThemeConfig` parameters
- Added fallback theme creation when theme resources fail to load
- Enhanced error handling in `load_theme_config()` method
- Added emergency fallback system in `_ready()` method

**Files Modified**:
- `Autoload/UIThemeManager.gd` - Made type system more flexible
- Function signatures updated to not depend on class recognition
- Added robust fallback mechanisms

### 3. SceneEdgeTransition Unused Signal (RESOLVED)
**Issue**: Signal `fade_complete` was declared but never emitted
**Solution**: Added proper signal emission in transition methods

### 4. Project Structure Validation

#### Required Autoloads (in order):
1. DebugManager
2. UIThemeManager  
3. DrivingConfigManager
4. (other autoloads...)

#### Critical Theme Files:
- `scripts/ui/ui_theme_config.gd` - UIThemeConfig class definition
- `data/ui/themes/default_theme.tres` - Default theme resource
- `data/ui/themes/*.tres` - Additional theme resources

### 5. Best Practices for Future Development

1. **Class Recognition Issues**: 
   - Always provide fallback mechanisms for custom classes
   - Use flexible typing when dealing with resources
   - Add comprehensive error handling

2. **Autoload Dependencies**:
   - Ensure proper initialization order
   - Use `await get_tree().process_frame` for cross-autoload communication
   - Always check autoload availability before use

3. **Theme System**:
   - The UIThemeManager now gracefully handles missing UIThemeConfig classes
   - Fallback themes are automatically created if resource loading fails
   - All theme operations are logged for debugging

### 6. Startup Success Indicators

When startup is working correctly, you should see:
```
UIThemeManager: Phase 1 initialized
UIThemeManager: Attempting to load default theme...
UIThemeManager: Initialized 4 theme definitions
UIThemeManager: Theme system ready
```

If fallback is triggered:
```
UIThemeManager: Default theme failed, creating emergency fallback...
UIThemeManager: Emergency fallback theme created
```

### 7. Individual Scene Testing Issues (RESOLVED)

**Issue**: Scenes work when run through normal game flow (Main → Lobby → Game) but fail when tested individually
**Root Cause**: Individual scenes bypass SceneManager initialization and autoload integration

**Solution**: Created `SceneInitializationHelper` class to ensure scenes work standalone:

**Files Added**:
- `scripts/scene_initialization_helper.gd` - Standalone scene initialization
- Updated `scripts/outdoor_scene.gd` - Enhanced initialization pattern

**Benefits**:
- Scenes auto-detect standalone vs normal testing
- Automatic SceneManager synchronization
- Missing player auto-creation for testing
- UI theme application for individual scenes
- Proper autoload validation and fallbacks

**Usage Pattern**:
```gdscript
func _ready():
    await initialize_scene()

func initialize_scene():
    await get_tree().process_frame
    
    # Enhanced initialization for standalone testing
    if is_standalone_testing():
        await SceneInitializationHelper.ensure_scene_ready_for_testing(self)
        SceneInitializationHelper.setup_scene_type_defaults(self, "outdoor")
        SceneInitializationHelper.create_test_player_if_missing(self)
        await SceneInitializationHelper.ensure_ui_theme_applied(self)
    
    # Normal initialization
    setup_doorway_connections()
    register_with_systems()
    finalize_scene_setup()
```

### 8. Best Practices for Scene Development

**Always Include Scene Testing Support**:
- Use `SceneInitializationHelper.ensure_scene_ready_for_testing()` in `_ready()`
- Implement `is_standalone_testing()` detection
- Structure initialization to work both ways

**Autoload Integration Pattern**:
- Always check autoload availability before use
- Provide meaningful fallbacks when autoloads are missing
- Use `await get_tree().process_frame` for autoload timing

### 9. Quick Scene Testing Solutions

**Problem**: Individual scenes still failing to load properly

**Quick Fix Options**:

1. **Option A**: Update existing scene script with enhanced initialization (recommended for permanent scenes)
2. **Option B**: Attach `SimpleSceneTest` script for quick testing (temporary solution)

**Option B - Quick Testing Script**:
```gdscript
# Simply attach scripts/simple_scene_test.gd to any scene root node
# Provides instant standalone testing with:
# - F1: Print scene info
# - F2: Validate scene setup  
# - ESC: Return to lobby
# - Auto-player creation
# - Theme application
```

**Recent Fixes Applied**:
- ✅ Fixed unused parameter warning in SceneInitializationHelper
- ✅ Improved UIThemeManager error handling (reduces console spam)
- ✅ Enhanced theme initialization for standalone testing
- ✅ Created SimpleSceneTest for instant scene testing

### 10. Emergency Testing Workflow

**If a scene won't load individually**:

1. **Attach SimpleSceneTest script** to the scene root node
2. **Set scene_type** to appropriate value ("outdoor", "indoor", "test")
3. **Enable auto_create_player** if scene needs a player
4. **Run scene** - should now work standalone
5. **Use F1/F2 keys** for debugging info
6. **Use ESC** to return to main game

**For permanent solutions**:
- Use the enhanced initialization pattern from `outdoor_scene.gd`
- Integrate SceneInitializationHelper into existing scene scripts

### 11. Future Improvements

- Consider implementing a theme validation tool
- Add more robust class registration checking  
- Implement theme hot-reloading for development
- Extend SceneInitializationHelper for more scene types
- Create scene testing templates for different scene types

## 🚨 **CRITICAL BREAKTHROUGH: Individual Scene Testing**

### **ROOT CAUSE DISCOVERED** ✅

**Why Main.tscn works but outdoor scenes crash:**

**Main.tscn Structure (WORKS):**
```
Main.tscn
├── Node2D (with simple main.gd script)
└── [NO GameUI, NO complex dependencies]
```

**Outdoor Scene Structure (CRASHES):**
```
Center.tscn  
├── Node2D (with outdoor_scene.gd script)
├── Environment (TileMaps)
├── Player.tscn
├── Camera2D  
└── UI → GameUI.tscn ← **CRASH POINT**
```

**The Problem:** GameUI.gd tries to call autoloads that don't exist:
- ✅ `UIThemeManager` - exists but broken
- ❌ `UIStateManager` - **MISSING** (causes immediate crash)
- ❌ `NotificationManager` - **MISSING** 

### **IMMEDIATE FIX APPLIED** ✅

**Fixed GameUI.gd lines 52-56:**
```gdscript
# OLD (CRASHES):
UIStateManager.register_ui_component(self)

# NEW (WORKS):
if UIStateManager:
    UIStateManager.register_ui_component(self)
    print("GameUI: Registered with UIStateManager")
else:
    print("GameUI: UIStateManager not available - continuing without state management")
```

**Additional Safeguards Added:**
- ✅ All `NotificationManager` calls now have null checks
- ✅ All `UIStateManager` calls now have null checks
- ✅ Reduced console spam from missing autoloads
- ✅ GameUI now fails gracefully instead of crashing

### **TESTING STATUS** 🧪

**Should Now Work:**
- ✅ Individual outdoor scenes (Center.tscn, North.tscn, etc.)
- ✅ GameUI loads without crashing
- ✅ UI is hidden by default (`visible = false`) 
- ✅ Basic movement and scene functionality

**Next Test:** Try playing `scenes/levels/outdoor/Center.tscn` individually

This guide provides systematic troubleshooting for startup issues while preserving your working game architecture. 