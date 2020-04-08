part of cobblestone;

/// A state/screen of a game.
///
/// [BaseGame] implements the basic lifecycle of this class. Extra states should be called by users from there, with a user defined state machine, stack, etc.
abstract class State {

  /// The base game this state is a part of.
  BaseGame get game;

  /// Wrapper around common WebGL functions.
  GLWrapper get gl => game.gl;

  /// The requested width of the game window. Used for [ScaleMode.fit] or [ScaleMode.fill].
  int get requestedWidth => game.requestedWidth;
  /// The requested height of the game window. Used for [ScaleMode.fit] or [ScaleMode.fill].
  int get requestedHeight => game.requestedHeight;
  /// The method used to scale the game canvas.
  ScaleMode get scaleMode => game.scaleMode;

  /// HTML canvas element the game is drawn on.
  CanvasElement get canvas => game.canvas;
  /// The actual width of the canvas.
  int get canvasWidth => game.canvasWidth;
  /// The actual height of the canvas.
  int get canvasHeight => game.canvasHeight;

  /// The effective width of the game. Use this for most calculations.
  /// Varies based on actual canvas size, and [scaleMode].
  int get width => game.width;
  /// The effective width of the game. Use this for most calculations.
  /// Varies based on actual canvas size, and [scaleMode].
  int get height => game.height;

  /// Game asset manager. Used to wait for asynchronously loaded assets.
  AssetManager get assetManager => game.assetManager;

  /// The game tween manager. Lists and updates [Tween]s added to it.
  TweenManager get tweenManager => game.tweenManager;

  /// The game audio context. Can be used for some global control of various sounds.
  AudioWrapper get audio => game.audio;

  /// Storage of current state of keyboard input.
  Keyboard get keyboard => game.keyboard;
  /// Storage of current state of mouse input.
  Mouse get mouse => game.mouse;

  /// Loads assets using [assetManager].
  void preload();

  /// Called once after assets are loaded. Create custom game state here.
  void create();

  /// Resumes the state.
  void resume();

  /// Pauses the state.
  void pause();

  /// Updates the state. Called each frame before [render].
  ///
  /// [delta] is the time in seconds since last frame.
  void update(double delta);

  /// Renders the state. Called each frame after [update].
  ///
  /// [delta] is the time in seconds since last frame.
  void render(double delta);

  /// Called after canvas changes size.
  void resize(int width, int height);

}
