part of cobblestone;

/// Loads a TMX tilemap from a URL.
///
/// [tileset] should be set when using an external tileset; [atlas] when using an internal one.
/// [atlas] should be a [Texture] or a texture atlas.
///
/// [extraSpacing] and [extraMargin] should be set when using the Phaser Tile Extruder (https://github.com/sporadic-labs/tile-extruder) after creating a map.
Future<Tilemap> loadTilemap(String url,
    {FutureOr<Tileset> tileset, FutureOr<dynamic> atlas,
    int extraSpacing = 0, int extraMargin = 0}) async {
  String file = await HttpRequest.getString(url);
  xml.XmlDocument doc = xml.parse(file);
  return Tilemap(doc, tileset: await tileset, atlas: await atlas,
      extraSpacing: extraSpacing, extraMargin: extraMargin);
}

/// A 2D orthographic tilemap.
class Tilemap {
  /// Raw XML data describing this tilemap.
  xml.XmlDocument file;

  /// List of tile map layers in the map.
  List<TileLayer> layers = [];

  /// List of object groups in the map.
  List<ObjectGroup> objectGroups = [];

  /// The width of the tilemap, in tiles.
  int width;

  /// The height of the tilemap, in tiles.
  int height;

  /// The width of tiles in this map, in pixels.
  int tileWidth;

  /// The height of tiles in this map, in pixels.
  int tileHeight;

  /// The set of tiles used to render this map.
  ///
  /// Must be set before drawing.
  Tileset tileset;

  /// A set of custom properties on this Tilemap.
  MapProperties properties;

  /// Creates a new tilemap from a TMX map and an optional external tileset.
  ///
  /// [tileset] should be set when using an external tileset; [atlas] when using an internal one.
  /// [atlas] should be a [Texture] or a texture atlas.
  ///
  /// [extraSpacing] and [extraMargin] should be set when using the Phaser Tile Extruder (https://github.com/sporadic-labs/tile-extruder) after creating a map.
  Tilemap(this.file, {this.tileset, dynamic atlas,
    int extraSpacing = 0, int extraMargin = 0}) {
    if (tileset == null && atlas == null) {
      throw ArgumentError('Either a tileset or an atlas must be provided');
    }

    width = int.parse(file.rootElement.getAttribute('width'));
    height = int.parse(file.rootElement.getAttribute('height'));

    tileWidth = int.parse(file.rootElement.getAttribute('tilewidth'));
    tileHeight = int.parse(file.rootElement.getAttribute('tileheight'));

    tileset ??= Tileset.fromElement(
        file.rootElement.findElements('tileset').first, atlas,
        extraSpacing, extraMargin);

    for (xml.XmlElement layer in file.rootElement.findElements('layer')) {
      layers.add(TileLayer(this, layer));
    }
    for (xml.XmlElement group in file.rootElement.findElements('objectgroup')) {
      objectGroups.add(ObjectGroup(this, group));
    }

    properties = MapProperties.fromChild(file.rootElement);
  }

  /// Updates the tilemap, for animations.
  void update(double delta) {
    tileset.update(delta);
  }

  /// Renders the tilemap layers. If [filter] is set, only renders the layers with names selected by the it.
  void render(SpriteBatch batch, num x, num y, Camera2D camera, {Pattern filter}) {
    if (filter == null) {
      for (TileLayer layer in layers) {
        layer.render(batch, x, y, camera);
      }
    } else {
      for (TileLayer layer in getLayersContaining(filter)) {
        layer.render(batch, x, y, camera);
      }
    }
  }

  /// Returns a list of map layers with names satisfying [filter].
  List<TileLayer> getLayersContaining(Pattern filter) {
    return layers.where((TileLayer layer) => layer.name.contains(filter));
  }
}

/// A tilemap layer filed with tiles.
class TileLayer {
  /// The map this layer is a part of.
  Tilemap parent;

  /// The name of this layer.
  String name;

  // Actual map data
  List<Tile> _tiles;
  List<int> _tileIds;

  /// The width of tiles in this layer, in pixels.
  int tileWidth;

  /// The height of tiles in this layer, in pixels.
  int tileHeight;

  /// The width of this layer, in tiles.
  int width;

  /// The height of this layer, in pixels.
  int height;

  /// A set of custom properties for this map layer.
  MapProperties properties;

  /// Creates a new tile layer from TMX data.
  TileLayer(this.parent, xml.XmlElement layer) {
    width = int.parse(layer.getAttribute('width'));
    height = int.parse(layer.getAttribute('height'));

    name = layer.getAttribute('name');

    xml.XmlElement data = layer.findElements('data').first;
    if (data.getAttribute('encoding') == 'csv') {
      _tileIds = _parseCsv(data.text, int.parse);
    } else if (data.getAttribute('encoding') == 'base64') {
      _tileIds = base64.decode(data.text);
    }

    _tiles = [];
    _tileIds.forEach((int id) => _tiles.add(parent.tileset.getTile(id)));

    tileWidth = parent.tileWidth;
    tileHeight = parent.tileHeight;

    properties = MapProperties.fromChild(layer);
  }

  /// Renders this tile layer to given [batch].
  void render(SpriteBatch batch, num x, num y, Camera2D camera) {
    double startX = min(min(camera.view.point0.x, camera.view.point1.x),
            min(camera.view.point2.x, camera.view.point3.x)) - x;
    double startY = min(min(camera.view.point0.y, camera.view.point1.y),
            min(camera.view.point2.y, camera.view.point3.y)) - y;

    double endX = max(max(camera.view.point0.x, camera.view.point1.x),
            max(camera.view.point2.x, camera.view.point3.x)) - x;
    double endY = max(max(camera.view.point0.y, camera.view.point1.y),
            max(camera.view.point2.y, camera.view.point3.y)) - y;

    for (int row = max(startY ~/ tileHeight, 0);
        row < min(endY ~/ tileHeight + 1, height);
        row++) {
      for (int col = max(startX ~/ tileWidth, 0);
          col < min(endX ~/ tileWidth + 1, width);
          col++) {
        if (getTile(col, row) != null) {
          getTile(col, row).render(batch, col * tileWidth + x,
              row * tileHeight + y, tileWidth, tileHeight);
        }
      }
    }
  }

  /// Returns the tile at ([x], [y]) from the bottom-left.
  Tile getTile(x, y) {
    return _tiles[width * (height - y - 1) + x];
  }
}

/// A group of objects in the map.
class ObjectGroup {
  /// The map this ObjectGroup is a part of.
  Tilemap map;

  /// The name of this object group.
  String name;

  /// A list of objects in this group.
  List<MapObject> objects = [];

  /// A set of custom properties for this object group.
  MapProperties properties;

  /// Creates a new object group from TMX data.
  ObjectGroup(this.map, xml.XmlElement group) {
    name = group.getAttribute('name');

    for (xml.XmlElement object in group.findElements('object')) {
      objects.add(MapObject.load(this, object));
    }

    properties = MapProperties.fromChild(group);
  }
}
