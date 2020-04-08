part of cobblestone;

/// A function type used to convert an [ImageElement] into a WebGL texture
typedef TextureHandler = gl.Texture Function(GLWrapper, ImageElement);

/// Loads a texture from a url.
///
/// Provide [handle] (probably one of [nearest], [linear], or [mipMap]) to control texture filtering.
Future<Texture> loadTexture(GLWrapper wrapper, String url,
    [TextureHandler handle = nearest]) {
  var completer = Completer<Texture>();
  var element = ImageElement();
  element.onLoad.listen((e) {
    var texture = handle(wrapper, element);
    Texture gameTexture =
        Texture(wrapper, texture, url, element.width, element.height);
    completer.complete(gameTexture);
  });
  element.src = url;
  return completer.future;
}

/// Converts an [ImageElement] to a mip-mapped texture.
gl.Texture mipMap(GLWrapper wrapper, ImageElement image) {
  var context = wrapper.context;
  
  gl.Texture texture = context.createTexture();
  context.pixelStorei(WebGL.UNPACK_FLIP_Y_WEBGL, 1);
  context.bindTexture(WebGL.TEXTURE_2D, texture);
  context.texImage2D(
      WebGL.TEXTURE_2D, 0, WebGL.RGBA, WebGL.RGBA, WebGL.UNSIGNED_BYTE, image);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, WebGL.LINEAR);
  context.texParameteri(
      WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.LINEAR_MIPMAP_NEAREST);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
  context.generateMipmap(WebGL.TEXTURE_2D);
  context.bindTexture(WebGL.TEXTURE_2D, null);
  return texture;
}

/// Converts an [ImageElement] to texture with nearest neighbor scaling.
gl.Texture nearest(GLWrapper wrapper, ImageElement element) {
  var context = wrapper.context;

  gl.Texture texture = context.createTexture();
  context.bindTexture(WebGL.TEXTURE_2D, texture);
  context.pixelStorei(WebGL.UNPACK_FLIP_Y_WEBGL, 1);
  context.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, WebGL.RGBA,
      WebGL.UNSIGNED_BYTE, element);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, WebGL.NEAREST);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.NEAREST);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
  context.bindTexture(WebGL.TEXTURE_2D, null);
  return texture;
}

/// Converts an [ImageElement] to a texture with linear scaling.
gl.Texture linear(GLWrapper wrapper, ImageElement element) {
  var context = wrapper.context;

  gl.Texture texture = context.createTexture();
  context.bindTexture(WebGL.TEXTURE_2D, texture);
  context.pixelStorei(WebGL.UNPACK_FLIP_Y_WEBGL, 1);
  context.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, WebGL.RGBA,
      WebGL.UNSIGNED_BYTE, element);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, WebGL.LINEAR);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.LINEAR);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
  context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
  context.bindTexture(WebGL.TEXTURE_2D, null);
  return texture;
}

/// A region of a WebGL texture used for drawing images.
///
/// Should typically be created by calling [loadTexture].
/// See [SpriteBatch] for rendering usage.
class Texture {
  /// Reference to the game's [GLWrapper]
  GLWrapper wrapper;
  gl.RenderingContext _context;

  /// The actual
  gl.Texture texture;

  /// WebGL texture coordinate used for drawing this texture
  double u, v, u2, v2;

  /// A string representing the original source of this texture, probably a filename or URL
  String source;

  /// The width of the full texture image.
  int sourceWidth;
  /// The height of the full texture image.
  int sourceHeight;

  /// The width of this texture region.
  int width;
  /// The height of this texture region.
  int height;

  /// Creates a new texture from a [gl.Texture].
  /// [loadTexture] should typically be used in place of directly calling this constructor.
  Texture(this.wrapper, this.texture, this.source, this.sourceWidth, this.sourceHeight) {
    _context = wrapper.context;
    setRegion(0, 0, sourceWidth, sourceHeight);
  }

  /// Creates a clone of another texture. Both reference the same WebGL texture, but can have independent texture coordinates.
  Texture.clone(Texture other) {
    wrapper = other.wrapper;
    _context = other._context;

    texture = other.texture;

    source = other.source;
    sourceWidth = other.sourceWidth;
    sourceHeight = other.sourceHeight;

    width = other.width;
    height = other.height;

    u = other.u;
    v = other.v;
    u2 = other.u2;
    v2 = other.v2;
  }

  /// Creates an empty texture. Should later be filled with data using WebGL functions.
  Texture.empty(this.wrapper, this.width, this.height, var filter) {
    _context = wrapper.context;

    texture = _context.createTexture();
    _context.bindTexture(WebGL.TEXTURE_2D, texture);
    //context.pixelStorei(WebGL.UNPACK_FLIP_Y_WEBGL, 1);
    _context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, filter);
    _context.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, filter);
    _context.texParameteri(
        WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
    _context.texParameteri(
        WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
    _context.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, width, height, 0, WebGL.RGBA,
        WebGL.UNSIGNED_BYTE, null);
    _context.bindTexture(WebGL.TEXTURE_2D, null);

    source = 'None';

    sourceWidth = width;
    sourceHeight = height;

    u = 0;
    v = 0;
    u2 = 1;
    v2 = 1;
  }

  /// Sets the bounds of the texture, using y-up coordinates from the bottom left.
  void setRegion(int x, int y, int width, int height) {
    double invTexWidth = 1.0 / sourceWidth;
    double invTexHeight = 1.0 / sourceHeight;
    setRegionCoords(x * invTexWidth, y * invTexHeight,
        (x + width) * invTexWidth, (y + height) * invTexHeight);

    this.width = width;
    this.height = height;
  }

  /// Sets the uv coordinates of the texture manually.
  void setRegionCoords(double u, double v, double u2, double v2) {
    width = ((u2 - u).abs() * sourceWidth).round();
    height = ((v2 - v).abs() * sourceHeight).round();

    this.u = u;
    this.v = v;
    this.u2 = u2;
    this.v2 = v2;
  }

  /// Splits this texture into pieces of [tileWidth] by [tileHeight].
  List<Texture> split(int tileWidth, int tileHeight,
      [int spacing = 0, int margin = 0]) {
    int x = (u * sourceWidth).floor();
    int y = (v * sourceWidth + height - tileHeight).floor();

    int rows = ((height + 2 * margin) / (tileHeight + spacing)).floor();
    int cols = ((width + 2 * margin) / (tileWidth + spacing)).floor();

    int startX = x + margin;
    y = y - margin;
    List<Texture> tiles = [];
    for (int row = 0; row < rows; row++, y -= tileHeight + spacing) {
      x = startX;
      for (int col = 0; col < cols; col++, x += tileWidth + spacing) {
        Texture tile = Texture.clone(this);
        tile.setRegion(x, y, tileWidth, tileHeight);
        tiles.add(tile);
      }
    }

    return tiles;
  }

  /// Binds this texture to a given location, or else location 0
  int bind([int location = 0]) {
    _context.activeTexture(textureBind(location));
    _context.bindTexture(WebGL.TEXTURE_2D, texture);
    return location;
  }
}
