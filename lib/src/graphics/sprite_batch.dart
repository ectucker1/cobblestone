part of cobblestone;

/// A batch of textured sprites.
class SpriteBatch extends VertexBatch {
  @override
  int maxSprites = 2000;

  @override
  final int drawMode = WebGL.TRIANGLES;

  @override
  final int vertexSize = 6;
  @override
  final int verticesPerSprite = 4;
  @override
  final int indicesPerSprite = 6;

  Vector4 _color = Colors.white;
  double _packedColor = packColor(Colors.white);

  int _vi = 0;

  /// The texture currently being used by the batch.
  ///
  /// Changing the texture will force a call to flush, and thus texture changes should be minimized.
  Texture texture;

  /// Creates a new sprite batch with a custom shader
  SpriteBatch(GLWrapper wrapper, shaderProgram, {this.maxSprites = 2000})
      : super(wrapper, shaderProgram) {
    color = Vector4.all(1.0);
  }

  /// Creates a new sprite batch with a simple shader
  SpriteBatch.defaultShader(GLWrapper wrapper, {int maxSprites = 2000})
      : this(wrapper, wrapper.batchShader, maxSprites: maxSprites);

  /// The color the next sprites in the batch will be drawn with.
  ///
  /// The default shader multiplies texture colors by this color.
  Vector4 get color => _color;
  set color(Vector4 color) {
    _color = color;
    _packedColor = packColor(color);
  }

  /// Draws the [texture] at ([x], [y]), the bottom left of the sprite. Can optionally draw at a given [height] and [width], scale by [scaleX] and [scaleY],
  /// flip the texture if [flipX] or [flipY], or turn [angle] around the center.
  void draw(Texture texture, num x, num y,
      {num width, num height,
      num scaleX = 1, num scaleY = 1,
      bool flipX = false, bool flipY = false,
      num angle = 0, bool counterTurn = false}) {
    x = x.toDouble();
    y = y.toDouble();

    if (spritesInFlush >= maxSprites) {
      print('Cobblestone: Warning: Batch full, forcing flush');
      flush();
    }
    if (this.texture != null) {
      if (texture.texture != this.texture.texture) {
        flush();
      }
    }

    this.texture = texture;

    width ??= texture.width;
    height ??= texture.height;

    width *= scaleX;
    height *= scaleY;

    double x1 = x;
    double y1 = y;

    double x2 = x;
    double y2 = y + height;

    double x3 = x + width;
    double y3 = y;

    double x4 = x + width;
    double y4 = y + height;

    if (angle != 0) {
      if (counterTurn) {
        angle = 2 * pi - angle;
      }

      double cx = x + width / 2;
      double cy = y + height / 2;

      double sinAng = sin(angle);
      double cosAng = cos(angle);

      double tempX = x1 - cx;
      double tempY = y1 - cy;

      double rotatedX = tempX * cosAng - tempY * sinAng;
      double rotatedY = tempX * sinAng + tempY * cosAng;

      x1 = rotatedX + cx;
      y1 = rotatedY + cy;

      tempX = x2 - cx;
      tempY = y2 - cy;

      rotatedX = tempX * cosAng - tempY * sinAng;
      rotatedY = tempX * sinAng + tempY * cosAng;

      x2 = rotatedX + cx;
      y2 = rotatedY + cy;

      tempX = x3 - cx;
      tempY = y3 - cy;

      rotatedX = tempX * cosAng - tempY * sinAng;
      rotatedY = tempX * sinAng + tempY * cosAng;

      x3 = rotatedX + cx;
      y3 = rotatedY + cy;

      tempX = x4 - cx;
      tempY = y4 - cy;

      rotatedX = tempX * cosAng - tempY * sinAng;
      rotatedY = tempX * sinAng + tempY * cosAng;

      x4 = rotatedX + cx;
      y4 = rotatedY + cy;
    }

    double u = texture.u.toDouble();
    double u2 = texture.u2.toDouble();

    double v = texture.v.toDouble();
    double v2 = texture.v2.toDouble();

    if (flipX) {
      double temp = u;
      u = u2;
      u2 = temp;
    }
    if (flipY) {
      double temp = v;
      v = v2;
      v2 = temp;
    }

    _vi = spritesInFlush * verticesPerSprite * vertexSize;

    vertices[_vi + 00] = x1;
    vertices[_vi + 01] = y1;
    vertices[_vi + 02] = 0.0;
    vertices[_vi + 03] = _packedColor;
    vertices[_vi + 04] = u;
    vertices[_vi + 05] = v;

    vertices[_vi + 06] = x2;
    vertices[_vi + 07] = y2;
    vertices[_vi + 08] = 0.0;
    vertices[_vi + 09] = _packedColor;
    vertices[_vi + 10] = u;
    vertices[_vi + 11] = v2;

    vertices[_vi + 12] = x3;
    vertices[_vi + 13] = y3;
    vertices[_vi + 14] = 0.0;
    vertices[_vi + 15] = _packedColor;
    vertices[_vi + 16] = u2;
    vertices[_vi + 17] = v;

    vertices[_vi + 18] = x4;
    vertices[_vi + 19] = y4;
    vertices[_vi + 20] = 0.0;
    vertices[_vi + 21] = _packedColor;
    vertices[_vi + 22] = u2;
    vertices[_vi + 23] = v2;

    spritesInFlush++;
  }

  @override
  void createIndices() {
    for (int i = 0, j = 0; i < indices.length; i += 6, j += 4) {
      indices[i] = j;
      indices[i + 1] = j + 1;
      indices[i + 2] = j + 2;
      indices[i + 3] = j + 2;
      indices[i + 4] = j + 3;
      indices[i + 5] = j + 1;
    }

    _context.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    _context.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, indices, WebGL.STATIC_DRAW);
  }

  @override
  void setAttribPointers() {
    _context.vertexAttribPointer(shaderProgram.attributes[vertPosAttrib],
        3, WebGL.FLOAT, false, vertexSize * 4, 0);
    _context.vertexAttribPointer(shaderProgram.attributes[colorAttrib],
        4, WebGL.UNSIGNED_BYTE, true, vertexSize * 4, 3 * 4);
    _context.vertexAttribPointer(shaderProgram.attributes[textureCoordAttrib],
        3, WebGL.FLOAT, false, vertexSize * 4, 4 * 4);

    _context.uniform1i(shaderProgram.uniforms[samplerUni], texture.bind(0));
  }
}
