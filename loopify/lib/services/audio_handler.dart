import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loopify/models/track.dart';

class LoopifyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  static const _name = "Loopify";
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  
  // Track management
  List<Track> _tracks = [];
  int _currentIndex = 0;
  bool _shuffle = false;
  LoopMode _loopMode = LoopMode.off;
  
  // Stream controllers for UI updates
  final StreamController<Track?> _currentTrackController = StreamController<Track?>.broadcast();
  final StreamController<bool> _isPlayingController = StreamController<bool>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  
  LoopifyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentAudioIndexChanges();
    _listenForSequenceStateChanges();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    _currentIndex = index;
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    if (_tracks.isEmpty) return;
    
    if (_shuffle) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _tracks.length;
    }
    
    await _player.seek(Duration.zero, index: _currentIndex);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_tracks.isEmpty) return;
    
    if (_shuffle) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = _currentIndex > 0 ? _currentIndex - 1 : _tracks.length - 1;
    }
    
    await _player.seek(Duration.zero, index: _currentIndex);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _shuffle = shuffleMode == AudioServiceShuffleMode.all;
    await super.setShuffleMode(shuffleMode);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _loopMode = LoopMode.off;
        break;
      case AudioServiceRepeatMode.one:
        _loopMode = LoopMode.one;
        break;
      case AudioServiceRepeatMode.all:
        _loopMode = LoopMode.all;
        break;
      case AudioServiceRepeatMode.group:
        _loopMode = LoopMode.all;
        break;
    }
    await _player.setLoopMode(_loopMode);
    await super.setRepeatMode(repeatMode);
  }

  // Custom methods for track management
  Future<void> setTracks(List<Track> tracks, {int initialIndex = 0}) async {
    _tracks = tracks;
    _currentIndex = initialIndex.clamp(0, tracks.length - 1);
    
    // Clear and rebuild playlist
    await _playlist.clear();
    for (final track in tracks) {
      AudioSource audioSource;
      if (track.isLocal && track.audioUrl.startsWith('/')) {
        // Local file
        audioSource = AudioSource.file(track.audioUrl);
      } else if (track.audioUrl.startsWith('http')) {
        // Online URL
        audioSource = AudioSource.uri(Uri.parse(track.audioUrl));
      } else {
        // Fallback to URI
        audioSource = AudioSource.uri(Uri.parse(track.audioUrl));
      }
      
      await _playlist.add(audioSource);
    }
    
    // Update queue with MediaItems
    final mediaItems = tracks.map((track) => MediaItem(
      id: track.audioUrl,
      album: track.album,
      title: track.title,
      artist: track.artist,
      duration: track.duration,
      artUri: track.albumArt.isNotEmpty ? Uri.parse(track.albumArt) : null,
    )).toList();
    queue.add(mediaItems);
    
    // Start playing if tracks are available
    if (tracks.isNotEmpty) {
      await _player.seek(Duration.zero, index: _currentIndex);
      await play();
    }
    
    final currentTrack = _getCurrentTrack();
    _currentTrackController.add(currentTrack);
  }

  Track? _getCurrentTrack() {
    if (_tracks.isEmpty || _currentIndex >= _tracks.length) return null;
    return _tracks[_currentIndex];
  }

  int _getRandomIndex() {
    if (_tracks.length <= 1) return 0;
    int newIndex;
    do {
      newIndex = (DateTime.now().millisecondsSinceEpoch % _tracks.length).toInt();
    } while (newIndex == _currentIndex && _tracks.length > 1);
    return newIndex;
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
      
      _isPlayingController.add(playing);
      _positionController.add(_player.position);
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value.toList();
      if (index != null && newQueue.isNotEmpty) {
        if (duration != null) {
          newQueue[index] = newQueue[index].copyWith(duration: duration);
          queue.add(newQueue);
        }
        _durationController.add(duration ?? Duration.zero);
      }
    });
  }

  void _listenForCurrentAudioIndexChanges() {
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _currentIndex = index;
        final currentTrack = _getCurrentTrack();
        _currentTrackController.add(currentTrack);
      }
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final metadata = sequence
          .where((source) => source.tag != null)
          .map((source) => source.tag as MediaItem)
          .toList();
      queue.add(metadata);
    });
  }

  void _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  // Getters for UI
  Stream<Track?> get currentTrackStream => _currentTrackController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  
  Track? get currentTrack => _getCurrentTrack();
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  List<Track> get tracks => _tracks;
  int get currentIndex => _currentIndex;
  bool get shuffle => _shuffle;
  LoopMode get loopMode => _loopMode;

  @override
  Future<void> dispose() async {
    await _player.dispose();
    await _currentTrackController.close();
    await _isPlayingController.close();
    await _positionController.close();
    await _durationController.close();
  }
} 