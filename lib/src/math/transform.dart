part of cobblestone;

/// A set of independently tracked transformations, grouped together into a [Matrix4].
class Transform {

  /// Updated to contain composition of all transformations.
  Matrix4 combined;
  /// Updated to be the inverse of [combined] matrix.
  Matrix4 invCombined;

  /// Translation vector of this transform.
  Vector2 translation;
  /// Clockwise rotation of this transform, in radians.
  double rotation;
  /// Scale multipliers in each dimension for this transform.
  Vector2 scale;

  /// If true, [translation] and [scale] are rounded to integers when creating the [combined] and [invCombined] matrices.
  bool roundInt;

  final Vector2 _temp = Vector2.zero();

  /// Creates a new transform that applies no change.
  Transform.identity() {
    setIdentity();
    update();
  }

  /// Creates a new transform with all the values given.
  Transform.all(num x, num y, num angle, bool counter, num scaleX, num scaleY) {
    setIdentity();
    translate(x, y);
    rotate(angle, counter);
    multiplyScale(scaleX, scaleY);
    update();
  }

  /// Creates a new transform with values identical to [other].
  Transform.copy(Transform other) {
    setIdentity();
    translation = Vector2.copy(other.translation);
    rotation = other.rotation;
    scale = Vector2.copy(other.scale);
    update();
  }

  /// Sets this transform to identity, i.e. no change when applying it.
  void setIdentity() {
    translation = Vector2.zero();
    rotation = 0;
    scale = Vector2.all(1.0);
    roundInt = false;

    combined = Matrix4.identity();
    invCombined = Matrix4.identity();
  }

  /// Translates the vector by [x] if it is a [Vector2] or by [x],[y] if they are numbers.
  void translate(x, [num y]) {
    if (x is Vector2) {
      translation.add(x);
    } else if (x is num && y is num) {
      _temp.setValues(x, y);
      translation.add(_temp);
    }
  }

  /// Increments rotation by [amount] in radians, -[amount] if [counter] is true.
  void rotate(num amount, [bool counter = false]) {
    if (!counter) {
      rotation += amount;
    } else {
      rotation -= amount;
    }
  }

  /// Multiplies the scale components by [x] if it is a [Vector2] or by [x],[y] if they are numbers.
  void multiplyScale(x, [num y]) {
    if (x is Vector2) {
      scale.multiply(x);
    } else if (x is num && y is num) {
      _temp.setValues(x, y);
      scale.multiply(_temp);
    }
  }

  /// X-component of translation.
  num get x => translation.x;
  set x(num x) => translation.setValues(x.toDouble(), y.toDouble());

  /// Y-component of translation.
  num get y => translation.y;
  set y(num y) => translation.setValues(x.toDouble(), y.toDouble());

  /// X-component of scale.
  num get scaleX => scale.x;
  set scaleX(num scaleX) =>
      translation.setValues(scaleX.toDouble(), scaleY.toDouble());

  /// Y-component of scale.
  num get scaleY => scale.y;
  set scaleY(num scaleY) =>
      translation.setValues(scaleX.toDouble(), scaleY.toDouble());

  /// Updates the [combined] and [invCombined] matrices for the current
  void update() {
    combined.setIdentity();
    invCombined.setIdentity();
    if (roundInt) {
      combined.translate(
          translation.x.roundToDouble(), translation.y.roundToDouble(), 0.0);
      combined.rotateZ(rotation);
      combined.scale(
          scale.x.roundToDouble(), scale.y.roundToDouble(), 0.0);

      invCombined.rotateZ(-rotation);
      invCombined.scale(1 / scale.x.roundToDouble(),
          1 / scale.y.roundToDouble(), 0.0);
      invCombined.translate(
          -translation.x.roundToDouble(), -translation.y.roundToDouble(), 0.0);
    } else {
      combined.translate(translation.x, translation.y, 0.0);
      combined.rotateZ(rotation);
      combined.scale(scale.x, scale.y, 0.0);

      invCombined.rotateZ(-rotation);
      invCombined.scale(1 / scale.x, 1 / scale.y, 0.0);
      invCombined.translate(-translation.x, -translation.y, 0.0);
    }
  }

}
