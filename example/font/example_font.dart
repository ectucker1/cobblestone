part of examples;

class FontExample extends BaseGame {
  SpriteBatch renderer;
  Camera2D camera;

  int textWidth;

  BitmapFont font;
  String text;

  @override
  void create() {
    font = assetManager.get('font');
    text = assetManager.get('lipsum');

    camera = Camera2D.originBottomLeft(width, height);
    renderer = SpriteBatch.defaultShader(gl);

    gl.setGLViewport(canvasWidth, canvasHeight);

    textWidth = (width * 0.6).toInt();
    firstTween();
  }

  @override
  void preload() {
    assetManager.load('font', loadFont('font/lora.fnt', loadTexture(gl, 'font/lora_0.png', linear)));
    assetManager.load('lipsum', HttpRequest.getString('font/lipsum.txt'));
  }

  @override
  void render(double delta) {
    gl.clearScreen(Colors.white);

    camera.update();

    renderer.projection = camera.combined;
    gl.context.disable(WebGL.DEPTH_TEST);
    gl.context.enable(WebGL.BLEND);
    gl.context.blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);
    renderer.begin();
    font.drawParagraph(renderer, (width - textWidth) ~/ 2, height, text, lineWidth: textWidth, align: TextAlign.right, scale: pixelRatio);
    renderer.end();
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
    camera = Camera2D.originBottomLeft(width, height);
  }

  @override
  void update(double delta) {}

  void firstTween() {
    Tween()
      ..set = [(v) => textWidth = v.toInt()]
      ..get = [() => textWidth]
      ..target = [0.2 * width]
      ..duration = 10
      ..ease = Ease.quartOut
      ..callback = secondTween
      ..start(tweenManager);
  }

  void secondTween() {
    Tween()
      ..set = [(v) => textWidth = v.toInt()]
      ..get = [() => textWidth]
      ..target = [width * 0.6]
      ..duration = 10
      ..ease = Ease.quartOut
      ..callback = firstTween
      ..start(tweenManager);
  }

  @override
  void config() {
    scaleMode = ScaleMode.resize;
  }
}
