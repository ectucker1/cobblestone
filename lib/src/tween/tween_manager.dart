part of cobblestone;

/// A set of tweens that updates each one.
///
/// [BaseGame] has a default tween manager that is updated every frame.
class TweenManager {

  // List of tweens in the manager.
  final List<Tween> _activeTweens = [];

  // Buffer of tweens to add before the next update.
  final List<Tween> _tweensToAdd = [];

  /// Creates a new tween manager.
  ///
  /// [BaseGame] has a default tween manager, but others could be used for different timesteps.
  TweenManager();

  /// Adds a tween to the manager.
  void add(Tween tween) {
    _tweensToAdd.add(tween);
  }

  /// Updates all tweens in the manager.
  void update(double delta) {
    for(var tween in _tweensToAdd) {
      _activeTweens.add(tween);
    }
    _tweensToAdd.clear();

    for(var tween in _activeTweens) {
      tween.update(delta);
    }
    _activeTweens.removeWhere((t) => t.finished);
  }

}