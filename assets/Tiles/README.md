# Tileset Workflow Guide

This directory contains everything you need for tileset creation and tilemap design in Godot.

## Folder Structure

```
/Assets/Tiles/
├── Drafts/           # Experimental tilesets, quick tests, iteration work
├── Final/            # Production-ready tilesets
└── Tilemaps/         # Scene files for testing and production maps
    ├── TilemapDraft.tscn    # Quick testing scene
    ├── OverworldMap.tscn    # Production map template
    └── draft_camera.gd      # Camera controller for navigation
```

## Workflow

### 1. Draft Phase (`/Drafts/`)
- Create experimental tilesets here
- Test different tile sizes, styles, and arrangements
- Rapid iteration without worrying about organization
- Use `TilemapDraft.tscn` to test your drafts immediately

### 2. Production Phase (`/Final/`)
- Move polished tilesets here
- Properly named and organized
- Ready for use in actual game scenes
- Should have proper collision, physics layers, etc.

### 3. Testing Your Tilesets

#### Using TilemapDraft.tscn:
1. Open `assets/Tiles/Tilemaps/TilemapDraft.tscn`
2. Select the TileMap node
3. In the Inspector, click on the TileSet dropdown
4. Choose "New TileSet" or load an existing one
5. If creating new: Click on the TileSet to open the editor
6. Add your tile texture and configure tiles
7. Use WASD to move camera, mouse wheel to zoom
8. Test painting tiles to verify everything works

#### Camera Controls in Draft Scene:
- **WASD**: Move camera around the map
- **Mouse Wheel**: Zoom in/out
- **Click**: Place tiles (when tileset is loaded)

## Best Practices

### Tileset Organization:
- Use consistent naming: `grass_tileset.tres`, `dungeon_walls.tres`
- Keep source images in same folder as .tres files
- Document tile ID meanings for complex tilesets

### Performance Tips:
- Use autotile/terrain features for efficiency
- Minimize unique tiles where possible
- Consider atlas textures for related tiles
- Test performance with large maps early

### Production Maps:
- Use `OverworldMap.tscn` as template for multi-layer maps
- Separate collision, background, foreground layers
- Include spawn points and boundaries
- Test with actual game systems early

## Quick Start Checklist

1. ✅ Create or import your first tileset image to `/Drafts/`
2. ✅ Open `TilemapDraft.tscn`
3. ✅ Create a new TileSet resource
4. ✅ Add your image and configure tiles
5. ✅ Test painting and navigation
6. ✅ Move to `/Final/` when satisfied
7. ✅ Create production maps using organized layers 