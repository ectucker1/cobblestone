part of examples;

class AudioExample extends BaseGame {
  Camera2D camera;
  Matrix4 pMatrix;

  SpriteBatch renderer;

  Music music;
  Sound sound;

  @override
  void create() {
    camera = Camera2D.originBottomLeft(width, height);

    gl.setGLViewport(canvasWidth, canvasHeight);

    music = assetManager.get('technogeek');
    sound = assetManager.get('wind');
  }

  @override
  void preload() {
    assetManager.load('technogeek', loadMusic(audio, 'audio/technogeek.ogg'));
    assetManager.load('wind', loadSound(audio, 'audio/wind.wav'));
  }

  @override
  void render(double delta) {
    gl.clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  void update(double delta) {
    if (keyboard.keyJustPressed(KeyCode.ONE)) {
      sound.play();
    } else if (keyboard.keyJustPressed(KeyCode.TWO)) {
      music.volume = 1.0;
      music.loop();
    } else if (keyboard.keyJustReleased(KeyCode.ZERO)) {
      audio.stopAll();
    } else if (keyboard.keyJustReleased(KeyCode.F)) {
      Tween()
          ..get = [() => music.volume]
          ..set = [(v) => music.volume = v]
          ..target = [0.0]
          ..duration = 5.0
          ..ease = Ease.linearInOut
          ..start(tweenManager);
    }
  }
}
