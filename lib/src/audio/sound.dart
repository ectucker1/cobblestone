part of cobblestone;

/// Loads a sound from a url.
Future<Sound> loadSound(AudioWrapper audio, String url) async {
  var request = await HttpRequest.request(url, responseType: 'arraybuffer');
  var buffer = await audio.context.decodeAudioData(request.response);
  return Sound(audio, buffer);
}

/// A playable sound using WebAudio.
///
/// Sounds are typically short files, use [Music] for longer tracks or narration.
class Sound extends AudioPlayer {
  final AudioWrapper _audio;
  web_audio.AudioContext _context;

  /// The raw audio data used to play this sound.
  var buffer;

  var _sources;
  int _nextID = 0;

  web_audio.GainNode _gainNode;

  bool _playing = false;

  double _volume = 1.0;

  /// Creates a new sound form an audio buffer
  Sound(this._audio, this.buffer) {
    _context = _audio.context;
    _gainNode = _context.createGain();
    _sources = {};
  }

  /// Plays this sound.
  ///
  /// If [loop] is set true, repeats indefinitely.
  /// Calls [onEnd] after the sound is finished.
  @override
  void play({bool loop = false, Function onEnd}) {
    final int id = _nextID;

    var source = _createSourceNode(loop);

    _gainNode.gain.value = volume;
    source.connectNode(_gainNode, 0, 0);
    _gainNode.connectNode(_context.destination, 0, 0);

    source.onEnded.listen((Event e) {
      onEnd?.call();
      _removeInstance(id);
    });

    _sources[id] = source;

    _nextID++;
    playing = true;
  }

  web_audio.AudioBufferSourceNode _createSourceNode(bool loop) {
    web_audio.AudioBufferSourceNode source = _context.createBufferSource();
    source.buffer = buffer;
    source.loop = loop;
    source.start(0);
    return source;
  }

  /// Play sound only if it's not already playing.
  void playIfNot({bool loop = false, Function onEnd}) {
    if (!playing) {
      play(loop: loop, onEnd: onEnd);
    }
  }

  /// Stops all instances of this sound.
  @override
  void stop() {
    for (var source in _sources.values) {
      source.stop(0);
    }
    _sources.clear();
    playing = false;
  }

  void _removeInstance(var id) {
    // Remove node when it finishes playing
    if (_sources[id] != null) {
      _sources[id].stop(0);
      _sources.remove(id);
    }
    playing = _sources.length != 0;
  }

  /// True of any instance of this sound is currently playing.
  @override
  bool get playing => _playing;
  set playing(bool playing) {
    _playing = playing;
    if (playing) {
      _audio.addPlaying(this);
    } else {
      _audio.removePlaying(this);
    }
  }

  /// The volume of this sound.
  @override
  double get volume => _volume;
  set volume(double volume) {
    _volume = volume;
    if (_volume < 0) {
      _volume = 0;
    } else if (_volume > 1) {
      _volume = 1;
    }
    _gainNode.gain.value = _volume;
  }
}
