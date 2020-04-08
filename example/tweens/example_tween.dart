part of examples;

class TweenExample extends BaseGame {
  ShaderProgram shaderProgram;

  Camera2D camera;

  SpriteBatch renderer;
  Texture rock;

  Box box;

  @override
  void create() {
    camera = Camera2D.originBottomLeft(width, height);
    renderer = SpriteBatch.defaultShader(gl);

    gl.setGLViewport(canvasWidth, canvasHeight);

    rock = assetManager.get('rock.png');

    box = Box(0.0, 0.0);

    var getPos = [() => box.x, () => box.y];
    var setPos = [(v) => box.x = v, (v) => box.y = v];

    Tween()
      ..get = getPos
      ..set = setPos
      ..target = [width - 50, height - 50]
      ..duration = 10.0
      ..delay = 1.0
      ..ease = Ease.backInOut
      ..callback = (() => print('Tween 1 Complete'))
      ..chain(Tween()
        ..get = getPos
        ..set = setPos
        ..target = [0.0, 0.0]
        ..duration = 10.0
        ..ease = Ease.expoInOut)
      ..start(tweenManager);
  }

  @override
  void preload() {
    assetManager.load('rock.png', loadTexture(gl, 'tweens/rock.png', nearest));
  }

  @override
  void render(double delta) {
    gl.clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();

    renderer.projection = camera.combined;
    renderer.begin();

    renderer.draw(rock, box.x, box.y, width: 50, height: 50);

    renderer.end();
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  void update(double delta) {}

  @override
  void config() {
    scaleMode = ScaleMode.fit;
  }
}

class Box {
  double x, y;

  Box(this.x, this.y);
}
