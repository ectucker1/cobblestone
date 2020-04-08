part of cobblestone;

/// An offscreen texture that can be rendered to.
class Framebuffer {
  /// Reference to the game's [GLWrapper].
  GLWrapper wrapper;
  gl.RenderingContext _context;

  /// Texture rendered to by this framebuffer.
  ///
  /// Can be used to render the contents of the framebuffer to the screen in various configurations.
  Texture texture;
  /// Reference to the actual WebGL framebuffer object.
  gl.Framebuffer buffer;

  /// Shader used by this framebuffer.
  ShaderProgram shader;
  SpriteBatch _batch;

  /// Width of the framebuffer, in pixels.
  int width;
  /// Height of the framebuffer, in pixels.
  int height;

  /// Called during rendering, use [setUniform] to provide additional data for shaders here.
  Function setAdditionalUniforms = () {};

  /// Creates a new framebuffer of [width], [height]. Can use [shader] for effects.
  Framebuffer(this.wrapper, this.width, this.height, {this.shader, filter = WebGL.NEAREST}) {
    _context = wrapper.context;

    shader ??= wrapper.batchShader;
    _batch = SpriteBatch(wrapper, shader, maxSprites: 2);

    texture = Texture.empty(wrapper, width, height, filter);

    buffer = _context.createFramebuffer();
    _context.bindFramebuffer(WebGL.FRAMEBUFFER, buffer);

    _context.framebufferTexture2D(WebGL.FRAMEBUFFER, WebGL.COLOR_ATTACHMENT0,
        WebGL.TEXTURE_2D, texture.texture, 0);

    endCapture();
  }

  /// Directs all further rendering to this framebuffer.
  void beginCapture() {
    _context.bindFramebuffer(WebGL.FRAMEBUFFER, buffer);
  }

  /// Stops capturing the rendering.
  void endCapture() {
    _context.bindFramebuffer(WebGL.FRAMEBUFFER, null);
  }

  /// Sets a uniform for this framebuffer's [shader].
  void setUniform(String name, dynamic value, [bool isInt = false]) =>
      shader.setUniform(name, value, isInt);

  /// Renders the FBO to the screen via an internal [SpriteBatch].
  ///
  /// Calls [setAdditionalUniforms] midway.
  void render(Matrix4 projection, [int x = 0, int y = 0, int width, int height]) {
    wrapper.clearScreen(0.0, 0.0, 0.0, 1.0);
    _batch.projection = projection;
    _batch.begin();

    setAdditionalUniforms();

    width ??= this.width ~/ 2;
    height ??= this.height ~/ 2;

    _batch.draw(texture, x, y, width: width, height: height);
    _batch.end();
  }
}
