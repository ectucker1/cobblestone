import 'package:cobblestone/cobblestone.dart';

main() {
  new AudioExample();
}

class AudioExample extends BaseGame {

  Camera2D camera;
  Matrix4 pMatrix;

  SpriteBatch renderer;
  GameTexture nehe;

  bool get isLoaded => nehe != null;

  Sound music;
  Sound beat;

  @override
  create() {
    camera = new Camera2D.originBottomLeft(width, height);

    setGLViewport(canvasWidth, canvasHeight);

    music = assetManager.get("technogeek.wav");
    beat = assetManager.get("short wind sound.wav");

    window.onKeyUp.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ONE) {
        beat.play();
      } else if(e.keyCode == KeyCode.TWO) {
        music.loop();
      }
    });
  }

  @override
  preload() {
    assetManager.load("technogeek.wav", loadGameSound("technogeek.wav"));
    assetManager.load("spaceship.wav", loadGameSound("spaceship.wav"));
    assetManager.load("short wind sound.wav", loadGameSound("short wind sound.wav"));
  }

  @override
  render(num delta) {
    clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();

  }

  resize(num width, num height) {
    setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  update(num delta) {
  }
}