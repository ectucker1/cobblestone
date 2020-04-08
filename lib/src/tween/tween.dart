part of cobblestone;

/// An animation between two values
class Tween {

  /// Tells whether the tween has been complete
  bool finished = false;

  /// A list of functions that return the current values of properties being animated
  List<Function> get = [];

  /// A list of functions that set the values of properties being animated
  List<Function> set = [];

  /// A list of values that the tween is animating to
  List target = [];

  /// Delay before the animation begins, default 0
  double delay = 0.0;

  /// Duration of the animation, default 0
  double duration = 0.0;

  /// Easing function used, usually from [tween.dart]
  Easing ease = Ease.linearInOut;

  /// Void function called when the tween is complete
  Function callback = () => {};

  // Initial valued of animated properties
  List _initial;

  // Elapsed time since starting
  double _time = 0.0;

  // Storage for another tween in a chain
  Tween _next;

  // The manager of this tween
  TweenManager _manager;

  /// Constructs a new tween. Use properties to set behavior.
  Tween();

  /// Adds the tween to the manager
  void start(TweenManager manager) {
    _initial = get.map((f) => f()).toList();

    manager.add(this);
    _manager = manager;
  }

  /// Runs this tween, then the next one
  void chain(Tween tween) {
    _next = tween;
  }

  /// Updates the tween to it position after [delta] more seconds
  void update(double delta) {
    _time += delta;

    if(_time > delay) {
      for (int i = 0; i < set.length; i++) {
        set[i](ease(_time - delay, _initial[i], target[i] - _initial[i], duration));
      }
      finished = _time >= delay + duration;
    }

    if(finished) {
      for (int i = 0; i < set.length; i++) {
        set[i](target[i]);
      }
      callback();
      if(_next != null) {
        _next.start(_manager);
      }
    }
  }

}