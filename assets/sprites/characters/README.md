# Character Sprite Development Guide

## Overview

This guide outlines the complete workflow for creating custom character sprites in Aseprite for a top-down 2D 32x32 pixel game in Godot, with emphasis on:
- **Modular layering systems** for in-game customization
- **Animation workflows** optimized for multiple character variants
- **Portrait creation** for NPCs and UI systems
- **Efficient sprite sheet management** for large-scale character rosters

## Aseprite Workflow Strategy

### Core Design Philosophy

**Layer-Based Character Construction**: Each character is built as a stack of independent layers that can be mixed, matched, and customized:
- **Base Layer**: Body shape, skin tone, basic anatomy
- **Clothing Layers**: Shirts, pants, accessories (each as separate layers)
- **Hair Layers**: Different styles and colors
- **Equipment Layers**: Weapons, tools, special items
- **Expression Layers**: Eyes, mouths for emotion variants

### Project Structure

#### File Organization
```
characters/
├── source/                    # Aseprite source files
│   ├── base_characters/       # Master character templates
│   ├── clothing_sets/         # Modular clothing components  
│   ├── portraits/             # Character portrait variants
│   └── exports/               # Generated sprite sheets
├── godot_imports/             # Auto-generated Godot-ready files
└── references/                # Source material and style guides
```

#### Master Template System
Create **base character templates** with standardized:
- Canvas size: **32x32 pixels** (or 64x64 for detailed characters)
- **8-frame walking cycle** (N, NE, E, SE, S, SW, W, NW directions)
- **Consistent layer naming** for automation scripts
- **Shared animation timing** across all character variants

## Animation Framework

### Core Animation Set (Required for All Characters)

1. **Idle Animations** (2-4 frames)
   - Breathing motion
   - Subtle body sway
   - Blinking for portraits

2. **Walk Cycle** (4-8 frames per direction)
   - 8-directional movement for top-down gameplay
   - Consistent stride length and timing
   - Synchronized arm and leg movement

3. **Interaction Animations** (2-6 frames)
   - Picking up objects
   - Opening doors/chests
   - Waving/greeting gestures

4. **Combat Animations** (Optional, 3-6 frames)
   - Basic attack swings
   - Defensive poses
   - Hit reactions

### Advanced Animation Techniques

#### Frame Management Strategy
- **Keyframe Planning**: Map out major poses before tweening
- **Onion Skinning**: Use Aseprite's onion skin feature for fluid motion
- **Reference Rotoscoping**: Study real movement for natural character motion

#### Animation Timing Guide
- **Idle**: 8-12 frames per second (slow, calming)
- **Walking**: 6-8 frames per second (natural gait)
- **Running**: 10-12 frames per second (energetic)
- **Combat**: 8-15 frames per second (snappy, impactful)

#### Layer Animation Workflow
1. **Rough Animation**: Block out movement with simple shapes
2. **Layer Isolation**: Animate each layer independently (body, clothing, hair)
3. **Synchronization**: Align timing across all layers
4. **Polish Pass**: Add secondary animation (hair bounce, cloth sway)

## Modular Character System

### Layer Hierarchy (Bottom to Top)
```
1. Background/Shadow
2. Body Base (skin tone, basic anatomy)
3. Undergarments 
4. Pants/Skirts
5. Shirts/Tops
6. Outerwear (coats, armor)
7. Hair Back (behind head)
8. Face/Head Details
9. Hair Front (over face)
10. Accessories (hats, glasses)
11. Weapons/Tools
12. Effects/Overlays
```

### Creating Interchangeable Components

#### Component Design Rules
- **Consistent anchor points**: All components align to the same body reference
- **Shared color palettes**: Use consistent color schemes across components
- **Style coherence**: Maintain visual consistency in line weight and shading
- **Performance optimization**: Keep layer count reasonable (8-12 layers max)

#### Color Variant Generation
1. **Base color mapping**: Define primary, secondary, accent colors
2. **Palette swapping**: Create color ramps for different skin tones, hair colors
3. **Material variation**: Different textures for clothing (leather, cloth, metal)

## Portrait Creation Workflow

### Portrait Specifications
- **Canvas Size**: 64x64 or 96x96 pixels for UI clarity
- **Style Consistency**: Match the game's overall art direction
- **Expression Range**: 3-5 emotional states per character
- **Format**: Front-facing or 3/4 view for personality

### NPC Portrait Strategy
1. **Base Template**: Create master portrait template
2. **Feature Variations**: Mix and match facial features, hair, clothing
3. **Emotion Layers**: Separate layers for different expressions
4. **Background Elements**: Simple backgrounds that reflect character role

### Portrait Animation (Optional)
- **Subtle breathing**: 2-3 frame chest movement
- **Blinking cycles**: 4-6 frame blink every 3-4 seconds  
- **Mouth movement**: For dialogue sync (3-4 mouth shapes)

## Godot Integration Strategy

### Export Configuration

#### Sprite Sheet Format
- **Individual Frames**: Export each animation frame separately for AnimatedSprite2D
- **Strip Format**: Export horizontal strips for AnimationPlayer workflows
- **Atlas Packing**: Use TexturePacker or Aseprite's sprite sheet feature

#### Layer Export Automation
```lua
-- Aseprite Script Template
function exportCharacterLayers()
    local sprite = app.activeSprite
    for i, layer in ipairs(sprite.layers) do
        if layer.isGroup then
            exportLayerGroup(layer)
        end
    end
end
```

### Godot Character Setup

#### Modular Character Scene Structure
```
CharacterBase (Node2D)
├── Body (AnimatedSprite2D)           # Base character body
├── Clothing (AnimatedSprite2D)       # Layered clothing system
├── Hair (AnimatedSprite2D)           # Hair variations
├── Equipment (AnimatedSprite2D)      # Weapons/tools
├── CollisionShape2D                  # Physics body
└── CharacterController (Script)     # Customization logic
```

#### Layer Management Script
```gdscript
class_name ModularCharacter
extends Node2D

@export var body_sprite: AnimatedSprite2D
@export var clothing_sprite: AnimatedSprite2D
@export var hair_sprite: AnimatedSprite2D

func change_clothing(clothing_id: String):
    clothing_sprite.sprite_frames = load("res://characters/clothing/" + clothing_id + ".tres")
    
func change_hair(hair_id: String):
    hair_sprite.sprite_frames = load("res://characters/hair/" + hair_id + ".tres")
```

## Asset Organization and Performance

### Sprite Sheet Optimization
- **Texture atlas packing**: Minimize draw calls by combining related sprites
- **Power-of-2 dimensions**: Use 512x512, 1024x1024 for optimal GPU performance
- **Consistent pixel density**: Maintain crisp pixel art scaling

### Memory Management
- **Sprite frame caching**: Preload frequently used character combinations
- **Dynamic loading**: Load character variations on-demand for large rosters
- **Compression settings**: Balance file size vs. image quality for mobile platforms

## Production Pipeline

### Character Creation Checklist
- [ ] Base character template created with all animation frames
- [ ] Layer hierarchy established and named consistently
- [ ] Color palette defined and applied
- [ ] Animation timing tested and refined
- [ ] Modular components created and tested
- [ ] Portrait variations completed
- [ ] Export settings configured for Godot
- [ ] Integration tested in game engine

### Quality Assurance
- [ ] All animations loop smoothly
- [ ] Layer combinations work correctly
- [ ] Color variants display properly
- [ ] Performance impact within acceptable limits
- [ ] Consistent art style across all variants

### Version Control
- [ ] Source .aseprite files backed up
- [ ] Export scripts documented and versioned
- [ ] Character documentation updated
- [ ] Integration examples provided

## Advanced Techniques

### Automation Scripts
Create Aseprite Lua scripts for:
- **Batch color palette swapping**
- **Automated layer export**
- **Animation validation**
- **Sprite sheet generation**

### Style Guidelines
- **Line weight**: Consistent 1-2 pixel outlines
- **Color theory**: Limited palettes with intentional color relationships
- **Anatomical proportions**: Stylized but consistent character proportions
- **Visual hierarchy**: Clear silhouettes and readable designs at game resolution

### Integration with Larger Sprite Sheets
- **Component mapping**: Track which sprite sheets contain which character parts
- **Batch processing**: Convert existing sprite sheets into modular components
- **Style matching**: Ensure new characters match existing art direction

## Tools and Resources

### Essential Aseprite Features
- **Onion skinning**: For smooth animation
- **Layer groups**: For organization
- **Tags**: For animation management
- **Slice tool**: For sprite sheet coordinates
- **Scripting**: For workflow automation

### External Tools Integration
- **TexturePacker**: For advanced sprite sheet optimization
- **Godot Import Pipeline**: Automated asset processing
- **Version Control**: Git LFS for binary asset management

### Reference Materials
- **Anatomy guides**: For proportionally correct characters
- **Animation reference**: For natural movement patterns
- **Color theory**: For cohesive visual design
- **Game design patterns**: For character progression systems

---

## Example Character Creation Process

1. **Concept**: Define character role, personality, visual elements
2. **Template Setup**: Start with base character template
3. **Layer Construction**: Build character using modular layer system
4. **Animation**: Apply walk cycle and key animations
5. **Variants**: Create color and equipment variations
6. **Portrait**: Design matching portrait for UI
7. **Export**: Generate Godot-ready sprite sheets
8. **Integration**: Import and test in game engine
9. **Polish**: Refine based on in-game testing

This workflow ensures efficient character creation while maintaining consistency, modularity, and performance optimization for your top-down 2D game project. 