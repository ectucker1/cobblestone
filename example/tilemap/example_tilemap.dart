part of examples;

class TilemapExample extends BaseGame {
  Camera2D camera;

  SpriteBatch renderer;
  DebugBatch debug;

  Tilemap extrudedMap;
  Tilemap atlasMap;

  bool north = false, east = false, south = false, west = false;

  // TODO demo both tilemap modes at once
  bool useAtlas = false;

  @override
  void create() {
    gl.setGLViewport(canvasWidth, canvasHeight);
    camera = Camera2D.originBottomLeft(32 * 16, 18 * 16);
    camera.transform.roundInt = true;

    renderer = SpriteBatch.defaultShader(gl);
    debug = DebugBatch.defaultShader(gl);

    extrudedMap = assetManager.get('extruded.tmx');
    atlasMap = assetManager.get('atlased.tmx');
  }

  @override
  void config() {
    scaleMode = ScaleMode.fit;
    requestedWidth = 32 * 16;
    requestedHeight = 18 * 16;
  }

  @override
  void preload() {
    assetManager.load('atlas.png',
        loadTexture(gl, 'tilemap/atlas.png', nearest));
    assetManager.load('atlas.atlas', loadAtlas('tilemap/atlas.atlas',
        assetManager.getLoading('atlas.png')));
    assetManager.load('tiles.tsx', loadTileset('tilemap/tiles.tsx',
        assetManager.getLoading('atlas.atlas')));
    assetManager.load('atlased.tmx', loadTilemap('tilemap/islands3.tmx',
        tileset: assetManager.getLoading('tiles.tsx')));

    assetManager.load(
        'tileset', loadTexture(gl, 'tilemap/floating_islands_extruded.png'));
    assetManager.load('extruded.tmx', loadTilemap('tilemap/islands.tmx',
        atlas: assetManager.getLoading('tileset'),
        extraMargin: 1, extraSpacing: 2));
  }

  @override
  void render(double delta) {
    gl.clearScreen(41 / 256, 38 / 256, 52 / 256, 1.0);

    camera.update();

    renderer.projection = camera.combined;
    renderer.begin();

    if(keyboard.keyPressed(KeyCode.B)) {
      atlasMap.render(renderer, 0, 0, camera);
      
      double offset = camera.transform.x;
      for (BasicTile texture in atlasMap.tileset.basicTiles.values) {
        renderer.draw(
            texture.texture, offset, height - 16 + camera.transform.y);
        offset += 16;
      }
    } else {
      extrudedMap.render(renderer, 0, 0, camera);
      
      double offset = camera.transform.x;
      for (BasicTile texture in extrudedMap.tileset.basicTiles.values) {
        renderer.draw(
            texture.texture, offset, height - 16 + camera.transform.y);
        offset += 16;
      }
    }

    renderer.end();
    
    if(keyboard.keyPressed(KeyCode.B)) {
      debug.projection = camera.combined;
      debug.begin();
      for (MapObject object in atlasMap.objectGroups.first.objects) {
        debug.color = object.properties['color'];
        debug.drawMap(object);
      }
      debug.end();
    }
  }

  @override
  void resize(int width, int height) {
    gl.setGLViewport(canvasWidth, canvasHeight);
    camera = Camera2D.originBottomLeft(32 * 16, 18 * 16);
  }

  @override
  void update(double delta) {
    if (keyboard.keyJustPressed(KeyCode.W)) north = true;
    if (keyboard.keyJustPressed(KeyCode.D)) east = true;
    if (keyboard.keyJustPressed(KeyCode.S)) south = true;
    if (keyboard.keyJustPressed(KeyCode.A)) west = true;

    if (keyboard.keyJustReleased(KeyCode.W)) north = false;
    if (keyboard.keyJustReleased(KeyCode.D)) east = false;
    if (keyboard.keyJustReleased(KeyCode.S)) south = false;
    if (keyboard.keyJustReleased(KeyCode.A)) west = false;

    if (north) camera.transform.translate(0.0, -delta * 20);
    if (east) camera.transform.translate(-delta * 20, 0.0);
    if (south) camera.transform.translate(0.0, delta * 20);
    if (west) camera.transform.translate(delta * 20, 0.0);
    camera.transform.roundInt = true;
    extrudedMap.update(delta);
  }
}
