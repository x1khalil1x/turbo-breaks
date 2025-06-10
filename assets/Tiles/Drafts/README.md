# Drafts Folder - Asset Import Guide

## 📥 Importing New Tileset Packs

### Tileset Formats
- **Sprite Sheets** (Preferred): Single PNG with multiple tiles (e.g., 512x512)
- **Individual Files**: Hundreds of separate PNG files
- **Mixed Packs**: Combination of both formats

### Import Workflow

#### Step 1: Place Raw Assets
1. Create subfolder: `raw_imports/[pack_name]/`
2. Place original PNG files here (preserve original names)
3. Note the tile size (usually 32x32 for this project)

#### Step 2: Godot Import
1. Drag PNG files into Godot FileSystem dock
2. Select PNG → Inspector → Import tab
3. Set **Filter: Off** (prevents blurring)
4. Click **Reimport**

#### Step 3: Create TileSet Resource
1. Create new scene with TileMap node
2. In TileMap → TileSet property → "New TileSet"
3. Open TileSet editor
4. Add your sprite sheet as source
5. Define tile regions (32x32 grid)

#### Step 4: Paint & Test
1. Select tiles from palette
2. Paint on TileMap layers
3. Test collision and visual appearance

### Organization
- Keep original files in `raw_imports/`
- Organized, tested tilesets move to `../Final/`
- Document tile IDs and collision settings

### Current Import Status
- [ ] Pack 1: 64x168 + 512x512 PNGs (Ready for import)
- [ ] Additional packs... 