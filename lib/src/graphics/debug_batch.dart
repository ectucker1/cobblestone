part of cobblestone;

/// A batch of bounding boxes, drawn in wireframe.
class DebugBatch extends VertexBatch {
  @override
  int maxSprites = 2000;

  @override
  final int drawMode = WebGL.LINES;

  @override
  final int vertexSize = 4;
  @override
  final int verticesPerSprite = 2;
  @override
  final int indicesPerSprite = 2;

  /// The number of segments to render when drawing ellipses.
  int ellipseResolution = 20;

  final Vector3 _point = Vector3.zero();
  final Vector3 _point2 = Vector3.zero();

  Vector4 _color = Colors.white;
  double _packedColor = packColor(Colors.white);

  /// Creates a new debug batch with a custom shader.
  DebugBatch(GLWrapper wrapper, ShaderProgram shaderProgram, {this.maxSprites = 2000})
      : super(wrapper, shaderProgram);

  /// Creates a new debug batch with a basic internal shader.
  DebugBatch.defaultShader(GLWrapper wrapper, {int maxSprites = 2000})
      : this(wrapper, wrapper.wireShader, maxSprites: maxSprites);

  /// The color the next objects in the batch will be drawn with.
  Vector4 get color => _color;
  set color(Vector4 color) {
    _color = color;
    _packedColor = packColor(color);
  }

  @override
  void setAttribPointers() {
    _context.vertexAttribPointer(shaderProgram.attributes[vertPosAttrib], 3,
        WebGL.FLOAT, false, vertexSize * 4, 0);
    _context.vertexAttribPointer(shaderProgram.attributes[colorAttrib], 4,
        WebGL.UNSIGNED_BYTE, true, vertexSize * 4, 3 * 4);
  }

  @override
  void createIndices() {
    for (int i = 0; i < indices.length; i++) {
      indices[i] = i;
    }

    _context.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    _context.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, indices, WebGL.STATIC_DRAW);
  }

  /// Draws a line from [start] to [end].
  void drawLine(Vector2 start, Vector2 end) {
    if(spritesInFlush >= maxSprites) {
      flush();
    }

    appendAttrib(start.x);
    appendAttrib(start.y);
    appendAttrib(0);
    appendAttrib(_packedColor);

    appendAttrib(end.x);
    appendAttrib(end.y);
    appendAttrib(0);
    appendAttrib(_packedColor);

    spritesInFlush++;
  }

  /// Draws an [Aabb2] or [Obb3], flattened on the z-axis.
  void drawBox(dynamic box) {
    if (box is Aabb2) {
      drawLine(box.max, Vector2(box.min.x, box.max.y));
      drawLine(Vector2(box.min.x, box.max.y), box.min);
      drawLine(box.min, Vector2(box.max.x, box.min.y));
      drawLine(Vector2(box.max.x, box.min.y), box.max);
    } else if (box is Obb3) {
      box.copyCorner(0, _point);
      box.copyCorner(2, _point2);
      drawLine(_point.xy, _point2.xy);
      box.copyCorner(6, _point);
      drawLine(_point2.xy, _point.xy);
      box.copyCorner(4, _point2);
      drawLine(_point.xy, _point2.xy);
      box.copyCorner(0, _point);
      drawLine(_point2.xy, _point.xy);
    }
  }

  /// Draws a representation of the given [MapObject].
  void drawMap(MapObject object) {
    if(object is MapRect) {
      drawLine(object.pos, object.pos + Vector2(object.width, 0));
      drawLine(object.pos + Vector2(object.width, 0),
          object.pos + Vector2(object.width, object.height));
      drawLine(object.pos + Vector2(object.width, object.height),
        object.pos + Vector2(0, object.height));
      drawLine(object.pos + Vector2(0, object.height), object.pos);
    } else if(object is MapPolygon) {
      for(int i = 0; i < object.points.length; i++) {
        if(i < object.points.length - 1) {
          drawLine(object.pos + object.points[i], object.pos + object.points[i + 1]);
        } else {
          drawLine(object.pos + object.points[i], object.pos + object.points[0]);
        }
      }
    } else if(object is MapEllipse) {
      Vector2 halfSize = Vector2(object.width / 2, object.height / 2);

      double theta = 0;
      Vector2 lastPoint = object.pos + halfSize + Vector2(halfSize.x * cos(theta), halfSize.y * sin(theta));
      for(double seg = 0; seg < ellipseResolution; seg++) {
        theta += (2 * pi) / ellipseResolution;
        Vector2 nextPoint = object.pos + halfSize + Vector2(halfSize.x * cos(theta), halfSize.y * sin(theta));
        drawLine(lastPoint, nextPoint);
        lastPoint = nextPoint;
      }
    } else if(object is MapPoint || object is MapText) {
      // 20 seems to be Tiled's magic number; why not use it here?
      drawLine(object.pos, object.pos + Vector2(-20, 40));
      drawLine(object.pos, object.pos + Vector2(20, 40));
    }
  }
}
