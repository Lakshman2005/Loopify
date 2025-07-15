import 'dart:async';
import 'dart:math';
import '../models/track.dart';

class MockAudioService {
  static MockAudioService? _instance;
  static MockAudioService get instance => _instance ??= MockAudioService._();
  MockAudioService._();

  Timer? _progressTimer;
  bool _isPlaying = false;
  Track? _currentTrack;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;

  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<Track?> _trackController =
      StreamController<Track?>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  // Streams
  Stream<bool> get isPlayingStream => _playingController.stream;
  Stream<Track?> get currentTrackStream => _trackController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  // Getters
  bool get isPlaying => _isPlaying;
  Track? get currentTrack => _currentTrack;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;

  /// Load and play a track
  Future<void> playTrack(Track track) async {
    print('[MockAudioService] Loading track: ${track.title}');

    // Stop current track if playing
    if (_isPlaying) {
      await stop();
    }

    _currentTrack = track;
    _currentPosition = Duration.zero;
    _totalDuration = track.duration;

    // Notify listeners
    _trackController.add(_currentTrack);
    _durationController.add(_totalDuration);
    _positionController.add(_currentPosition);

    // Start playing
    await play();
  }

  /// Play current track
  Future<void> play() async {
    if (_currentTrack == null) return;

    print('[MockAudioService] Playing: ${_currentTrack!.title}');
    _isPlaying = true;
    _playingController.add(_isPlaying);

    // Start progress timer
    _startProgressTimer();
  }

  /// Pause current track
  Future<void> pause() async {
    print('[MockAudioService] Pausing playback');
    _isPlaying = false;
    _playingController.add(_isPlaying);
    _progressTimer?.cancel();
  }

  /// Stop current track
  Future<void> stop() async {
    print('[MockAudioService] Stopping playback');
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _progressTimer?.cancel();

    _playingController.add(_isPlaying);
    _positionController.add(_currentPosition);
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    if (_currentTrack == null) return;

    _currentPosition = position;
    if (_currentPosition > _totalDuration) {
      _currentPosition = _totalDuration;
    }

    _positionController.add(_currentPosition);
    print(
        '[MockAudioService] Seeking to: ${_formatDuration(_currentPosition)}');
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    print('[MockAudioService] Volume set to: ${(_volume * 100).toInt()}%');
  }

  /// Skip to next track (placeholder)
  Future<void> skipNext() async {
    print('[MockAudioService] Skip next requested');
    // This would be handled by the PlayerProvider with queue management
  }

  /// Skip to previous track (placeholder)
  Future<void> skipPrevious() async {
    print('[MockAudioService] Skip previous requested');
    // This would be handled by the PlayerProvider with queue management
  }

  /// Start progress timer to simulate playback
  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }

      _currentPosition = Duration(seconds: _currentPosition.inSeconds + 1);

      // Check if track finished
      if (_currentPosition >= _totalDuration) {
        timer.cancel();
        _isPlaying = false;
        _currentPosition = _totalDuration;
        _playingController.add(_isPlaying);
        print('[MockAudioService] Track finished: ${_currentTrack?.title}');
        // Notify track finished (would trigger next track in real implementation)
      }

      _positionController.add(_currentPosition);
    });
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Dispose resources
  void dispose() {
    _progressTimer?.cancel();
    _playingController.close();
    _trackController.close();
    _positionController.close();
    _durationController.close();
  }
}

/// Extension to add random durations to tracks
extension TrackDuration on Track {
  Duration get randomDuration {
    final random = Random();
    final minutes = random.nextInt(4) + 2; // 2-5 minutes
    final seconds = random.nextInt(60);
    return Duration(minutes: minutes, seconds: seconds);
  }
}
