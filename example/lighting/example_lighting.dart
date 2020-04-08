part of examples;

class LightingExample extends BaseGame {
  ShaderProgram shaderProgram;

  Camera2D camera;

  SpriteBatch renderer;
  Texture wall;
  Texture wallNorm;

  double time = 0.0;

  int numLights = 10;
  List<Vector3> lightPosData = [];
  List<Vector4> lightColorInit = [];

  List<Vector3> lightPos = [];
  List<Vector4> lightColor = [];

  Vector4 ambientColor = Vector4(0.6, 0.6, 1.0, 0.001);
  Vector3 attenuation = Vector3(0.4, 3.0, 20.0);

  @override
  void create() {
    camera = Camera2D.originBottomLeft(width, height);
    renderer = SpriteBatch(gl, assetManager.get('lighting'));
    renderer.setAdditionalUniforms = () {
      renderer.setUniform('uLightPos', lightPos);
      renderer.setUniform('uLightColor', lightColor);
      renderer.setUniform('uAmbientLightColor', ambientColor);
      renderer.setUniform('uScreenRes',
          Vector2(width.toDouble(), height.toDouble()));
      renderer.setUniform('uFalloff', attenuation);
      renderer.setUniform('uDiffuse', wall.bind(1), true);
      renderer.setUniform('uNormal', wallNorm.bind(2), true);
    };

    gl.setGLViewport(canvasWidth, canvasHeight);

    for(int i = 0; i < numLights; i++) {
      var newPos = Vector3.random();
      newPos.scale(2.0);
      newPos.sub(Vector3.all(2.0));
      lightPosData.add(newPos);
      lightColorInit.add(Vector4.random());

      lightPos.add(Vector3.random());
      lightPos[i].z = 0.075;
      lightColor.add(Vector4.zero());
    }

    wall = assetManager.get('tileDiffuse');
    wallNorm = assetManager.get('tileNormal');
  }

  @override
  void preload() {
    assetManager.load('lighting', loadProgram(gl, 'lighting/basic.vertex', 'lighting/lighting.fragment'));
    assetManager.load('tileDiffuse', loadTexture(gl, 'lighting/hp_floor_tiles_02.png', linear));
    assetManager.load('tileNormal', loadTexture(gl, 'lighting/hp_floor_tiles_02_norm.png', linear));
  }

  @override
  void render(double delta) {
    gl.clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();

    renderer.projection = camera.combined;

    renderer.begin();
    renderer.draw(wall, 0.0, 0.0, width: height, height: height);
    renderer.draw(wall, height, 0, width: height, height: height);
    renderer.end();
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
  }

  @override
  void update(double delta) {
    time += delta;
    for(int i = 0; i < numLights; i++) {
      lightPos[i].x = lightPos[i].x + lightPosData[i].x * delta;
      lightPos[i].y = lightPos[i].y + lightPosData[i].y * delta;
      if(lightPos[i].x > 1) {
        lightPos[i].x = 1.0;
        lightPosData[i].x = -1.0;
      }
      if(lightPos[i].x < 0) {
        lightPos[i].x = 0.0;
        lightPosData[i].x = 1.0;
      }
      if(lightPos[i].y > 1) {
        lightPos[i].y = 1.0;
        lightPosData[i].y = -1.0;
      }
      if(lightPos[i].y < 0) {
        lightPos[i].y = 0.0;
        lightPosData[i].y = 1.0;
      }

      lightColor[i].r = cos(time);
      lightColor[i].g = sin(time);
      lightColor[i].b = sin(time);
    }
  }

  @override
  void config() {
    scaleMode = ScaleMode.resize;
  }

}
