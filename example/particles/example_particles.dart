part of examples;

class ParticlesExample extends BaseGame {

  Camera2D camera;

  SpriteBatch renderer;

  ParticleEmitter emitter;

  @override
  void create() {
    camera = Camera2D.originBottomLeft(width, height);
    renderer = SpriteBatch.defaultShader(gl);

    ParticleEffect effect = assetManager.get('flame');
    emitter = ParticleEmitter(effect);
}

  @override
  void preload() {
    assetManager.load('flame', loadEffect('particles/flame.json', loadTexture(gl, 'particles/flame.png', linear)));
  }

  @override
  void render(double delta) {
    gl.clearScreen(Colors.gray);

    camera.update();

    gl.context.enable(WebGL.BLEND);
    gl.context.blendFuncSeparate(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA, WebGL.ONE, WebGL.ONE_MINUS_SRC_ALPHA);
    //gl.context.blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);
    renderer.projection = camera.combined;
    renderer.begin();

    emitter.draw(renderer);

    renderer.end();
  }

  @override
  void resize(int width, int height) {
    camera = Camera2D.originBottomLeft(width, height);
  }

  @override
  void update(double delta) {
    emitter.pos = mouse.worldCoord(camera);
    emitter.update(delta);
  }

  @override
  void config() {
    scaleMode = ScaleMode.fit;
    requestedWidth = 1920;
    requestedHeight = 1080;
  }

}
