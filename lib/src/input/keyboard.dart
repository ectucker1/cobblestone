part of cobblestone;

// Based on code from https://stackoverflow.com/questions/13746105/how-to-listen-to-key-press-repetitively-in-dart-for-games

/// A container that tracks the current state of inputs on the keyboard.
class Keyboard {
  /// A map between key codes and the time the key was pressed.
  final Map<int, num> _keys = {};

  /// A map of keys pressed last frame.
  final Map<int, num> _lastKeys = {};

  /// A list of subscription events used to get keybord data.
  final List<StreamSubscription> _subs = [];

  /// Creates a new keyboard, and subscribes to browser input events.
  Keyboard() {
    _subs.add(window.onKeyDown.listen((KeyboardEvent e) {
      // If the key is not set yet, set it with a timestamp.
      if (!_keys.containsKey(e.keyCode)) _keys[e.keyCode] = e.timeStamp;
    }));
    _subs.add(window.onKeyUp.listen((KeyboardEvent e) {
      // Remove the key, it is no longer pressed
      _keys.remove(e.keyCode);
    }));

    _subs.add(window.onFocus.listen((Event e) {
      // Clear all keys, they shouldn't be active when the window is unfocused
      _keys.clear();
    }));
    _subs.add(window.onBlur.listen((Event e) {
      // Clear all keys, they shouldn't be active when the window is unfocused
      _keys.clear();
    }));
  }

  /// Moves the keyboard into the next logical "frame".
  ///
  /// Automatically called in [BaseGame] but may be used for a implementing a custom timestep.
  void update() {
    _lastKeys.clear();
    _lastKeys.addAll(_keys);
  }

  /// Returns true if a given key code, from [KeyCode], is currently pressed down
  bool keyPressed(int keyCode) => _keys.containsKey(keyCode);

  /// Returns true if a given key code, from [KeyCode], was just released this frame
  bool keyJustReleased(int keyCode) =>
      _lastKeys.containsKey(keyCode) && !_keys.containsKey(keyCode);

  /// Returns true if a given key code, from [KeyCode], was just pressed this frame
  bool keyJustPressed(int keyCode) =>
      !_lastKeys.containsKey(keyCode) && _keys.containsKey(keyCode);

  void _cancelSubs() {
    for (var sub in _subs) {
      sub.cancel();
    }
  }
}
