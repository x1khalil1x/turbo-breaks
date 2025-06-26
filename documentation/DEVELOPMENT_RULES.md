# TURBO BREAKS: Development Rules & Context

🏁 **Established Best Practices for Building Turbo Breaks**

## Core Development Philosophy

### 1. **Foundation First, Features Later**
- ✅ **Solid base systems** before adding complexity
- ✅ **Test each component** in isolation before integration
- ✅ **Iterate on fundamentals** until they feel right
- ❌ **No feature creep** until core mechanics are polished

### 2. **Performance & Maintainability**
- ✅ **Scene transitions over large worlds** (Option A architecture)
- ✅ **Modular scene structure** with reusable components
- ✅ **Clear naming conventions** for all assets and scripts
- ✅ **Consistent code patterns** across similar systems

### 3. **Multi-Perspective Design Readiness**
- ✅ **Top-down foundation** established first
- ✅ **Flexible camera systems** that can adapt to different perspectives
- ✅ **Scalable asset pipeline** for different view angles
- ✅ **Unified collision and physics** across perspective changes

## Established Code Patterns

### Character Movement & Animation
```gdscript
# STANDARD PATTERN: 4-directional character system
class_name Player extends CharacterBody2D

var last_direction: String = "down"  # Always track facing direction
@export var speed: float = 200.0     # Configurable in inspector

# Movement: normalized velocity for consistent diagonal speed
velocity = direction.normalized() * speed

# Animation: directional naming convention
"idle_down", "idle_up", "idle_left", "idle_right"
"walk_down", "walk_up", "walk_left", "walk_right"
```

### Scene Architecture Rules
```
scenes/
├── characters/     # Reusable character components
├── levels/         # Individual playable areas (640x360)
├── ui/            # Interface components
└── transitions/   # Scene change effects

# RULE: Each level scene contains:
- Player instance (with disabled camera)
- Scene-specific Camera2D with TopDownCamera script
- TileMap for environment
- UI CanvasLayer
```

### Camera System Standards
```gdscript
# CRITICAL RULE: Only ONE Camera2D per scene
# - Level scenes (OutdoorScene.tscn) have the main Camera2D
# - Player.tscn has NO Camera2D node at all
# - This prevents camera conflicts and viewport confusion

# TopDownCamera configuration:
@export var follow_speed: float = 5.0
@export var dead_zone_radius: float = 32.0
@export var smooth_enabled: bool = true

# Camera limits define where camera CENTER can move:
# For 640x360 viewport showing world (0,0) to (1280,720):
limit_left = 320    # Half viewport width from left edge
limit_top = 180     # Half viewport height from top edge
limit_right = 960   # Total width minus half viewport width
limit_bottom = 540  # Total height minus half viewport height
```

## Asset Management Rules

### Sprite Import Settings
```
# For pixel art character sprites:
compress/mode = 0
detect_3d/compress_to = 0
process/fix_alpha_border = true

# Naming convention:
char7.png → Multiple directional animations
32x64 pixel sprites for character consistency
```

### Animation Conventions
```
# SpriteFrames resource naming:
- Default animation: "idle_down"
- 8 total animations minimum (4 idle + 4 walk)
- Frame rate: 5.0 FPS for most character animations
- Loop: true for idle and walk cycles
```

## Development Workflow

### Phase-Based Approach
```
Phase 1: Foundation ✅ COMPLETED
✅ Player movement & animation
✅ Camera system
✅ Basic scene structure
✅ UI system integration & autoload architecture
✅ Critical startup fixes & system safety
✅ Environment building (tilemaps)

Phase 2: Core Systems (CURRENT)
✅ Scene transitions (via MapManager)
✅ UI integration (GameUI + autoloads)
✅ Audio system connection
- Basic interaction framework
- Content creation pipeline

Phase 3: Content & Polish
- Multiple perspective implementation
- Advanced gameplay systems
- Performance optimization & polish
```

### Testing Standards
```
# Before advancing to next system:
1. Test movement in isolated Player scene
2. Test in actual level scenes
3. Verify camera behavior
4. Check performance with larger areas
5. Validate on different screen sizes
```

## Code Quality Rules

### Script Organization
```gdscript
# CLASS STRUCTURE TEMPLATE:
extends NodeType
class_name ClassName

@export var public_settings: type
@onready var node_references = $NodePath
var private_variables: type

func _ready() -> void:
    # Initialization only

func _process/_physics_process(delta):
    # Main update loop

func public_methods():
    # External interface

func private_methods():
    # Internal logic
```

### Error Prevention
```
# ALWAYS validate before use:
if node and node.has_method("method_name"):
    node.method_name()

if sprite.sprite_frames and sprite.sprite_frames.has_animation("anim"):
    sprite.play("anim")

# Use @onready for node references
# Use class_name for reusable components
```

## Technical Decisions Made

### Architecture Choices
- ✅ **Scene Transitions** (not seamless world)
- ✅ **CharacterBody2D** for player movement
- ✅ **AnimatedSprite2D** with SpriteFrames resources
- ✅ **TopDownCamera** with dead zone following
- ✅ **Autoload singletons** for global systems (DebugManager, UIThemeManager, UIStateManager, NotificationManager, DrivingConfigManager, WorldMapManager)
- ✅ **Null-safe initialization** with await process_frame patterns
- ✅ **Signal-based integration** with graceful fallbacks

### Input & Controls
- ✅ **Custom input actions** (move_up, move_down, move_left, move_right)
- ✅ **Normalized 8-directional movement**
- ✅ **Direction memory** for idle states

### Performance Targets
- ✅ **640x360 base resolution** with scaling
- ✅ **60 FPS target** on modest hardware
- ✅ **Memory efficient** scene loading
- ✅ **Quick scene transitions** under 0.5 seconds

## Future System Guidelines

### When Adding New Features
1. **Design the interface first** - how will it connect to existing systems?
2. **Create isolated test scene** - prove the concept works alone
3. **Follow established patterns** - maintain consistency with existing code
4. **Update this document** - record new patterns and decisions

### Multi-Perspective Preparation
- **Maintain consistent scale** across perspectives (32x32 tile standard)
- **Design unified collision systems** that work in any view
- **Plan perspective-specific camera behaviors**
- **Keep asset pipeline flexible** for different viewing angles

---

**This document should be referenced and updated throughout development to maintain consistency and quality.**

## Advanced Systems Implementation (Post-Foundation)

### Autoload System Integration (✅ COMPLETED)
```gdscript
# CRITICAL STARTUP FIX PATTERNS:
# 1. Dependency-ordered autoload loading (DebugManager first)
# 2. Null-safe connections with await get_tree().process_frame
# 3. Graceful fallback when dependencies unavailable
# 4. Signal validation before connecting

# AUTOLOAD DEPENDENCY CHAIN:
DebugManager → (SceneManager, UIThemeManager, UIStateManager) 
           → (NotificationManager, DrivingConfigManager) 
           → WorldMapManager

# Implementation: All autoloads use await pattern for safe initialization
```

### UI Theme System Integration (✅ COMPLETED)
```gdscript
# UITHEME RESOURCE PATTERN:
class_name UIThemeConfig extends Resource
# Complete theme resource creation with:
# - Button, panel, label, input styling
# - Color scheme management  
# - Font and accessibility settings
# - Runtime theme switching support

func create_theme_resource() -> Theme:
    # Generates complete Godot Theme from UIThemeConfig
    # Used by UIThemeManager for runtime theme application
    # Ensures all UI components receive consistent styling
```

## Advanced Systems Implementation (Post-Foundation)

### Shader & Visual Effects
```gdscript
# MENU BACKGROUND SHADER IMPLEMENTATION:
# Fine pixelation + color palette quantization for retro look
uniform float pixelation: hint_range(32.0, 512.0) = 128.0  # Fine pixel grid
uniform int palette_size: hint_range(2, 32) = 8            # Color reduction

# Shader placement: assets/shaders/menu_background.gdshader
# Application: Applied to UI/Background ColorRect with ShaderMaterial
# Effect: Creates animated, pixelated background with color quantization

# Key learning: Higher pixelation values = finer pixels (128+ for subtle effect)
```

### UI Component Architecture
```gdscript
# VOLUME CONTROL PATTERN - Modular UI Components:
extends Control
class_name VolumeControl

# Export configuration in scene
@export var expand_direction: String = "horizontal"  # or "vertical"

# Self-contained component with:
- Signal connections in _ready()
- Autoload references (MusicPlayer direct access)
- Expandable UI with smooth tweens
- Icon state management

# REUSABLE PATTERN: All UI components follow this structure
# - One scene file with script
# - Instance in other scenes
# - Customize via exported variables
```

### Music & Audio Management
```gdscript
# MUSIC PLAYER AUTOLOAD PATTERN:
extends AudioStreamPlayer

enum VolumeMode { MENU, GAMEPLAY }
var current_mode: VolumeMode = VolumeMode.MENU

# PERSISTENT AUDIO: Music continues across scene changes
# VOLUME MODES: Different volumes for different game states
# SIGNAL SYSTEM: UI components listen to volume_changed signal

# Implementation: Autoload + JSON catalog + volume control UI
```

### Collision System Architecture
```gdscript
# COLLISION LAYER ASSIGNMENT (Project Settings):
Layer 1: Player     (CharacterBody2D)
Layer 2: Walls      (StaticBody2D - buildings, obstacles) 
Layer 3: Items      (StaticBody2D - interactable objects)
Layer 4: Doorways   (Area2D - detection zones)
Layer 5: Boundaries (StaticBody2D - scene edges)

# RULE: Set collision in original scene, inherits everywhere
# Player collision: Set in Player.tscn (Layer 1, Mask 2+5)
# Building collision: Add StaticBody2D child nodes per building

# TILEMAP COLLISION: Automatic via TileMapLayer named "Collision"
```

### Doorway & Transition System
```gdscript
# DOORWAY COMPONENT PATTERN:
extends Area2D
class_name Doorway

@export var target_scene: String = ""
@export var target_position: Vector2 = Vector2.ZERO
@export var doorway_id: String = ""

signal player_entered_doorway(target_scene: String, target_position: Vector2)

# MODULAR DESIGN: One component, infinite reuse
# SIGNAL-BASED: Doorway → Scene → SceneManager → MapManager
# CONFIGURABLE: Each instance sets target via inspector
```

### Scene Management & World Building
```gdscript
# MAP MANAGER - 3x3 WORLD GRID:
# Autoload: MapManager.gd handles scene navigation
var map_scenes = {
    Vector2(0, 0): "NorthWest.tscn", Vector2(1, 0): "North.tscn", 
    Vector2(2, 0): "NorthEast.tscn", Vector2(0, 1): "West.tscn",
    Vector2(1, 1): "Center.tscn",    Vector2(2, 1): "East.tscn",
    Vector2(0, 2): "SouthWest.tscn", Vector2(1, 2): "South.tscn",
    Vector2(2, 2): "SouthEast.tscn"
}

# SCENE TEMPLATE STRUCTURE:
OutdoorScene/
├── Environment/ (TileMap, static visuals)
├── Interactions/ (Doorways, NPCs)
├── Player/ (instanced, positioned per scene)
└── UI/ (GameUI, consistent across scenes)

# SPAWN POSITIONING: Players enter at opposite edge of movement direction
```

### Font Management System
```gdscript
# FONTMANAGER AUTOLOAD PATTERN:
enum FontType { MENU, DIALOGUE, TITLE, RETRO, RACING, MONOSPACE }

# SELECTIVE APPLICATION: Apply to labels only, not buttons
# THEME OVERRIDE: Uses add_theme_font_override() pattern
# PRESET FUNCTIONS: make_title_text(), make_racing_text(), etc.

# RULE: Don't override button fonts - breaks default styling
```

## Global Folder Implementation Roadmap

### Likely Future Implementations
```gdscript
# From "You Wake Up in a Forest" analysis:

event_bus.gd     # Global signal system for UI interactions
├── item_box_hovered(position, item_box_size, hint_text)
├── edge_hovered(position, dir, hint_text)  
└── transition_started/ended signals

constants.gd     # Game constants and text formatting
├── ITEM_TEXTURES dictionary mapping
├── UI color formatting constants
└── Special command/action strings

enums.gd         # Type-safe enumerations
├── Item { HANDGUN, BULLET, HONEY, KNIFE, FLASHLIGHT, KEY }
├── Flag { SHOT_FOX, ATE_MUSHROOM, KILLED_STRANGER }
└── Clear game state representation
```

### Possible Future Implementations
```gdscript
command_interpreter.gd  # Text-based command parsing
scenarios.gd           # Story content and dialogue management

# FINITE STATE MACHINE (FSM) Pattern:
# Tutorial → Story → Action → ActionResult → SpecialEvent → Death/End
# Useful for complex game state flows beyond simple scene transitions
```

### Component Reusability Rules
```gdscript
# DOORWAY VISUAL FEEDBACK:
# Development: Visible collision shapes help place doorways
# Production: Remove visual feedback, keep invisible triggers
# Toggle via export variable or conditional compilation

# STATIC OBSTACLE PATTERN:
extends StaticBody2D
class_name StaticObstacle
@export var obstacle_type: String = "generic"
# One script, many uses: cars, signs, furniture, etc.
```

## Doorway System Implementation Guide

### Core Doorway Component
The doorway system uses a modular `Area2D`-based component that handles scene transitions through configurable properties and signal-based communication.

#### Doorway Component Structure
```gdscript
# scenes/components/Doorway.gd
extends Area2D
class_name Doorway

@export var target_scene: String = ""       # Scene path to load
@export var target_position: Vector2 = Vector2.ZERO  # Where player spawns
@export var doorway_id: String = ""         # For debugging/identification

signal player_entered_doorway(target_scene: String, target_position: Vector2)
```

#### Scene Setup Instructions
```
1. Add Doorway.tscn to your scene
2. Position the doorway at transition point (building entrance, area border, etc.)
3. Configure in Inspector:
   - target_scene: "res://scenes/levels/TargetScene.tscn"
   - target_position: Vector2(100, 200) # Where player appears in target scene
   - doorway_id: "house_front_door" # For development/debugging
4. Connect doorway signal to scene's transition handler
```

#### Signal Flow Architecture
```
Player enters Area2D → Doorway.player_entered_doorway signal
                    ↓
Scene receives signal → Scene.transition_to_scene() 
                    ↓
SceneManager.change_scene_to_file(target_scene, target_position)
                    ↓
MapManager.update_current_scene() # If using grid system
```

#### Scene Integration Pattern
```gdscript
# In your level scene script:
extends Node2D

func _ready():
    # Connect all doorways in the scene
    for doorway in get_tree().get_nodes_in_group("doorways"):
        doorway.player_entered_doorway.connect(_on_doorway_entered)

func _on_doorway_entered(target_scene: String, target_position: Vector2):
    SceneManager.change_scene_to_file(target_scene, target_position)
```

#### Collision Layer Setup
```
# Doorway collision configuration:
- Layer: 4 (Doorways)
- Mask: 1 (Player)
- Body must be in "player" group for detection
- Collision shape: RectangleShape2D sized for doorway opening
```

#### Development vs Production
```gdscript
# VISUAL FEEDBACK TOGGLE:
@export var show_debug_shape: bool = true  # Set false for production

func _ready():
    if show_debug_shape:
        # Auto-generated collision shape for development
        var collision_shape = CollisionShape2D.new()
        var rectangle_shape = RectangleShape2D.new()
        rectangle_shape.size = Vector2(64, 32)
        collision_shape.shape = rectangle_shape
        add_child(collision_shape)
```

#### Common Doorway Configurations
```gdscript
# BUILDING ENTRANCE:
target_scene = "res://scenes/levels/interior/House01Interior.tscn"
target_position = Vector2(320, 500)  # Near interior door
doorway_id = "house_01_entrance"

# SCENE BORDER (to adjacent outdoor area):
target_scene = "res://scenes/levels/outdoor/NorthField.tscn" 
target_position = Vector2(640, 680)  # Bottom of new scene
doorway_id = "field_north_border"

# VEHICLE ENTRANCE:
target_scene = "res://scenes/levels/drive_mode/Highway01.tscn"
target_position = Vector2(100, 360)  # Driver's seat
doorway_id = "car_driver_door"
```

#### Troubleshooting Checklist
```
✅ Player CharacterBody2D in "player" group?
✅ Doorway Area2D on collision layer 4?
✅ Doorway monitoring = true in Inspector?
✅ target_scene path exists and is correct?
✅ target_position within target scene bounds?
✅ Signal connected in scene's _ready() function?
✅ SceneManager autoload exists and works?
```

### Best Practices
- **Consistent sizing**: Use 64x32 for standard doorways, 96x32 for wide entrances
- **Clear naming**: Use descriptive doorway_id values for debugging
- **Bi-directional**: Add return doorway in target scene back to origin  
- **Player positioning**: Place target_position away from walls/obstacles
- **Visual alignment**: Position doorway precisely over visual door/opening

## Scalable Scene Management Architectures

### Better Architectures for Hundreds of Scenes

When scaling beyond small grid systems (7-20 scenes), consider these approaches:

1. **Hierarchical Scene Management** (Recommended):
   ```
   Regions (Cities, Wilderness, Underground)
   ├── Areas (Neighborhoods, Forest Sections, Cave Systems)  
   │   ├── Scenes (Individual locations)
   ```

2. **Graph-Based Connections**: 
   - Scenes connected by relationships, not grid positions
   - Database/JSON defining scene connections
   - More flexible than rigid grid systems

3. **Streaming World System**: 
   - Load adjacent scenes in background
   - Unload distant scenes to manage memory
   - Seamless world feel with scene-based architecture

4. **Region Managers**: 
   - CityManager, WildernessManager, DungeonManager
   - Each handles their area's scene loading logic
   - MapManager becomes a coordinator, not a grid

### Recommended Evolution Path
- **Phase 1**: Use grid system while learning/prototyping (7-20 scenes)
- **Phase 2**: Implement hierarchical scene graph (20-100 scenes)  
- **Phase 3**: Add streaming and region management (100+ scenes)

*Note: The doorway system scales perfectly to any architecture - only the MapManager needs evolution for larger worlds.*

## Scene Integration Workflow

### Adding Collision to Existing Scenes
```
1. Project Settings → Layer Names → 2D Physics → Set layer names
2. TileMap: Add "Collision" TileMapLayer (automatic)
3. Objects: Select node → Inspector → Collision section
   - Layer: What it is (Player=1, Walls=2, etc.)
   - Mask: What it collides with (Player mask=2+5)
4. Player: Set once in Player.tscn, applies everywhere
5. Buildings: Add StaticBody2D children per building
```

### Camera & Bounds Integration
```gdscript
# WORLD BOUNDS + CAMERA LIMITS:
# Camera limits: Where camera center can move
# World bounds: StaticBody2D walls at scene edges
# Both needed: Camera stops + Player stops

# 1080x720 scene limits:
camera.limit_left = 0
camera.limit_right = 1080
camera.limit_top = 0  
camera.limit_bottom = 720
```

## Key Learning Patterns

### Shader Development
- **Test incrementally**: Start simple, add effects one by one
- **Parameter tuning**: Use inspector-exposed uniforms for real-time adjustment
- **Resolution awareness**: Pixelation values need testing at target resolution

### UI Component Design  
- **Self-contained**: Each component handles own signals and state
- **Autoload integration**: Direct references to global systems
- **Visual feedback**: Debug prints for troubleshooting

### Collision Implementation
- **Layer strategy**: Plan collision layers before implementing
- **Inheritance rules**: Set in source scenes, inherits in instances  
- **Testing approach**: Start with player movement, add obstacles incrementally

### Scene Architecture
- **Modular doorways**: One component, configured per instance
- **Signal chains**: Doorway → Scene → Manager for clean separation
- **Template reuse**: Copy and customize base scene templates

---

**These advanced systems build upon the foundation established in earlier phases. Reference this section when implementing complex interactions, UI systems, or world navigation features.** 

## UI Design Standards

### Core UI Philosophy
```
# ACCESSIBILITY-FIRST DESIGN
- ✅ **Browser & Mobile Compatible**: All UI works on touch and mouse
- ✅ **Clean & Minimal**: No clutter, clear visual hierarchy
- ✅ **Consistent Iconography**: PNG icons for reliability over SVG
- ✅ **Persistent vs Menu-Only**: Smart separation of always-visible vs contextual UI
```

### Global UI Architecture
```
# PERSISTENT UI ELEMENTS (Always Visible):
- MiniMap: Core navigation aid (simple dot-on-grid initially)
- MenuAccess: Logo-based button (PNG icon) for main menu access
- Sound Toggle: Simple mute/unmute switch (not volume slider)
- HotKeys Display: Context-sensitive key hints
- Notification Area: System messages and alerts

# MENU-ONLY UI ELEMENTS (Main Menu Access):
- Volume Control: Full audio settings and music selection
- Game Settings: Graphics, controls, preferences
- Save/Load System: Game state management
- Advanced Options: Developer/debug features
```

### UI Component Standards
```gdscript
# STANDARD UI SCENE STRUCTURE:
GameUI.tscn (CanvasLayer)
├── PersistentUI/
│   ├── MiniMap (Control)
│   ├── MenuButton (TextureButton - PNG logo)
│   ├── SoundToggle (CheckBox)
│   └── NotificationArea (RichTextLabel)
├── HotKeyDisplay/ (Context-sensitive)
└── MenuOverlay/ (Hidden by default)

# UI POSITIONING RULES:
- Top-left: MiniMap
- Top-right: Menu access & sound toggle  
- Bottom: Context-sensitive hotkeys
- Center: Notifications (temporary)
```

### Visual Design Guidelines
```
# ICON STANDARDS:
- Format: PNG (not SVG) for pixel-perfect rendering
- Size: 32x32 or 64x64 for UI consistency with game assets
- Style: Match game's pixel art aesthetic
- Logo: User's provided logo asset for menu button

# COLOR & CONTRAST:
- High contrast for accessibility
- Consistent with game's color palette
- Clear visual states (normal, hover, pressed, disabled)

# TYPOGRAPHY:
- Readable fonts at small sizes
- Consistent font hierarchy
- Proper contrast ratios
```

### Implementation Priorities
```
# PHASE 1 (Foundation):
✅ Basic GameUI scene structure
⏳ MiniMap placeholder (dot-on-grid)
⏳ Menu access button with logo
⏳ Simple sound toggle

# PHASE 2 (Functionality):
- Working MiniMap with scene representation
- Full menu system integration
- Notification system implementation
- HotKey context system

# PHASE 3 (Polish):
- Smooth UI animations
- Advanced MiniMap features
- Comprehensive settings menu
- Mobile-optimized touch targets
```

### UI Integration Rules
```gdscript
# SCENE INTEGRATION PATTERN:
# Each level scene includes:
[node name="UI" type="CanvasLayer" parent="."]
[node name="GameUi" parent="UI" instance=ExtResource("GameUI.tscn")]

# GLOBAL UI ACCESS:
# UI elements communicate through signals, not direct references
# Use autoload singletons for UI state management
# Maintain UI state across scene transitions
```

---

## NEXT STEPS FOR DEVELOPMENT

### Phase 1: Critical Systems Debugging & Fixes

#### A. Doorway System Loop Fix (PRIORITY 1)
**Issue Analysis**: Players spawn at doorway positions and immediately trigger scene transitions back, creating loops.

**Root Cause**: Target spawn positions are too close to doorway trigger areas, causing immediate re-detection.

**Immediate Fixes Required**:
```gdscript
# 1. Add doorway cooldown system to prevent rapid transitions
extends Area2D
class_name Doorway

var transition_cooldown: float = 0.0
const COOLDOWN_TIME: float = 1.0  # 1 second cooldown

func _process(delta):
    if transition_cooldown > 0:
        transition_cooldown -= delta

func _on_body_entered(body):
    if body.is_in_group("player") and transition_cooldown <= 0:
        transition_cooldown = COOLDOWN_TIME
        player_entered_doorway.emit(target_scene, target_position)
```

**Position Corrections Needed**:
- **MainBuilding Exit**: Change target_position from `Vector2(208, 100)` to `Vector2(208, 140)` (safer distance)
- **Center to MainBuilding**: Change target_position from `Vector2(540, 600)` to `Vector2(540, 550)` (safer distance)
- **All border doorways**: Ensure 50+ pixel buffer from edge doorways

#### B. Enhanced Debug Tools Implementation

**1. Debug Manager Enhancements**:
```gdscript
# Add to DebugManager.gd:
func log_scene_transition(from_scene: String, to_scene: String, position: Vector2):
    debug_log("TRANSITION: %s → %s at %s" % [from_scene, to_scene, position], LogLevel.INFO)

func validate_doorway_positioning():
    # Check for doorways too close to each other
    # Validate spawn positions are within scene bounds
    # Ensure no overlapping trigger areas
```

**2. Visual Debug Indicators**:
- Doorway boundaries visible in debug mode
- Spawn position markers in target scenes
- Scene transition history display

#### C. Scene Configuration Standardization

**Updated Scene Integration Pattern**:
```gdscript
# STANDARD LEVEL SCENE STRUCTURE:
extends Node2D

@export var scene_id: String = ""
@export var scene_type: String = "outdoor"  # outdoor, indoor, special

func _ready():
    # 1. Connect doorway signals
    setup_doorway_connections()
    
    # 2. Register with MapManager if outdoor
    if scene_type == "outdoor":
        MapManager.register_current_scene(scene_id)
    
    # 3. Initialize debug logging
    if DebugManager:
        DebugManager.log_info("Scene loaded: " + scene_id)
        DebugManager.validate_current_scene()

func setup_doorway_connections():
    await get_tree().process_frame  # Ensure all nodes ready
    
    for doorway in get_tree().get_nodes_in_group("doorways"):
        if not doorway.player_entered_doorway.is_connected(_on_doorway_entered):
            doorway.player_entered_doorway.connect(_on_doorway_entered)
        
        # Validate doorway configuration
        if DebugManager:
            var validation = DebugManager.validate_doorway(doorway)
            if not validation.valid:
                DebugManager.log_warning("Doorway issues: " + str(validation.issues))

func _on_doorway_entered(target_scene: String, target_position: Vector2):
    if DebugManager:
        DebugManager.log_scene_transition(name, target_scene, target_position)
    
    SceneManager.change_scene_with_position(target_scene, target_position)
```

### Phase 2: Character Select Enhancement & UI Integration

#### A. Character Select Screen Completion

**Current Status**: ✅ Professional Anno Mutationem styling implemented, ✅ Equipment/module slot system, ✅ Basic navigation

**Remaining Tasks**:
1. **Equipment Selection Popups**:
   ```gdscript
   # Add to character_select.gd:
   func show_equipment_selection(slot_type: String):
       var popup = preload("res://scenes/UI/EquipmentSelectionPopup.tscn").instantiate()
       popup.setup_for_slot(slot_type, current_character_data)
       popup.equipment_selected.connect(_on_equipment_selected)
       add_child(popup)
   ```

2. **Character Validation System** (partially implemented):
   ```gdscript
   func validate_character_state() -> Dictionary:
       var result = {"valid": true, "issues": []}
       
       # Check required equipment
       if not current_character_data.equipped_weapon:
           result.issues.append("No weapon equipped")
           result.valid = false
       
       # Check name validity
       if current_character_data.name.strip_edges() == "":
           result.issues.append("Character name required")
           result.valid = false
       
       return result
   ```

3. **Character Data Persistence**: Integration with save/load system

#### B. Persistent UI Elements Implementation

**Global UI Architecture** (needs implementation):
```gdscript
# Create GlobalUI.gd autoload:
extends CanvasLayer
class_name GlobalUI

@onready var mini_map = $PersistentContainer/MiniMap
@onready var menu_button = $PersistentContainer/MenuAccess
@onready var sound_toggle = $PersistentContainer/SoundToggle
@onready var notification_area = $PersistentContainer/NotificationArea

func _ready():
    # Setup persistent UI that survives scene transitions
    process_mode = Node.PROCESS_MODE_ALWAYS
    
func show_notification(message: String, duration: float = 3.0):
    # Implementation for temporary notifications
    
func update_minimap_position(scene_id: String):
    # Update minimap based on current scene
```

**UI Components Needed**:
- **MiniMap**: Simple grid-based navigation display
- **MenuAccess**: Quick access to settings/save without full scene transition
- **NotificationSystem**: Game state messages and alerts
- **HotKeyDisplay**: Context-sensitive control hints

#### C. Scene Transition Improvements

**Recommended Transition System Enhancements**:
```gdscript
# Enhanced SceneManager.gd methods:
func change_scene_with_fade(target_scene: String, spawn_pos: Vector2, fade_time: float = 0.5):
    # Add visual transition effects
    # Prevent input during transitions
    # Handle loading states for complex scenes

func preload_adjacent_scenes():
    # Background loading for smoother transitions
    # Memory management for preloaded scenes
    # Cache frequently accessed scenes
```

### Phase 3: Advanced Systems Integration

#### A. Audio System Integration
- **Music Manager**: Seamless audio transitions between scenes
- **Spatial Audio**: Position-based sound effects
- **Dynamic Soundtrack**: Context-aware music selection

#### B. Multi-Perspective Preparation
- **Camera System Scaling**: Prepare for side-view and isometric modes
- **Asset Pipeline**: Consistent art style across perspectives
- **UI Adaptability**: Interface that works in all view modes

#### C. Performance Optimization
- **Scene Streaming**: Background loading/unloading for large worlds
- **Asset Optimization**: Texture compression and memory management
- **Debug Profiling**: Performance monitoring tools

### Implementation Priority Order

**Week 1 (Critical Fixes)**:
1. Fix doorway position overlaps causing loops
2. Implement doorway transition cooldown
3. Add enhanced debug visualization

**Week 2 (Character Select Polish)**:
1. Complete equipment/module selection popups
2. Implement character validation with user feedback
3. Add character creation workflow

**Week 3 (Persistent UI)**:
1. Implement GlobalUI autoload system
2. Create minimap with scene tracking
3. Add notification system for game events

**Week 4 (Integration & Testing)**:
1. Test all scene transitions thoroughly
2. Performance optimization and debugging
3. Prepare for multi-perspective implementation

### Success Metrics
- ✅ **Zero doorway transition loops** in testing
- ✅ **Character select → Game flow** works seamlessly
- ✅ **All debug tools functional** and helpful
- ✅ **Persistent UI elements** survive scene changes
- ✅ **Performance maintains 60fps** across all scenes

**This foundation will support all future game systems including driving mechanics, music gameplay, and multi-perspective viewing modes.** 