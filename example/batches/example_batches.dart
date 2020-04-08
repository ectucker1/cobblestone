part of examples;

class BatchExample extends BaseGame {
  Camera2D camera;
  Matrix4 pMatrix;

  PointBatch pointBatch;
  DebugBatch debugBatch;

  @override
  void create() {
    camera = Camera2D.originBottomLeft(width, height);
    pointBatch = PointBatch.defaultShader(gl, maxSprites: 2);

    debugBatch = DebugBatch.defaultShader(gl, maxSprites: 8);

    gl.setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  void preload() {}

  @override
  void render(double delta) {
    gl.clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();

    pointBatch.projection = camera.combined;
    pointBatch.begin();

    pointBatch.draw(Vector3(10.0, 10.0, 0.0), Vector4(0.0, 1.0, 0.0, 1.0));
    pointBatch.draw(Vector3(10.0, 20.0, 0.0), Vector4(1.0, 1.0, 0.0, 1.0));

    pointBatch.end();

    debugBatch.projection = camera.combined;
    debugBatch.begin();

    Aabb2 box = Aabb2.centerAndHalfExtents(
        Vector2(10.0, 10.0), Vector2(10.0, 100.0));
    debugBatch.drawBox(box);

    Obb3 ob = Obb3();
    Matrix3 rotation = Matrix3.rotationZ(pi / 8);
    ob
      ..center.setFrom(Vector3(100.0, 100.0, 0.0))
      ..halfExtents.setFrom(Vector3(50.0, 75.0, 0.0))
      ..rotate(rotation);
    debugBatch.drawBox(ob);

    debugBatch.end();
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  void update(double delta) {}
}
