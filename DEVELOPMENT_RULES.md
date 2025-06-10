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
Phase 1: Foundation (CURRENT)
✅ Player movement & animation
✅ Camera system
✅ Basic scene structure
⏳ Environment building (tilemaps)

Phase 2: Core Systems
- Scene transitions
- UI integration  
- Audio system connection
- Basic interaction framework

Phase 3: Content & Polish
- Multiple perspective implementation
- Advanced gameplay systems
- Content creation pipeline
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
- ✅ **Autoload singletons** for global systems

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