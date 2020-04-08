part of cobblestone;

/// A method of scaling the game canvas
enum ScaleMode {
  /// Fully fills the window with the canvas, extending past the window borders to keep the aspect ratio.
  fill,
  /// Fits the canvas within the window size at the requested aspect ratio and internal size.
  fit,
  /// Scales the canvas to fit the full window size, and sets the game screeen.
  resize
}

/// Scales [element] based on [mode].
void scaleCanvas(CanvasElement element, ScaleMode mode, int requestWidth,
    int requestHeight, int parentWidth, int parentHeight,
    bool handleHDPI) {
  double devicePixelRatio = handleHDPI ? window.devicePixelRatio : 1;
  switch (mode) {
    case ScaleMode.fill:
      double scale = max(parentWidth / requestWidth, parentHeight / requestHeight);
      element.width = (requestWidth * scale * devicePixelRatio).toInt();
      element.height = (requestHeight * scale * devicePixelRatio).toInt();
      break;
    case ScaleMode.fit:
      double scale = min(parentWidth / requestWidth, parentHeight / requestHeight);
      element.width = (requestWidth * scale * devicePixelRatio).toInt();
      element.height = (requestHeight * scale * devicePixelRatio).toInt();
      break;
    case ScaleMode.resize:
      element.width = (window.innerWidth * devicePixelRatio).toInt();
      element.height = (window.innerHeight * devicePixelRatio).toInt();
      break;
  }
}

/// The dimension that can be assumed by users.
int effectiveDimension(ScaleMode mode, int requested, int canvas) {
  switch (mode) {
    case ScaleMode.resize:
      return canvas;
    default:
      return requested;
  }
}
