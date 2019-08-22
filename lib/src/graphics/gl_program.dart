part of cobblestone;

/// Compiles a new shader form code at the [vertex] and [fragment] URLS.
Future<ShaderProgram> loadProgram(GLWrapper wrapper, String vertex, String fragment) {
  return Future.wait([
    HttpRequest.getString(vertex),
    HttpRequest.getString(fragment)
  ]).then((List<String> sources) =>
      wrapper.compileShader(sources[0], sources[1]));
}

/// A compiled WebGL shader
class ShaderProgram {
  /// Reference to the game's [GLWrapper]
  GLWrapper wrapper;
  GL.RenderingContext _context;

  /// List of vertex attribute names and locations.
  Map<String, int> attributes = Map<String, int>();
  /// List of uniform names and locations.
  Map<String, GL.UniformLocation> uniforms =
      Map<String, GL.UniformLocation>();

  /// The complete GL program to be used in rendering.
  GL.Program program;

  /// The compiled fragment shader used in this program.
  GL.Shader fragShader;
  /// The compiled vertex shader used in this program.
  GL.Shader vertShader;

  /// Compiles a new shader with the text content of [vertexSource] and [fragmentSource].
  ShaderProgram.compile(this.wrapper, String vertexSource, String fragmentSource) {
    _context = wrapper.context;
    
    fragShader = _context.createShader(WebGL.FRAGMENT_SHADER);
    _context.shaderSource(fragShader, fragmentSource);
    _context.compileShader(fragShader);

    vertShader = _context.createShader(WebGL.VERTEX_SHADER);
    _context.shaderSource(vertShader, vertexSource);
    _context.compileShader(vertShader);

    program = _context.createProgram();
    _context.attachShader(program, vertShader);
    _context.attachShader(program, fragShader);
    _context.linkProgram(program);

    if (!_context.getProgramParameter(program, WebGL.LINK_STATUS)) {
      print("Could not initialise shaders");
    }

    int activeAttributes =
        _context.getProgramParameter(program, WebGL.ACTIVE_ATTRIBUTES);
    int activeUniforms = _context.getProgramParameter(program, WebGL.ACTIVE_UNIFORMS);

    for (int i = 0; i < activeAttributes; i++) {
      GL.ActiveInfo a = _context.getActiveAttrib(program, i);
      int attributeLocation = _context.getAttribLocation(program, a.name);
      attributes[a.name] = attributeLocation;
    }

    for (int i = 0; i < activeUniforms; i++) {
      GL.ActiveInfo a = _context.getActiveUniform(program, i);
      uniforms[a.name] = _context.getUniformLocation(program, a.name);
    }
  }

  /// Enables vertex attributes and tells WebGL to use this program.
  startProgram() {
    attributes
        .forEach((name, location) => _context.enableVertexAttribArray(location));
    _context.useProgram(program);
  }

  /// Sets uniforms using Dart datatypes.
  ///
  /// These can be of type int, double, [Vector2], [Vector3], [Vector4], [Matrix4] or lists of the above.
  setUniform(String name, dynamic value) {
    if (value is int) {
      _context.uniform1i(uniforms[name], value);
    } else if (value is double) {
      _context.uniform1f(uniforms[name], value);
    } else if (value is Vector2) {
      _context.uniform2f(uniforms[name], value.x, value.y);
    } else if (value is Vector3) {
      _context.uniform3f(uniforms[name], value.x, value.y, value.z);
    } else if (value is Vector4) {
      _context.uniform4f(uniforms[name], value.x, value.y, value.z, value.w);
    } else if (value is Matrix4) {
      _context.uniformMatrix4fv(uniforms[name], false, value.storage);
    } else if(value is List) {
      name = name + '[0]'; //Really weird way an array uniform is distinguished
      if (value[0] is int) {
        _context.uniform1iv(uniforms[name], value);
      } else if (value[0] is double) {
        _context.uniform1fv(uniforms[name], value);
      } else if (value[0] is Vector2) {
        var array = [];
        for(var vector in value) {
          array.add(vector.x);
          array.add(vector.y);
        }
        _context.uniform2fv(uniforms[name], array);
      } else if (value[0] is Vector3) {
        var array = [];
        for(var vector in value) {
          array.add(vector.x);
          array.add(vector.y);
          array.add(vector.z);
        }
        _context.uniform3fv(uniforms[name], array);
      } else if (value[0] is Vector4) {
        var array = [];
        for(var vector in value) {
          array.add(vector.x);
          array.add(vector.y);
          array.add(vector.z);
          array.add(vector.w);
        }
        _context.uniform4fv(uniforms[name], array);
      } else if (value[0] is Matrix4) {
        var array = [];
        for(var matrix in value) {
          array.addAll(matrix.storage);
        }
        _context.uniformMatrix4fv(uniforms[name], false, array);
      }
    }
  }

  /// Disables program vertex attributes.
  ///
  /// A new program will need to be started before rendering again.
  endProgram() {
    attributes
        .forEach((name, location) => _context.disableVertexAttribArray(location));
  }
}
