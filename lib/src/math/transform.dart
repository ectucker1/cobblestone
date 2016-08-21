part of cobblestone;

class Transform {

  Matrix4 combined;

  Vector2 temp;

  Vector2 translation;
  num rotation;
  Vector2 currentScale;

  Transform.identity() {
    setDefaults();
    update();
  }

  Transform.all(num x, num y, num angle, bool counter, num scaleX, num scaleY) {
    setDefaults();
    translate(x, y);
    rotate(angle, counter);
    scale(scaleX, scaleY);
    update();
  }

  Transform.copy(Transform other) {
    setDefaults();
    translation = new Vector2.copy(other.translation);
    rotation = other.rotation;
    currentScale = new Vector2.copy(other.currentScale);
    update();
  }

  void setDefaults() {
    translation = new Vector2.zero();
    rotation = 0;
    currentScale = new Vector2.all(1.0);
    temp = new Vector2.zero();

    combined = new Matrix4.identity();
  }

  void translate(x, [num y]) {
    if(x is Vector2) {
      translation.add(x);
    } else {
      temp.setValues(x, y);
      translation.add(temp);
    }
  }

  void setTranslation(x, [num y]) {
    if(x is Vector2) {
      translation.setFrom(x);
    } else {
      translation.setValues(x.toDouble(), y.toDouble());
    }
  }

  void rotate(num amount, bool counter) {
    if(!counter) {
      rotation += amount;
    } else {
      rotation -= amount;
    }
  }

  void setRotation(num angle) {
    rotation = angle;
  }

  void scale(x, [num y]) {
    if(x is Vector2) {
      currentScale.multiply(x);
    } else {
      temp.setValues(x, y);
      currentScale.multiply(temp);
    }
  }

  void setScale(x, [num y]) {
    if(x is Vector2) {
      currentScale.setFrom(x);
    } else {
      currentScale.setValues(x.toDouble(), y.toDouble());
    }
  }

  void update() {
    combined.setIdentity();
    combined.translate(translation.x, translation.y, 0.0);
    combined.rotateZ(rotation);
    combined.scale(currentScale.x, currentScale.y, 0.0);
  }

  num get x => translation.x;
  num get y => translation.y;

  void set x(num x) => translation.setValues(x.toDouble(), y.toDouble());
  void set y(num y) => translation.setValues(x.toDouble(), y.toDouble());

  num get scaleX => currentScale.x;
  num get scaleY => currentScale.y;

  void set scaleX(num scaleX) => translation.setValues(scaleX.toDouble(), scaleY.toDouble());
  void set scaleY(num scaleY) => translation.setValues(scaleX.toDouble(), scaleY.toDouble());

}