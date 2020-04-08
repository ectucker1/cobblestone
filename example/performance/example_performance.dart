part of examples;

const double gravity = -9.8;
Random rand = Random();

class PerformanceExample extends BaseGame {
  Camera2D camera;

  SpriteBatch renderer;

  List<BoulderSprite> boulders = [];

  @override
  void create() {
    camera = Camera2D.originBottomLeft(width, height);
    renderer = SpriteBatch.defaultShader(gl, maxSprites: 20000);

    gl.setGLViewport(canvasWidth, canvasHeight);

    Texture boulderSheet = assetManager.get('boulders2.png');

    List<Texture> textures = boulderSheet.split(16, 16);
    for (int i = 0; i < 100000; i++) {
      boulders.add(BoulderSprite(textures[rand.nextInt(textures.length)],
          rand.nextInt(width).toDouble(),
          rand.nextInt(height ~/ 2) + height / 2));
    }
  }

  @override
  void preload() {
    assetManager.load('boulders2.png', loadTexture(gl, 'performance/boulders2.png'));
  }

  @override
  void render(double delta) {
    gl.clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();
    renderer.projection = camera.combined;

    renderer.begin();
    for (BoulderSprite sprite in boulders) {
      sprite.update(delta);
      renderer.draw(sprite.texture, sprite.x, sprite.y);
    }
    renderer.end();
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  void update(double delta) {}
}

class BoulderSprite {
  Texture texture;

  double speedX, speedY;
  double x, y;

  BoulderSprite(this.texture, this.x, this.y) {
    speedX = (rand.nextDouble() * 100) - 50;
    speedY = (rand.nextDouble() * 100) - 50;
  }

  void update(double delta) {
    x += speedX * delta;
    y += speedY * delta;
    speedY += gravity * delta;

    if (x > 640) {
      speedX *= -1;
      x = 640;
    } else if (x < 0) {
      speedX *= -1;
      x = 0;
    }

    if (y < 0) {
      speedY *= -0.85;
      y = 0;
    } else if (y > 480) {
      speedY = 0;
      y = 480;
    }
  }

}
