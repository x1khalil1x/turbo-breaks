# WorldDraft System

## Overview
The WorldDraft scene provides a visual prototyping environment for designing the complete 3×3 overworld map layout. This tool helps with world cohesion, biome transitions, and overall layout planning before implementing individual regional scenes.

## Canvas Specifications
- **Total Canvas**: 3840×2160 pixels
- **Region Size**: 1280×720 pixels each
- **Grid Layout**: 3×3 = 9 regions total
- **Tile Size**: 32×32 pixels (matching project standard)

## Region Layout
```
┌─────────────┬─────────────┬─────────────┐
│  NORTHWEST  │    NORTH    │  NORTHEAST  │
│Mountain/For │  Tundra/Ice │Volcanic/Des │
│             │             │             │
├─────────────┼─────────────┼─────────────┤
│    WEST     │   CENTER    │    EAST     │
│Coastal/Beac │  Hub/City   │Plains/Grass │
│             │             │             │
├─────────────┼─────────────┼─────────────┤
│  SOUTHWEST  │    SOUTH    │  SOUTHEAST  │
│Swamp/Wetlan │Industrial/U │Badlands/Rui │
│             │             │             │
└─────────────┴─────────────┴─────────────┘
```

## Features

### TileMap Layers
1. **BaseLayer** - Terrain foundations and ground tiles
2. **DecorationLayer** - Objects, buildings, vegetation  
3. **CollisionLayer** - Invisible collision planning (semi-transparent)

### Camera Navigation
- **Drag to Pan** - Left-click and drag to move around
- **Scroll Zoom** - Mouse wheel for zooming in/out
- **Zoom Range** - 0.1x to 2.0x
- **Default View** - 0.3x zoom, centered on entire world

### UI Controls
- **Show/Hide Grid** - Toggle 3×3 region dividers
- **Show/Hide Regions** - Toggle biome name labels
- **Show/Hide Collision** - Toggle collision layer visibility
- **Zoom Controls** - Button-based zoom in/out
- **Center View** - Return to default camera position
- **Reset Zoom** - Return to default zoom level

### External Art Integration
- **Procreate Slot** - Import draft artwork as reference overlay
- **Half Transparency** - Overlay doesn't interfere with tile work
- **Centered Positioning** - Automatically positioned at world center

## Usage Workflow

### 1. Layout Planning
1. Open WorldDraft.tscn
2. Use region markers to plan biome placement
3. Toggle grid to see exact boundaries
4. Sketch rough layouts with tiles

### 2. External Art Reference
```gdscript
# Load reference artwork (script usage)
world_draft.load_procreate_draft("res://assets/drafts/world_concept.png")
```

### 3. Tile Prototyping
- Use BaseLayer for terrain types
- Use DecorationLayer for landmarks
- Plan collision areas with CollisionLayer

### 4. Transition Planning
- Focus on region borders for seamless transitions
- Test tile blending between biomes
- Plan inter-region pathways and connections

## Integration with Game Systems

### Fast Travel
- Region coordinates map directly to fast travel destinations
- `get_region_center()` provides exact teleport coordinates

### Minimap
- WorldDraft layout becomes the minimap reference
- Region markers translate to minimap labels

### Story Connections
- Visual layout helps plan quest routes
- Clear sight lines for story progression between regions

## Technical Notes

### Performance
- Heavy scene intended for editor use only
- Not optimized for runtime/export
- Full 3840×2160 canvas may be resource intensive

### File Management
- Save frequent snapshots of different layout iterations
- Export region layouts as separate images for reference
- Keep collision planning separate from visual design

### Coordinate System
- Origin (0,0) at top-left corner
- Region coordinates: (0-2, 0-2)
- World coordinates: (0-3840, 0-2160)

## Best Practices

1. **Start with rough shapes** - Block out major terrain types first
2. **Focus on transitions** - Spend time on region borders
3. **Use layers effectively** - Separate base terrain from decoration
4. **Reference real maps** - Study how real biomes transition
5. **Plan for scale** - Remember each region will be detailed later
6. **Save iterations** - Keep different versions as you iterate

## Future Enhancements
- Export individual region layouts as .png files
- Integration with actual TileSet resources for better previews
- Auto-generation of individual scene files from draft layouts
- Integration with story/quest planning tools 