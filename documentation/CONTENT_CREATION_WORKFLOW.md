# TURBO BREAKS: Content Creation Workflow Pipeline

🏁 **Standardized Pipeline from Draft to Final Scenes**

## 🔄 WORKFLOW OVERVIEW

The content creation pipeline follows a **4-Step Process**:

```
WorldDraft.tscn → Template Selection → Asset Population → Scene Connection
   (Planning)      (Foundation)       (Content)        (Integration)
```

## 📋 STEP-BY-STEP WORKFLOW

### **Step 1: Layout Planning (WorldDraft.tscn)**
- Open `scenes/tools/WorldDraft.tscn`
- Plan overall 3×3 world layout using region markers
- Sketch basic tile placement for each biome
- Identify transition points between regions
- Export region screenshots for reference

### **Step 2: Template Selection & Setup**
Choose appropriate template based on zone type:

#### **Urban Zones** → `scenes/levels/templates/UrbanZoneTemplate.tscn`
- **TileMap Layers**: Ground, Roads, Buildings, UrbanDecor, Collision
- **Interaction Areas**: BuildingEntrances, VehicleSpawns, InfoSigns
- **Use Cases**: City center, downtown, commercial districts

#### **Nature Zones** → `scenes/levels/templates/NatureZoneTemplate.tscn`
- **TileMap Layers**: Terrain, Water, Vegetation, Structures, NaturalFeatures
- **Interaction Areas**: Landmarks, DiscoverableItems, WildlifeSpawns
- **Use Cases**: Forest, mountain, coastal, rural areas

#### **Highway Zones** → `scenes/levels/templates/HighwayZoneTemplate.tscn`
- **TileMap Layers**: Ground, Highway, RoadMarkings, Barriers, Signage
- **Interaction Areas**: DrivingTriggers, ServiceStations, SpeedZones
- **Use Cases**: Racing areas, major roads, vehicle-focused zones

### **Step 3: Asset Population & Design**

#### **TileMap Layer Workflow**:
1. **Base Layer** (-2 z-index): Ground textures, basic terrain
2. **Feature Layer** (-1 z-index): Roads, water, primary features
3. **Object Layer** (0 z-index): Buildings, large structures
4. **Detail Layer** (1+ z-index): Decorations, small objects (Y-sort enabled)
5. **Collision Layer** (10 z-index): Invisible collision shapes

#### **Asset Guidelines**:
- **Ground**: Use consistent tile patterns, avoid jarring transitions
- **Buildings**: Follow 32x32 grid alignment, add collision via StaticBody2D
- **Decoration**: Enable Y-sort for proper depth rendering
- **Collision**: Paint collision tiles for walls, boundaries, obstacles

### **Step 4: Scene Connection & Integration**

#### **Doorway Setup**:
```gdscript
# Add to Interactions/Doorways/ node
# Each doorway connects to adjacent scene in 3x3 grid

# Example: North border doorway
position = Vector2(640, 40)  # Top center of scene
target_scene = "res://scenes/levels/outdoor/North.tscn"
target_position = Vector2(640, 680)  # Bottom of target scene
```

#### **Scene Edge Transitions**:
- **North Edge**: Player exits at Y=40, enters target at Y=680
- **South Edge**: Player exits at Y=680, enters target at Y=40
- **West Edge**: Player exits at X=40, enters target at X=1240
- **East Edge**: Player exits at X=1240, enters target at X=40

## 🛠️ TECHNICAL STANDARDS

### **Scene Dimensions & Layout**
```
Scene Size: 1280×720 pixels
Player Spawn: Vector2(640, 360) - scene center
Camera Limits: left=0, top=0, right=1280, bottom=720
```

### **TileMap Layer Z-Index Standards**
```
Background: -2 (Ground, terrain)
Features: -1 (Roads, water)
Objects: 0 (Buildings, structures)
Details: 1+ (Decorations, Y-sort enabled)
Collision: 10 (Invisible collision layer)
```

### **Naming Conventions**
```
Scene Files: ZoneName.tscn (e.g., "Center.tscn", "NorthWest.tscn")
TileMap Layers: Semantic names (Ground, Buildings, Decoration, Collision)
Interaction Areas: Purpose-based (Doorways, NPCs, VehicleSpawns)
```

### **Performance Guidelines**
- **Keep total tile count per scene under 2000** for 60fps target
- **Use modulate for debug visibility** (Collision layer: red 30% alpha)
- **Enable Y-sort only on layers that need depth sorting**
- **Minimize overdraw** by using appropriate z-index values

## 🎨 ASSET INTEGRATION BEST PRACTICES

### **From WorldDraft to Final Scene**:
1. **Reference Export**: Export region screenshots from WorldDraft
2. **Template Duplication**: Save template with new scene name
3. **Layer-by-Layer Building**: Populate each TileMap layer systematically
4. **Collision Testing**: Enable collision visibility to verify player movement
5. **Doorway Validation**: Test transitions to adjacent scenes

### **Tile Placement Strategy**:
- **Start with largest elements** (buildings, major features)
- **Add pathways and connections** second
- **Fill with decorative details** last
- **Paint collision areas** throughout the process

### **Quality Checkpoints**:
- ✅ **Visual Consistency**: Does the scene match the biome theme?
- ✅ **Player Movement**: Can the player navigate freely?
- ✅ **Transition Points**: Do doorways connect to correct adjacent scenes?
- ✅ **Performance**: Does the scene maintain 60fps?
- ✅ **Collision Accuracy**: Are walls and obstacles properly blocked?

## 🔗 INTEGRATION WITH EXISTING SYSTEMS

### **MapManager Integration**:
Scenes automatically integrate with the existing 3×3 grid navigation:
```gdscript
# MapManager handles scene transitions via doorway signals
# Player position automatically calculated based on exit direction
# No additional code required for basic scene navigation
```

### **UI System Integration**:
- GameUI persists across scene transitions
- Theme system applies consistently
- Debug overlay (F3) shows current scene information

### **Future Integration Points**:
- **Save System**: Scene state persistence
- **NPC System**: Character placement and interactions
- **Inventory System**: Item placement and collection
- **Driving Mode**: Vehicle spawn points and driving triggers

## 📝 WORKFLOW CHECKLIST

### **Before Starting**:
- [ ] WorldDraft layout planning complete
- [ ] Biome theme decided for target scene
- [ ] Adjacent scenes identified for doorway connections

### **During Creation**:
- [ ] Appropriate template selected and duplicated
- [ ] Base terrain layer completed
- [ ] Major features and structures placed
- [ ] Decorative details added
- [ ] Collision layer painted and tested
- [ ] Doorways placed and configured

### **Before Completion**:
- [ ] Player movement tested throughout scene
- [ ] All doorway transitions verified
- [ ] Performance tested (60fps maintained)
- [ ] Visual consistency with adjacent scenes checked
- [ ] Scene file saved with proper naming convention

## 🚀 QUICK START COMMANDS

### **Template Duplication** (via Godot Editor):
1. Navigate to `scenes/levels/templates/`
2. Right-click appropriate template → Duplicate
3. Rename to target zone name (e.g., "SouthEast.tscn")
4. Move to `scenes/levels/outdoor/` directory
5. Open and begin asset population

### **Rapid Scene Setup**:
```gdscript
# Use this pattern for quick doorway setup:
# Copy from existing scenes and modify coordinates
```

This workflow enables rapid, consistent scene creation while maintaining integration with Turbo Breaks' established systems. 