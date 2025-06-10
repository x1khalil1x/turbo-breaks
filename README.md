# TURBO BREAKS: An AMF Video Game??

🏁 **A racing-inspired JRPG experience grounded in music, art, and community. Find your crew, start your career, and build your creative empire - fast!**

![Game Screenshot](assets/screenshots/gameplay.png)
*Screenshot placeholder - add actual gameplay images*

## 🎮 About

Turbo Breaks is a game with two things at its core: 💽 music and 🏎️ driving. As the product of AMF as indie game dev, the game will be a platform for stylizing and showcasing the AMF ethos and catalog. By creating a hybrid interactive experience - part 💼 portfolio and part 🕹️ video game - users are welcome to engage with AMF and Turbo Breaks on their own terms.
Experience [key features placeholder] as you [gameplay description placeholder].

### Key Features
- [Feature 1 placeholder]
- [Feature 2 placeholder] 
- Dynamic scene transitions with shader-based intro sequence
- Professional audio system, featuring music from the AMF catalog and community, deeply integrated into both gameplay and portfolio experiences.
- [Additional features placeholder]

## 🎨 Inspirations

### Multi-Perspective Design Philosophy
Turbo Breaks features multiple camera perspectives to create varied gameplay experiences, following successful examples from industry leaders:

**Games Using Multiple Perspectives:**
- **The Legend of Zelda: A Link to the Past** - Top-down overworld + side-scrolling dungeons
- **Super Metroid** - Side-view + occasional top-down sections  
- **Hyper Light Drifter** - Top-down + isometric-style environments
- **CrossCode** - Isometric + side-view puzzle sections
- **Paper Mario** - Mix of side-view and 3D/isometric perspectives

**Three (3) Perspectives:**
1. **Top-Down** (Pokémon, Zelda style) - Navigation and exploration focus
2. **Side-View** (Platformers like Hollow Knight & Blasphemous) - Precision jumping and vertical challenges  
3. **Isometric/2.5D** (Eastward, Stardew Valley) - Depth illusion with grid-based logic

**Quality-of-life & Quality-of-Play**

## 🖥️ System Requirements

### Minimum Requirements
- **OS:** Windows 10 / macOS 10.15+ / Linux (Ubuntu 18.04+)
- **Processor:** [CPU requirement placeholder]
- **Memory:** [RAM requirement placeholder]
- **Graphics:** [GPU requirement placeholder]
- **Storage:** [Storage requirement placeholder]

### Recommended Requirements
- **OS:** Windows 11 / macOS 12+ / Linux (Ubuntu 20.04+)
- **Processor:** [Recommended CPU placeholder]
- **Memory:** [Recommended RAM placeholder]
- **Graphics:** [Recommended GPU placeholder]

## 📥 Installation

### Option 1: Download Release
1. Go to the [Releases](../../releases) page
2. Download the latest version for your platform
3. Extract the archive
4. Run the executable

### Option 2: Build from Source
1. Install [Godot Engine 4.4.1+](https://godotengine.org/download)
2. Clone this repository:
   ```bash
   git clone https://github.com/[username]/turbo-breaks.git
   cd turbo-breaks
   ```
3. Open the project in Godot
4. Export for your target platform

## 🎯 Controls

### Keyboard
- **[Key]:** [Action placeholder]
- **[Key]:** [Action placeholder]
- **ESC:** Pause/Menu
- **Any Key:** Skip intro sequence

### Gamepad
- [Gamepad controls placeholder]

## 🛠️ Development

### Built With
- **Engine:** Godot 4.4.1
- **Language:** GDScript
- **Audio:** OGG Vorbis format
- **Shaders:** Custom GLSL shaders for visual effects

### Technical Features
- **Scene Management:** Custom singleton-based scene system
- **Audio System:** Dynamic music system with crossfading
- **UI Animations:** Tween-based smooth transitions
- **Shader Effects:** Animated background with real-time gradients

### Development Setup

#### Prerequisites
- Godot Engine 4.4.1 or newer
- ffmpeg (for audio conversion)
- Homebrew (macOS) for tool management

#### Audio Workflow
Convert audio files to Godot-compatible format:
```bash
# Convert MP3 to OGG
ffmpeg -i music.mp3 -q:a 5 music.ogg

# Batch convert
for file in *.mp3; do ffmpeg -i "$file" "${file%.mp3}.ogg"; done
```

#### Project Structure
```
turbo-breaks/
├── audio/
│   ├── music/          # Background music (.ogg)
│   ├── sfx/           # Sound effects
│   └── voice/         # Voice/dialogue
├── assets/            # Images, textures, models
├── data/             # JSON configurations
├── scenes/           # Godot scene files
│   ├── intro/        # Intro sequence
│   ├── lobby/        # Main lobby/menu
│   └── drive_mode/   # Core gameplay
└── scripts/          # GDScript files
```

#### Key Systems
- **Player Character:** 4-directional movement with normalized velocity and animation system
- **TopDownCamera:** Smart follow camera with dead zone and auto-target finding
- **Scene Architecture:** Modular scene transitions (640x360 individual areas)
- **Camera Configuration:** Single-camera setup with proper viewport alignment
- **SceneManager:** Handles smooth scene transitions (planned)
- **MusicPlayer:** Manages background music with fade effects (planned)

#### Current Development Status

**Phase 1: Foundation** ✅ **COMPLETED**
- ✅ **Player Movement System:** 8-directional input with consistent diagonal speed
- ✅ **Animation Framework:** 4-directional idle/walk animations with direction memory
- ✅ **Camera System:** TopDownCamera with dead zone following and auto-target detection
- ✅ **Scene Structure:** Modular Player character, level scenes with proper camera setup
- ✅ **Camera Architecture:** Single-camera design eliminates conflicts between Player and Scene cameras
- ✅ **Asset Pipeline:** SpriteFrames with 32x64 character sprites, 8 animations total

**Technical Implementation:**
```gdscript
# Player movement uses CharacterBody2D with normalized velocity
velocity = direction.normalized() * speed

# Animation system tracks last direction for idle states
var last_direction: String = "down"

# Camera setup: ONE camera per scene (in OutdoorScene, NOT in Player)
# Player.tscn has NO Camera2D node to prevent conflicts

# Naming convention for animations:
"idle_down", "idle_up", "idle_left", "idle_right"
"walk_down", "walk_up", "walk_left", "walk_right"
```

**Next Phase Preview:**
- **Environment Building:** TileMap setup and collision systems
- **Scene Transitions:** Seamless movement between areas
- **UI Integration:** HUD, menus, and interaction prompts

### Tileset Development Strategy

#### Multi-Perspective Approach
Our development follows a phased approach to handle three distinct camera perspectives while maintaining visual consistency and manageable complexity.

**Development Phases:**
1. **Phase 1: Top-Down Foundation** (Months 1-2) - Establish core art pipeline and style rules
2. **Phase 2: Side-View Expansion** (Months 3-4) - Add platformer mechanics and transition systems  
3. **Phase 3: Isometric Polish** (Months 5+) - Complete the perspective trilogy with 2.5D depth

**Technical Benefits:**
- **Varied Gameplay**: Each perspective naturally encourages different mechanics
- **World Building**: Show the same spaces from different angles for richer storytelling
- **Pacing Control**: Switch perspectives to change game feel and difficulty
- **Modular Systems**: Forces clean, separated architecture that scales well

#### Critical Pitfalls to Avoid

🚨 **Art Style Inconsistency**
- **Problem**: Each perspective feels like a different game
- **Solution**: Establish shared color palettes, lighting rules, and character proportions first
- **Tool**: Use `TileStandards` class for consistent measurements and colors

🚨 **Scale Confusion**  
- **Problem**: Character/object sizes don't make sense between perspectives
- **Solution**: Define canonical object sizes (e.g., "a door is always 2 tiles high")

🚨 **Physics/Collision Complexity**
- **Problem**: Different collision needs per perspective create messy systems
- **Solution**: Design unified collision layers with perspective-specific masks

🚨 **Development Time Explosion**
- **Problem**: 3x the asset creation work without proper planning
- **Solution**: Perfect the pipeline with ONE perspective before expanding

🚨 **Player Disorientation**
- **Problem**: Jarring transitions between perspectives  
- **Solution**: Use consistent UI elements, audio cues, and transition effects

#### Smart Workflow Strategy

**Starting Point: Top-Down Focus**
- Most forgiving perspective for learning tileset workflows
- Clear spatial relationships and collision boundaries
- Easier to prototype gameplay mechanics quickly
- Natural foundation for establishing art style rules

**Asset Pipeline:**
```
Concept → Rough Draft → Style Test → Final Polish → Integration Test
    ↓         ↓           ↓           ↓            ↓
 Sketches   Draft/     TileStandards  Final/    Production
           folder      validation     folder      scenes
```

**Quality Gates:**
- All tilesets must pass `TileStandards.validate_tileset_size()`
- Color palettes limited to `SHARED_PALETTE_SIZE + PERSPECTIVE_VARIANT_COLORS`  
- Performance testing with large maps before moving to Final/ folder
- Cross-perspective consistency checks using shared style guide

### TileMap Editor Workflow

#### Understanding the Three-Panel Interface

The TileMap editor consists of three primary panels that work together to create your game world:

**Main Viewport (Scene View)**
- **Purpose:** Your active canvas for placing, erasing, and arranging tiles
- **Primary Functions:** Visual tile placement, scene composition, layer visualization
- **Navigation:** Middle-click drag to pan, scroll wheel to zoom, grid overlay shows tile boundaries
- **Editing:** Left-click places selected tiles, right-click erases, Shift+drag for straight lines

**Tile Palette (Bottom Panel)**
- **Purpose:** Tile selection and brush management - your "color palette" for tiles
- **Organization:** Displays all tiles from your active TileSet resource
- **Selection:** Single-click to select individual tiles, drag to select multi-tile brushes
- **Modes:** Switch between Tiles/Patterns/Terrains tabs for different painting approaches

**Inspector Panel (Properties)**
- **Purpose:** TileMap configuration, layer management, and tile properties
- **Critical Settings:** 
  - `Tile Set` - Links to your .tres tileset resource
  - `Tile Size` - Must match your source image tile dimensions
  - `Tile Shape` - Square, Isometric, Hexagonal options
  - Layer management for terrain, collision, navigation

#### Essential TileMap Operations

**Basic Tile Placement:**
```
1. Select TileMap node in scene
2. Choose tile from bottom palette
3. Left-click in viewport to place
4. Right-click to erase individual tiles
5. Ctrl+Z to undo, Ctrl+Y to redo
```

**Advanced Placement Techniques:**
- **Line Drawing:** Hold Shift while dragging for straight lines
- **Rectangle Fill:** Select multiple tiles in palette, then paint as a group
- **Pattern Mode:** Create reusable tile combinations (buildings, decorations)
- **Terrain Mode:** Auto-connect tiles with matching terrain types

**Layer Management:**
- **Terrain Sets:** Organize tiles by gameplay function (walls, floors, decorations)
- **Physics Layers:** Define collision boundaries for player/enemy interaction
- **Navigation Layers:** Set pathfinding areas for AI movement
- **Custom Data Layers:** Add metadata (damage zones, trigger areas, etc.)

#### TileSet Import Best Practices

**Before Importing:**
1. Ensure sprite atlas has consistent tile sizes (16x16, 32x32, etc.)
2. Use transparent backgrounds for proper auto-detection
3. Organize atlas logically (all walls together, all floors together)
4. Test atlas in image editor to verify tile boundaries

**During Import Process:**
1. **Auto-Create Tiles:** Choose "Yes" for automatic tile detection
2. **Verify Detection:** Check that Godot correctly identified individual sprites
3. **Manual Cleanup:** Merge or split tiles if auto-detection missed anything
4. **Set Tile Properties:** Add collision, terrain tags, and custom data as needed

**Post-Import Optimization:**
1. **Test Performance:** Large tilemaps with many tiles can impact framerate
2. **Organize Terrain Sets:** Group related tiles for easier terrain painting
3. **Configure Physics:** Set up collision layers for gameplay mechanics
4. **Create Patterns:** Save common tile combinations for rapid level design

#### Troubleshooting Common Issues

**Tiles Not Appearing:**
- Verify TileSet resource is assigned to TileMap node
- Check tile size matches source image dimensions
- Ensure tileset atlas imported correctly in FileSystem dock

**Collision Not Working:**
- Enable collision layer in TileMap settings
- Verify individual tiles have collision shapes defined
- Check collision layers and masks match your player/enemy setup

**Performance Problems:**
- Use TileMap layers instead of multiple TileMap nodes
- Enable "Use Parent Material" for large maps
- Consider texture atlasing for many small tilesets

**Visual Artifacts:**
- Disable texture filtering on pixel art tilesets
- Use consistent tile sizes throughout your project
- Check for incorrect tile spacing in source atlas

### Known Issues
- [Issue placeholder]
- Ensure audio files are in OGG format for best compatibility
- [Additional issues placeholder]

## 🐛 Issues & Fixes

### Font Text Visibility Issues

#### **Issue: Font Demo Back Button Invisible Text**
**Problem:** The "Back to Lobby" button in the font showcase screen had completely invisible text, while lobby screen buttons showed text (but tinted with button colors).

**Root Cause:** The `FontManager.apply_font_to_control()` function only applies font and font size but doesn't set any text color overrides. Without explicit color settings, button text defaulted to transparent/invisible.

#### **Attempted Fix #1: FontManager + Color.WHITE (Failed)**
```gdscript
FontManager.apply_font_to_control(back_button, FontManager.FontType.MENU, 16)
back_button.add_theme_color_override("font_color", Color.WHITE)
```
**Why it failed:** The FontManager fonts may have had color conflicts or the Color.WHITE constant wasn't explicit enough for the theme override system.

#### **Working Fix: System Font + Explicit RGBA (Success)**
```gdscript
# Use system font (same as working lobby buttons)
var system_font = ThemeDB.fallback_font
back_button.add_theme_font_override("font", system_font)
back_button.add_theme_font_size_override("font_size", 18)

# Force explicit white colors with full RGBA values
back_button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
back_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
back_button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
back_button.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 1.0))
```

**Why it worked:** 
1. **System font reliability:** `ThemeDB.fallback_font` is guaranteed to exist and render properly
2. **Explicit RGBA values:** `Color(1.0, 1.0, 1.0, 1.0)` is more explicit than `Color.WHITE` constant
3. **All button states covered:** Ensures text is white in normal, hover, pressed, and focus states
4. **Matches working pattern:** Uses the exact same approach as the working lobby buttons

**Lesson:** When FontManager font loading fails or has issues, fall back to system fonts with explicit RGBA color values for reliable text visibility.

### Drive Mode Crash Investigation

#### **Issue: Drive Mode Button Crashes Application**
**Problem:** Clicking the "Enter Drive Mode" button on the lobby screen caused the application to crash with error: "Invalid access to property or key 'modulate' on a base object of type 'CanvasLayer'."

**Root Cause:** The DriveMode script was trying to apply `modulate` properties to a `CanvasLayer` node, but `CanvasLayer` nodes don't have a `modulate` property. Only `Node2D` and `Control` nodes support modulation.

**Problematic Code:**
```gdscript
@onready var ui = $UI  # CanvasLayer - no modulate property!

func _ready():
    ui.modulate.a = 0.0  # ERROR: CanvasLayer has no modulate
    var tween = create_tween()
    tween.tween_property(ui, "modulate:a", 1.0, 0.6)  # ERROR
```

**Working Fix:**
```gdscript
@onready var ui = $UI
@onready var background = $UI/Background      # ColorRect - has modulate
@onready var vbox_container = $UI/VBoxContainer  # VBoxContainer - has modulate

func _ready():
    # Apply modulate to children that support it, not the CanvasLayer
    background.modulate.a = 0.0
    vbox_container.modulate.a = 0.0
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(background, "modulate:a", 1.0, 0.6)
    tween.tween_property(vbox_container, "modulate:a", 1.0, 0.6)
```

**Why it worked:**
1. **Node Type Awareness:** `ColorRect` and `VBoxContainer` inherit from `Control`, which has `modulate`
2. **Proper Target Selection:** Applied fade effects to actual UI elements, not the container layer
3. **Parallel Tweening:** Both elements fade simultaneously for smooth visual effect

**Lesson:** Always check node inheritance when applying properties. `CanvasLayer` is a special node for UI layering and doesn't inherit visual properties like `modulate` from `Node2D` or `Control`.

## 🎨 Assets

### Audio Requirements
- **Music:** OGG Vorbis, 44.1kHz, stereo
- **SFX:** WAV or OGG, various sample rates
- Use ffmpeg for format conversion

### Graphics
- [Graphics requirements placeholder]

## 🤝 Contributing

[Contributing guidelines placeholder]

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

[License placeholder - specify your chosen license]

## 📞 Support

- **Issues:** [Report bugs](../../issues)
- **Discussions:** [Community discussions](../../discussions)
- **Contact:** [Contact information placeholder]

## 🙏 Credits

### Development Team
- **[Your Name]:** [Role placeholder]
- [Additional team members placeholder]

### Third-Party Assets
- [Asset credits placeholder]
- Godot Engine - [godotengine.org](https://godotengine.org)

### Special Thanks
- [Special thanks placeholder]

---

**Made with ❤️ using Godot Engine**

*Last updated: [5/29/25]* 