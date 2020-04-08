part of examples;

class GeometryExample extends BaseGame {
  ShaderProgram shaderProgram;

  Camera2D camera;

  SpriteBatch renderer;
  Texture rock;

  double rot = pi / 4;

  @override
  void create() {
    camera = Camera2D.originBottomLeft(width, height);
    renderer = SpriteBatch.defaultShader(gl);

    gl.setGLViewport(canvasWidth, canvasHeight);

    rock = assetManager.get('rock.png');
  }

  @override
  void preload() {
    assetManager.load('rock.png', loadTexture(gl, 'geometry/rock.png'));
  }

  @override
  void render(double delta) {
    gl.clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();

    renderer.projection = camera.combined;
    renderer.begin();

    renderer.color = Colors.indianRed;
    renderer.draw(rock, 0.0, 0.0, width: 100.0, height: 100.0);

    renderer.color = Colors.forestGreen;
    renderer.draw(rock, 25.0, 25.0,
        width: 100.0, height: 100.0, flipX: true, flipY: true);

    renderer.color = Colors.saddleBrown;
    renderer.draw(rock, width - 50.0, 0.0, width: 50.0, height: height);

    renderer.color = Colors.lightSkyBlue;
    renderer.draw(rock, 0.0, height - 100.0,
        width: 100.0, height: 100.0, flipY: true);

    renderer.color = Colors.lightGoldenrodYellow;
    renderer.draw(rock, width / 2 - 50, height / 2 - 50,
        width: 100.0,
        height: 100.0,
        flipX: true,
        angle: rot,
        counterTurn: true);

    renderer.end();
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  void update(double delta) {
    rot += 0.5 * delta;
  }

  @override
  void config() {
    scaleMode = ScaleMode.fit;
  }

}
