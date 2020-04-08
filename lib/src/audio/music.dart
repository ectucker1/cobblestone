part of cobblestone;

/// Loads a sound using an [AudioElement].
Future<Music> loadMusic(AudioWrapper audio, String url) async {
  AudioElement element = AudioElement(url);
  return Music(audio, element);
}

/// A longer sound, streamed from an [AudioElement].
class Music extends AudioPlayer {
  final AudioWrapper _audio;

  /// The media element for this music.
  final MediaElement element;

  /// The progress, in seconds, through the media element.
  double get time => element.currentTime;
  /// The length of the media element, in seconds.
  double get duration => element.duration;

  bool _playing = false;
  double _volume = 1.0;

  /// Creates a new music from an HTML Media Element.
  ///
  /// This should typically be called via [loadMusic]
  Music(this._audio, this.element);

  /// Plays this music. If [loop] is true, repeats indefinitely.
  @override
  void play({bool loop = false, Function onEnd}) {
    element.loop = loop;
    element.volume = volume;
    element.onEnded.first.then((e) {
      onEnd?.call();
    });
    element.play();
    playing = true;
  }

  /// Stops this sound.
  @override
  void stop() {
    element.pause();
    element.currentTime = 0;
  }

  /// Loops this sound indefinitely.
  @override
  void loop() {
    play(loop: true);
  }

  /// True if the music is currently playing, false if not
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

  /// The volume, clamped from 0 to 1, of this music.
  @override
  double get volume => _volume;
  set volume(double volume) {
    _volume = volume;
    if (_volume < 0) {
      _volume = 0;
    } else if (_volume > 1) {
      _volume = 1;
    }
    element.volume = _volume;
  }
}
