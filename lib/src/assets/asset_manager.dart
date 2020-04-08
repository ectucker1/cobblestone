part of cobblestone;

/// A manager that loads assets in the background while the main loop continues.
class AssetManager {
  Map<String, dynamic> _assets;

  Map<String, Future<dynamic>> _toLoad;

  /// Creates an empty asset manager.
  AssetManager() {
    _assets = {};
    _toLoad = {};
  }

  /// Returns true if all assets are loaded.
  bool allLoaded() {
    for (String source in _toLoad.keys) {
      if (!_assets.containsKey(source)) {
        return false;
      }
    }
    return true;
  }

  /// Begins loading an asset. Assets can later be retrieved by [get].
  void load(String source, Future asset) {
    if(_toLoad.containsKey(source)) {
      throw ArgumentError('Source must be unique for every asset.');
    }
    _toLoad[source] = asset;
    asset.then((data) {
      _assets[source] = data;
    });
  }

  /// Gets an asset by its [source].
  dynamic get(String source) {
    return _assets[source];
  }

  /// Returns true if an asset with the given [source] has finished loading.
  bool hasLoaded(String source) {
    return _assets.containsKey(source);
  }

  /// Returns a future for an asset with the given [source].
  FutureOr<dynamic> getLoading(String source) {
    if(hasLoaded(source)) {
      return get(source);
    }
    return _toLoad[source];
  }
}
