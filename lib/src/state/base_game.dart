part of cobblestone;

/// A base class for programming games.
///
/// This is the starting point for most development with the engine.
abstract class BaseGame implements State {

  // A stopwatch, used to calculate delta time
  Stopwatch _stopwatch;

  /// Wrapper around common WebGL functions.
  @override
  GLWrapper gl;

  /// The requested width of the game window. Used for [ScaleMode.fit] or [ScaleMode.fill].
  @override
  int requestedWidth = 640;
  /// The requested width of the game window. Used for [ScaleMode.fit] or [ScaleMode.fill].
  @override
  int requestedHeight = 480;
  /// The method used to scale the game canvas.
  @override
  ScaleMode scaleMode = ScaleMode.fit;

  /// Ratio between canvas physical pixels and CSS pixels
  double pixelRatio;

  /// If set to true, will scale the canvas size up fully on HDPI screens
  bool enableHDPI = true;

  /// HTML canvas element the game is drawn on.
  @override
  CanvasElement canvas;
  /// The actual width of the canvas.
  @override
  int canvasWidth;
  /// The actual height of the canvas.
  @override
  int canvasHeight;

  /// The effective width of the game. Use this for most calculations.
  /// Varies based on actual canvas size, and [scaleMode]
  @override
  int width;
  /// The effective width of the game. Use this for most calculations.
  /// Varies based on actual canvas size, and [scaleMode]
  @override
  int height;

  /// Game asset manager. Used to wait for asynchronously loaded assets.
  @override
  final AssetManager assetManager = AssetManager();

  /// The game tween manager. Lists and updates [Tween]s added to it.
  @override
  final TweenManager tweenManager = TweenManager();

  /// The game audio context. Can be used for some global control of various sounds.
  @override
  final AudioWrapper audio = AudioWrapper();

  /// Storage of current state of keyboard input.
  @override
  Keyboard keyboard;
  /// Storage of current state of mouse input.
  @override
  Mouse mouse;

  @override
  BaseGame get game => this;

  bool _started = false;
  bool _stopped = false;

  StreamSubscription _resizeSub;

  /// Creates a new game with the first canvas element on the page.
  BaseGame(): this.query('canvas');

  /// Creates a new game with the canvas selected by [selector].
  BaseGame.query(String selector): this.withCanvas(querySelector(selector));

  /// Creates a new game with the given [canvas].
  BaseGame.withCanvas(this.canvas) {
    config();
    gl = GLWrapper(canvas.getContext3d());
    keyboard = Keyboard();
    mouse = Mouse(canvas, enableHDPI);
    _resizeCanvas();
    _startLoop();
  }

  // Resizes the canvas upon resize events.
  void _resizeCanvas() {
    pixelRatio = window.devicePixelRatio;

    scaleCanvas(canvas, scaleMode, requestedWidth, requestedHeight,
        window.innerWidth, window.innerHeight, enableHDPI);
    canvasWidth = canvas.width;
    canvasHeight = canvas.height;

    width = effectiveDimension(scaleMode, requestedWidth, canvasWidth);
    height = effectiveDimension(scaleMode, requestedHeight, canvasHeight);

    gl.setGLViewport(canvasWidth, canvasHeight);

    mouse._resize(width, height);

    if (_started) resize(width, height);
  }

  // Sets some things up, and starts the loop.
  void _startLoop() {
    preload();

    _tick(0);
  }

  /// First method in lifecycle. Set [scaleMode], [requestedWidth], and [requestedHeight] here.
  void config() {}

  /// Second method in lifecycle. Load assets here using [assetManager]
  @override
  void preload();

  /// Last method called in the beginning of the game. Create new game elements with loaded assets here.
  @override
  void create();

  /// Actually initializes the game
  void _start() {
    create();

    _stopwatch = Stopwatch();
    _stopwatch.start();

    _resizeCanvas();
    _resizeSub = window.onResize.listen((Event e) => _resizeCanvas());

    _started = true;
  }

  /// Stops looping the game
  void stop() {
    _stopped = true;
    _resizeSub.cancel();
    mouse._cancelSubs();
    keyboard._cancelSubs();
  }

  /// A tick in the game loop
  void _tick(time) {
    if (_started) {
      double delta = _stopwatch.elapsedMilliseconds / 1000.0;
      _stopwatch.reset();

      // Don't update right after long breaks (e.g. window minimized)
      delta = delta < 1 ? delta : 0.0;

      tweenManager.update(delta);
      update(delta);
      render(delta);

      keyboard.update();
      mouse.update();
    } else if (assetManager.allLoaded()) {
      _start();
    }

    if(!_stopped) {
      window.animationFrame.then(_tick);
    }
  }

  /// Updates the state. Called each frame before [render].
  ///
  /// [delta] is the time in seconds since last frame.
  @override
  void update(double delta);

  /// Renders the state. Called each frame after [update].
  ///
  /// [delta] is the time in seconds since last frame.
  @override
  void render(double delta);

  /// Called after canvas changes size
  @override
  void resize(int width, int height) {}

  /// Pauses the game.
  @override
  void pause() {}

  /// Resumes the game.
  @override
  void resume() {}

}
