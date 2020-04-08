part of cobblestone;

/// Loads a TSX tileset from a url.
///
/// [atlas] should be a [Texture] or a texture atlas.
/// [extraSpacing] and [extraMargin] should be set when using the Phaser Tile Extruder (https://github.com/sporadic-labs/tile-extruder) after creating a map.
Future<Tileset> loadTileset(String url, FutureOr<dynamic> atlas,
    [int extraSpacing = 0, int extraMargin = 0]) async {
  String file = await HttpRequest.getString(url);
  xml.XmlDocument doc = xml.parse(file);
  return Tileset.fromFile(doc, await atlas);
}

/// A set of tiles used in rendering a map.
class Tileset {
  /// Set of all static tiles, i.e. not animated.
  Map<int, BasicTile> basicTiles;

  /// Set of all tiles used in the map.
  Map<int, Tile> tiles;

  /// The ID of the first tile in this set.
  int firstGID = 1; // Will vary once multiple tilesets are supported.

  /// The number of tiles in this set.
  int tilecount;

  /// The width of tiles in this set, in pixels.
  int tileWidth;
  /// The height of tiles in this set, in pixels.
  int tileHeight;

  /// Offset to the first tile, in pixels.
  int tileMargin;
  /// Spacing between tiles, in pixels.
  int tileSpacing;

  /// Custom user properties on this tileset.
  MapProperties properties;

  /// Creates a new tileset from XML data and textures.
  ///
  /// [atlas] should be a texture for sets made in the "Tileset Image" mode.
  /// [atlas] should be a texture atlas for sets made in the "Collection of Images" mode.
  ///
  /// [extraSpacing] and [extraMargin] should be set when using the Phaser Tile Extruder (https://github.com/sporadic-labs/tile-extruder) after creating a map.
  Tileset.fromElement(xml.XmlElement element, var atlas,
      [int extraSpacing = 0, int extraMargin = 0]) {
    tilecount = _parseAttrib(element, 'tilecount', int.parse);

    tileWidth = _parseAttrib(element, 'tilewidth', int.parse);
    tileHeight = _parseAttrib(element, 'tileheight', int.parse);

    tileMargin = _parseAttrib(element, 'margin', int.parse, 0);
    tileSpacing = _parseAttrib(element, 'spacing', int.parse, 0);
    tileMargin += extraMargin;
    tileSpacing += extraSpacing;

    basicTiles = {};
    tiles = {};

    // Split texture for tileset mode
    if (atlas is Texture) {
      List<Texture> textures =
        atlas.split(tileWidth, tileHeight, tileSpacing, tileMargin);
      for (int i = 0; i < textures.length; i++) {
        basicTiles[i + firstGID] = BasicTile(i, textures[i]);
      }
    } else if (atlas is Map<String, Texture>) {
      element.findElements('tile').forEach((tile) {
        int id = int.parse(tile.getAttribute('id'));
        String source = path.basenameWithoutExtension(
            tile.findElements('image').first.getAttribute('source'));
        basicTiles[id + firstGID] = BasicTile(id, atlas[source], tile);
      });
    } else {
      throw ArgumentError('Atlas must be a Texture or a Texture Atlas');
    }

    tiles.addAll(basicTiles);

    element.findElements('tile').forEach((tile) {
      int id = int.parse(tile.getAttribute('id')) + firstGID;
      if (tile.findElements('animation').isNotEmpty) {
        tiles[id] = AnimatedTile(id, tile, firstGID, basicTiles);
      } else {
        tiles[id] = BasicTile(id, basicTiles[id].texture, tile);
      }
    });

    properties = MapProperties.fromChild(element);
  }

  /// Creates a new tileset from XML data and textures.
  ///
  /// [atlas] should be a texture for sets made in the "Tileset Image" mode.
  /// [atlas] should be a texture atlas for sets made in the "Collection of Images" mode.
  ///
  /// [extraSpacing] and [extraMargin] should be set when using the Phaser Tile Extruder (https://github.com/sporadic-labs/tile-extruder) after creating a map.
  Tileset.fromFile(xml.XmlDocument file, var atlas,
      [int extraSpacing = 0, int extraMargin = 0])
      : this.fromElement(file.rootElement, atlas, extraSpacing, extraMargin);

  /// Returns the tile with the given GID if it is in this set.
  Tile getTile(int gid) {
    return tiles[gid];
  }

  /// Updates the tileset, for animations.
  void update(double delta) {
    for(Tile tile in tiles.values) {
      tile.update(delta);
    }
  }
}
