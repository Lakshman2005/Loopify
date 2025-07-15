import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import '../services/audio_handler.dart';

class PlayerProvider with ChangeNotifier {
  final LoopifyAudioHandler _audioHandler;
  PlayerProvider(this._audioHandler) {
    // Listen to audio handler streams and notify listeners when they change
    _audioHandler.currentTrackStream.listen((track) {
      print('[PlayerProvider] Current track stream updated: ${track?.title}');
      notifyListeners();
    });
    
    _audioHandler.isPlayingStream.listen((isPlaying) {
      print('[PlayerProvider] Playing state stream updated: $isPlaying');
      notifyListeners();
    });
  }

  // Getters that delegate to audio handler
  Track? get currentTrack {
    final track = _audioHandler.currentTrack;
    print('[PlayerProvider] currentTrack getter called, returning: ${track?.title}');
    return track;
  }
  bool get isPlaying => _audioHandler.isPlaying;
  bool get isLoading => false; // Audio handler handles this internally
  List<Track> get queue => _audioHandler.tracks;
  int get currentIndex => _audioHandler.currentIndex;
  Duration get position => _audioHandler.position;
  Duration get duration => _audioHandler.duration;
  String? get errorMessage => null; // Audio handler handles errors internally
  bool get isShuffleEnabled => _audioHandler.shuffle;
  LoopMode get loopMode => _audioHandler.loopMode;

  // Streams for UI updates
  Stream<Track?> get currentTrackStream => _audioHandler.currentTrackStream;
  Stream<bool> get isPlayingStream => _audioHandler.isPlayingStream;
  Stream<Duration> get positionStream => _audioHandler.positionStream;
  Stream<Duration> get durationStream => _audioHandler.durationStream;

  Future<void> playTrack(Track track, {List<Track>? queue, int? index}) async {
    try {
      if (queue != null) {
        await _audioHandler.setTracks(queue, initialIndex: index ?? 0);
      } else {
        await _audioHandler.setTracks([track], initialIndex: 0);
      }
      notifyListeners();
    } catch (e) {
      print('Error playing track: $e');
    }
  }

  Future<void> play() async {
    await _audioHandler.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioHandler.pause();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_audioHandler.isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
    notifyListeners();
  }

  Future<void> nextTrack() async {
    await _audioHandler.skipToNext();
    notifyListeners();
  }

  Future<void> previousTrack() async {
    await _audioHandler.skipToPrevious();
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioHandler.seek(position);
    notifyListeners();
  }

  void updatePosition(Duration position) {
    // This is handled by the audio handler streams
    notifyListeners();
  }

  Future<void> clearQueue() async {
    await _audioHandler.setTracks([]);
    notifyListeners();
  }

  Future<void> setShuffleMode(bool enabled) async {
    await _audioHandler.setShuffleMode(
      enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
    notifyListeners();
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    AudioServiceRepeatMode audioServiceMode;
    switch (mode) {
      case RepeatMode.none:
        audioServiceMode = AudioServiceRepeatMode.none;
        break;
      case RepeatMode.all:
        audioServiceMode = AudioServiceRepeatMode.all;
        break;
      case RepeatMode.one:
        audioServiceMode = AudioServiceRepeatMode.one;
        break;
    }
    await _audioHandler.setRepeatMode(audioServiceMode);
    notifyListeners();
  }

  // Legacy methods for compatibility
  void toggleShuffle() {
    setShuffleMode(!isShuffleEnabled);
  }

  void toggleRepeat() {
    RepeatMode currentMode;
    switch (loopMode) {
      case LoopMode.off:
        currentMode = RepeatMode.all;
        break;
      case LoopMode.all:
        currentMode = RepeatMode.one;
        break;
      case LoopMode.one:
        currentMode = RepeatMode.none;
        break;
      default:
        currentMode = RepeatMode.none;
        break;
    }
    setRepeatMode(currentMode);
  }

  String getRepeatIcon() {
    return 'assets/icons/repeat.svg';
  }

  Color getRepeatIconColor() {
    switch (loopMode) {
      case LoopMode.off:
        return Colors.white.withOpacity(0.6);
      case LoopMode.all:
        return Colors.green;
      case LoopMode.one:
        return Colors.blue;
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  String getShuffleIcon() {
    return 'assets/icons/shuffle.svg';
  }

  Color getShuffleIconColor() {
    return isShuffleEnabled ? Colors.green : Colors.white.withOpacity(0.6);
  }

  // Playback mode methods for compatibility
  PlaybackMode get playbackMode {
    if (isShuffleEnabled) return PlaybackMode.shuffle;
    switch (loopMode) {
      case LoopMode.off:
        return PlaybackMode.off;
      case LoopMode.all:
        return PlaybackMode.repeatAll;
      case LoopMode.one:
        return PlaybackMode.repeatOne;
      default:
        return PlaybackMode.off;
    }
  }

  void cyclePlaybackMode() {
    switch (playbackMode) {
      case PlaybackMode.off:
        setShuffleMode(true);
        break;
      case PlaybackMode.shuffle:
        setShuffleMode(false);
        setRepeatMode(RepeatMode.all);
        break;
      case PlaybackMode.repeatAll:
        setRepeatMode(RepeatMode.one);
        break;
      case PlaybackMode.repeatOne:
        setRepeatMode(RepeatMode.none);
        break;
    }
  }

  String getPlaybackModeIcon() {
    switch (playbackMode) {
      case PlaybackMode.shuffle:
        return 'assets/icons/shuffle.svg';
      case PlaybackMode.repeatAll:
        return 'assets/icons/repeat.svg';
      case PlaybackMode.repeatOne:
        return 'assets/icons/repeat.svg';
      case PlaybackMode.off:
      default:
        return 'assets/icons/repeat.svg';
    }
  }

  Color getPlaybackModeIconColor() {
    switch (playbackMode) {
      case PlaybackMode.shuffle:
        return Colors.green;
      case PlaybackMode.repeatAll:
        return Colors.blue;
      case PlaybackMode.repeatOne:
        return Colors.orange;
      case PlaybackMode.off:
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  String getPlaybackModeName() {
    switch (playbackMode) {
      case PlaybackMode.shuffle:
        return 'Shuffle';
      case PlaybackMode.repeatAll:
        return 'Repeat All';
      case PlaybackMode.repeatOne:
        return 'Repeat One';
      case PlaybackMode.off:
      default:
        return 'Off';
    }
  }

  bool get isRepeatOne => loopMode == LoopMode.one;
  bool get isShuffle => isShuffleEnabled;
  bool get isRepeatAll => loopMode == LoopMode.all;

  void seek(Duration position) {
    seekTo(position);
  }

  void addToQueue(Track track) {
    final currentTracks = List<Track>.from(queue);
    currentTracks.add(track);
    _audioHandler.setTracks(currentTracks);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < queue.length) {
      final currentTracks = List<Track>.from(queue);
      currentTracks.removeAt(index);
      _audioHandler.setTracks(currentTracks);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioHandler.dispose();
    super.dispose();
  }
}

// Enums for compatibility
enum RepeatMode {
  none,
  all,
  one,
}

enum PlaybackMode {
  off,
  shuffle,
  repeatAll,
  repeatOne,
}
