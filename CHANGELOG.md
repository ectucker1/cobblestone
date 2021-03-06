
# Changelog  

## 0.3.4

- Update dependencies to latest version
- Now requires ```sdk >= 2.6.0```

## 0.3.3

- Added `enableHDPI` variable in `BaseGame` to configure High DPI support
- Added `pixelRatio` property to help with accounting for DPI in rendering
- Added `isInt` parameter to `setUniform` to allow integers and doubles to be distinguished in setting uniforms

## 0.3.2

- Internal renaming of imported libraries
  
## 0.3.1 Minor Typing
  
- Replaced  ```num``` with ```int``` or ```double``` where those types were clearly expected
- Most notably, texture and viewport widths are required to be ```int```
  
## 0.3.0 The Great Tilemap Update  
  
### Tilemaps  
  
- Added support for loading objects in maps  
- Added support for loading custom properties on objects, maps, layers, tiles, etc.  
- Added support for external tilesets  
- Added support for padding and margins in tilesets  
- Added support for extruded tilesets made using the [Phaser Tile Extruder](https://github.com/sporadic-labs/tile-extruder) to fix bleeding  
- Now requires tileset or atlas to be passed to loadTilemap  
  
### Graphics  
  
### Texture  
- Changed the split method to support padding and margins  
  
#### Texture Atlases  
- Switched atlas format to the one used by the [LibGDX TexturePacker](https://github.com/libgdx/libgdx/wiki/Texture-packer)  
  
#### DebugBatch  
- Renamed from PhysboxBatch  
- Added support for drawing different kinds of MapObjects  
- Added support for different colors per object  
  
### Other  
  
#### AssetManager  
- Added getLoading and hasLoaded to better support asset dependencies
