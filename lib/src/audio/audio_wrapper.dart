part of cobblestone;

/// A wrapper around the WebAudio context, will have extra features later
class AudioWrapper {

  /// The actual WebAudio context
  web_audio.AudioContext context;

  /// A list of all audio currently playing.
  ///
  /// This list is automatically modified when playing and stopping [AudioPlayer]
  List<AudioPlayer> sounds = [];

  /// Creates a new Audio Wrapper.
  ///
  /// The wrapper provided in BaseGame should typically be used instead.
  AudioWrapper() {
    context = web_audio.AudioContext();
  }

  /// Adds a sound to the list of sounds currently playing.
  void addPlaying(AudioPlayer sound) {
    if(!sounds.contains(sound)) {
      sounds.add(sound);
    }
  }

  /// Removes a sound from this list of sounds currently playing.
  void removePlaying(AudioPlayer sound) {
    sounds.remove(sound);
  }

  /// Stops all currently playing sounds
  void stopAll() {
    var oldSounds = List.from(sounds);
    for(var sound in oldSounds) {
      sound.stop();
    }
  }

}

/// Generic audio element, implemented by [Sound] and [Music]
abstract class AudioPlayer {

  /// True if the sound is playing, false if not
  bool get playing;

  /// The volume of the audio, from 0 to 1
  double get volume;

  /// Plays the audio. Loops if [loop] is true
  void play({bool loop = false, Function onEnd});

  /// Loops this sound indefinitely
  void loop() {
    play(loop: true);
  }

  /// Stops the audio immediately
  void stop();

}