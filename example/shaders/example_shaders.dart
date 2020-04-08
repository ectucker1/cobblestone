part of examples;

class ShaderExample extends BaseGame {
  Camera2D camera;

  SpriteBatch renderer;

  Texture water;

  double angleWave = 0.0;

  @override
  void create() {
    camera = Camera2D.originBottomLeft(width, height);
    renderer = SpriteBatch(gl, assetManager.get('water'));
    renderer.setAdditionalUniforms = () {
      renderer.setUniform('waveData', Vector2(angleWave, 0.9));
      renderer.setUniform('uLightColor', Colors.navy);
    };

    gl.setGLViewport(canvasWidth, canvasHeight);

    water = assetManager.get('water.png');
  }

  @override
  void preload() {
    assetManager.load('water.png', loadTexture(gl, 'shaders/water.png'));
    assetManager.load('water', loadProgram(gl, 'shaders/water.vertex', 'shaders/ambient.fragment'));
  }

  @override
  void render(double delta) {
    gl.clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();

    renderer.projection = camera.combined;
    renderer.begin();
    for (int i = 0; i < width / 64; i++) {
      for (int j = 0; j < height / 64; j++) {
        renderer.draw(water, i * 64, j * 64, width: 64, height: 64);
      }
    }
    renderer.end();
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  void update(double delta) {
    angleWave += delta * 5.0;
    while (angleWave > pi * 2) {
      angleWave -= pi * 2;
    }
  }
}