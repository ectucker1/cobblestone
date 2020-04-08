part of cobblestone;

/// A tile on the map.
abstract class Tile {
  /// The ID number of this tile.
  int id;

  /// The texture used for rendering this tile.
  Texture texture;

  /// Custom user data describing this tile.
  MapProperties properties;

  Tile._(this.id, this.texture);

  /// Renders the tile using [batch].
  void render(SpriteBatch batch, num x, num y, num width, num height);

  /// Updates this tile.
  void update(double delta) {}
}

/// A static tile, with a single image.
class BasicTile extends Tile {

  /// Creates a new basic tile with the given [id], [texture] and optionally TMX data.
  BasicTile(int id, Texture texture, [xml.XmlElement data]): super._(id, texture) {
    if (data != null) {
      properties = MapProperties.fromChild(data);
    } else {
      properties = MapProperties.empty();
    }
  }

  @override
  void render(SpriteBatch batch, num x, num y, num width, num height) {
    batch.draw(texture, x, y, width: width, height: height);
  }
}

/// A tile that plays an animation in a loop.
class AnimatedTile extends Tile {

  /// A list of texture frames for this tile's animation.
  List<Texture> frames = [];

  /// A list of timings in seconds corresponding to textures in [frames].
  List<double> timings = [];

  /// The time into the current animation loop, in seconds.
  double currentTime = 0.0;

  /// Creates a new animated tile, with frames from the given set of basic tiles.
  AnimatedTile(int id, xml.XmlElement data, int firstGID,
      Map<int, BasicTile> basicTiles): super._(id, null) {
    for (var frame
        in data.findElements('animation').first.findElements('frame')) {
      frames.add(basicTiles[int.parse(frame.getAttribute('tileid')) + firstGID]
          .texture);
      timings.add(double.parse(frame.getAttribute('duration')) / 1000);
    }

    properties = MapProperties.fromChild(data);

    update(0);
  }

  @override
  void update(double delta) {
    currentTime += delta;

    // Find the last frame hit.
    double timeSum = 0;
    for (int i = 0; i < timings.length; i++) {
      if (currentTime >= timeSum) {
        texture = frames[i];
      }
      timeSum += timings[i];
    }

    // Reset the loop if past.
    if (currentTime >= timeSum) {
      currentTime = 0.0;
      texture = frames[0];
    }
  }

  @override
  void render(SpriteBatch batch, num x, num y, num width, num height) {
    batch.draw(texture, x, y, width: width, height: height);
  }
}
