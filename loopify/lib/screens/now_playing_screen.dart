import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:io';
import '../providers/player_provider.dart';
import '../providers/music_provider.dart';
import '../models/track.dart';
import '../widgets/track_card.dart';
import '../services/device_music_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  bool _showQueue = false;
  late AnimationController _particleController;
  late Animation<double> _albumArtScale;
  late Animation<double> _particleAnimation;
  
  // Cache for album art to prevent repeated extractions
  Map<String, String> _albumArtCache = {};
  String? _currentAlbumArtPath;

  // Loop/Shuffle modes
  final int _playbackMode =
      0; // 0: normal, 1: shuffle, 2: repeat one, 3: repeat all
  final List<Map<String, dynamic>> _playbackModes = [
    {'icon': Icons.repeat, 'name': 'Normal'},
    {'icon': Icons.shuffle, 'name': 'Shuffle'},
    {'icon': Icons.repeat_one, 'name': 'Repeat One'},
    {'icon': Icons.repeat, 'name': 'Repeat All'},
  ];

  final Map<String, Future<String>> _albumArtFutures = {};

  Future<String> _getAlbumArtFuture(Track track) {
    if (!_albumArtFutures.containsKey(track.audioUrl)) {
      _albumArtFutures[track.audioUrl] = DeviceMusicService.extractAlbumArt(track.audioUrl);
    }
    return _albumArtFutures[track.audioUrl]!;
  }

  Color? _dominantColor;

  // 1. Add state for drag offset and animation
  double _dragOffset = 0.0;
  bool _isDragging = false;
  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;
  String? _lastTrackId;

  // Album art cache to prevent flickering
  // final Map<String, String> _albumArtCache = {}; // This line is removed

  Future<String?> _getAlbumArt(track) async {
    if (!track.isLocal) return track.albumArt;
    if (_albumArtCache.containsKey(track.audioUrl)) {
      return _albumArtCache[track.audioUrl];
    }
    final path = await DeviceMusicService.extractAlbumArt(track.audioUrl);
    if (path != null && path.isNotEmpty) {
      _albumArtCache[track.audioUrl] = path;
      return path;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _albumArtScale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateDominantColor());
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeAnimation = Tween<double>(begin: 0, end: 0).animate(_swipeController)
      ..addListener(() {
        setState(() {
          _dragOffset = _swipeAnimation.value;
        });
      });
  }

  @override
  void didUpdateWidget(NowPlayingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDominantColor();
  }

  Future<void> _updateDominantColor() async {
    final playerProvider = context.read<PlayerProvider>();
    final track = playerProvider.currentTrack;
    if (track == null) return;
    String? albumArtPath;
    if (track.isLocal && track.audioUrl.isNotEmpty) {
      albumArtPath = await _getAlbumArtFuture(track);
    } else if (track.albumArt.isNotEmpty) {
      albumArtPath = track.albumArt;
    }
    if (albumArtPath != null && albumArtPath.isNotEmpty) {
      ImageProvider imageProvider;
      if (albumArtPath.startsWith('http')) {
        imageProvider = NetworkImage(albumArtPath);
      } else {
        imageProvider = FileImage(File(albumArtPath));
      }
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(200, 200),
        maximumColorCount: 8,
      );
      setState(() {
        _dominantColor = palette.dominantColor?.color ?? const Color(0xFF222222);
      });
    } else {
      setState(() {
        _dominantColor = const Color(0xFF222222);
      });
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _cyclePlaybackMode() {
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.cyclePlaybackMode();

    // Show toast with current mode
    final modeName = playerProvider.getPlaybackModeName();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playback mode: $modeName'),
        backgroundColor: const Color(0xFF1DB954),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showSongOptions(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.white),
              title: const Text('Add to Favorites',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showToast('Added to favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white),
              title: const Text('Add to Queue',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showToast('Added to queue');
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Add to Playlist',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showToast('Add to playlist feature coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showToast('Share feature coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('Song Info',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSongInfo(context, track);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSongInfo(BuildContext context, Track track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Song Info', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${track.title}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Artist: ${track.artist}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Album: ${track.album}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Duration: ${_formatDuration(track.duration)}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            // Remove 'Type: Online' display, only show local or nothing
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  // 1. Add the missing _showToast method
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1DB954),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 3. Add the build method and main UI logic (swipe, album art, controls, etc.)
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final track = playerProvider.currentTrack;
        final nextIndex = playerProvider.currentIndex + 1;
        final nextTrack = (nextIndex < playerProvider.queue.length)
            ? playerProvider.queue[nextIndex]
            : null;
        
        if (track == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Text('No track playing', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          );
        }

        // Load album art when track changes
        _loadAlbumArt(track);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Blurred background with album art
              _buildBlurredBackground(track),
              // Semi-transparent overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Modern header
                    Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
                          const SizedBox(width: 8),
              Expanded(
                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                const Text('Now Playing', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(
                      track.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () => _showSongOptions(context, track),
                          ),
                                      ],
                                    ),
                                  ),
                    // Centered album art - Bigger size
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: (track.isLocal && _currentAlbumArtPath != null)
                            ? Image.file(
                                File(_currentAlbumArtPath!),
                                width: 320,
                                height: 320,
                                fit: BoxFit.cover,
                              )
                            : (!track.isLocal && track.albumArt.isNotEmpty)
                                ? (track.albumArt.startsWith('http')
                                    ? Image.network(
                                        track.albumArt,
                                        width: 320,
                                        height: 320,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(track.albumArt),
                                        width: 320,
                                        height: 320,
                                        fit: BoxFit.cover,
                                      ))
                                : Container(
                                    width: 320,
                                    height: 320,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      Icons.music_note,
                                      size: 80,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    // Song info row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  track.artist,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.queue_music, color: Colors.white),
                            onPressed: () => setState(() => _showQueue = !_showQueue),
                          ),
                          IconButton(
                            icon: const Icon(Icons.playlist_add, color: Colors.white),
                            onPressed: () => _showToast('Add to playlist feature coming soon'),
                          ),
                        ],
                      ),
                    ),
                    // Thin progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Slider(
                        value: playerProvider.position.inSeconds.toDouble(),
                        min: 0,
                        max: playerProvider.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          playerProvider.seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white24,
                      ),
                    ),
                    // Playback controls
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.white),
                            onPressed: () => _showToast('Added to favorites'),
                          ),
                          IconButton(
                            icon: SvgPicture.asset('assets/icons/previous.svg', width: 32, height: 32, color: Colors.white),
                            onPressed: playerProvider.previousTrack,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                            ),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                playerProvider.isPlaying ? 'assets/icons/pause.svg' : 'assets/icons/play.svg',
                                width: 40, height: 40, color: _dominantColor ?? const Color(0xFF222222)),
                              onPressed: playerProvider.togglePlayPause,
                            ),
                          ),
                          IconButton(
                            icon: SvgPicture.asset('assets/icons/next.svg', width: 32, height: 32, color: Colors.white),
                            onPressed: playerProvider.nextTrack,
                          ),
                    IconButton(
                            icon: _getPlaybackModeIcon(),
                            onPressed: _cyclePlaybackMode,
                          ),
                        ],
                      ),
                    ),
                    // Queue button below controls - Removed
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 8),
                    //   child: IconButton(
                    //     icon: SvgPicture.asset('assets/icons/queue.svg', width: 28, height: 28, color: Colors.white),
                    //     onPressed: () => setState(() => _showQueue = !_showQueue),
                    //   ),
                    // ),
                    // Mini player/up next at the bottom
                    if (nextTrack != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                                                          child: (nextTrack.albumArt != null && nextTrack.albumArt.isNotEmpty)
                              ? (nextTrack.albumArt.startsWith('http')
                                  ? Image.network(
                                      nextTrack.albumArt,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(nextTrack.albumArt),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ))
                              : SizedBox.shrink(),
                            ),
                            title: Text(
                              nextTrack.title,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              nextTrack.artist,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => playerProvider.removeFromQueue(nextIndex),
                            ),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlurredBackground(Track track) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background album art (blurred)
          if (track.isLocal && _currentAlbumArtPath != null)
            Positioned.fill(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Image.file(
                    File(_currentAlbumArtPath!),
                    width: double.infinity,
                    height: double.infinity,
          fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else if (!track.isLocal && track.albumArt.isNotEmpty)
            Positioned.fill(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: track.albumArt.startsWith('http')
                      ? Image.network(
          track.albumArt,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(track.albumArt),
                          width: double.infinity,
                          height: double.infinity,
          fit: BoxFit.cover,
                        ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _dominantColor ?? const Color(0xFF222222),
                    _dominantColor ?? const Color(0xFF121212),
                  ],
                ),
              ),
            ),
          // Dark overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _albumArtScale.value,
          child: Transform.translate(
            offset: Offset(
              _particleAnimation.value * 100,
              _particleAnimation.value * 100,
            ),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
            colors: [
              _dominantColor ?? const Color(0xFF222222),
              _dominantColor ?? const Color(0xFF121212),
            ],
      ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final playerProvider = context.read<PlayerProvider>();
    final track = playerProvider.currentTrack;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            if (track != null) {
              _showSongOptions(context, track);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPlayerView() {
    final playerProvider = context.read<PlayerProvider>();
    if (playerProvider.currentTrack == null) {
      return const Center(
        child: Text('No track playing', style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }
    final Track track = playerProvider.currentTrack!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackCard(
            track: track,
            onTap: () {
              _showSongOptions(context, track);
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () {
                  playerProvider.previousTrack();
                },
              ),
              IconButton(
                icon: playerProvider.isPlaying
                    ? const Icon(Icons.pause_circle_filled, color: Colors.white, size: 60)
                    : const Icon(Icons.play_circle_filled, color: Colors.white, size: 60),
                onPressed: () {
                  playerProvider.togglePlayPause();
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {
                  playerProvider.nextTrack();
                },
                    ),
                  ],
                ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.shuffle, color: Colors.white),
                onPressed: () {
                  _cyclePlaybackMode();
                },
              ),
              IconButton(
                icon: const Icon(Icons.repeat, color: Colors.white),
                onPressed: () {
                  _cyclePlaybackMode();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueView() {
    final playerProvider = context.read<PlayerProvider>();
        final queue = playerProvider.queue;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Queue',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 24),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
          itemCount: queue.length,
          itemBuilder: (context, index) {
            final track = queue[index];
                return TrackCard(
                    track: track,
                    onTap: () {
                    playerProvider.playTrack(track);
                    _showQueue = false;
                    setState(() {});
                  },
                );
              },
                    ),
                  ),
                ],
              ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _loadAlbumArt(Track track) async {
    if (track.id == _lastTrackId) return; // Already loaded for this track
    
    _lastTrackId = track.id;
    
    if (!track.isLocal) {
      _currentAlbumArtPath = track.albumArt;
      return;
    }
    
    if (_albumArtCache.containsKey(track.audioUrl)) {
      _currentAlbumArtPath = _albumArtCache[track.audioUrl];
      return;
    }
    
    final path = await DeviceMusicService.extractAlbumArt(track.audioUrl);
    if (path != null && path.isNotEmpty) {
      _albumArtCache[track.audioUrl] = path;
      _currentAlbumArtPath = path;
    } else {
      _currentAlbumArtPath = null;
    }
  }

  Widget _getPlaybackModeIcon() {
    final playerProvider = context.read<PlayerProvider>();
    final playbackMode = playerProvider.playbackMode;
    
    switch (playbackMode) {
      case PlaybackMode.shuffle:
        return SvgPicture.asset('assets/icons/shuffle.svg', width: 28, height: 28, color: Colors.white);
      case PlaybackMode.repeatAll:
        return SvgPicture.asset('assets/icons/repeat.svg', width: 28, height: 28, color: Colors.white);
      case PlaybackMode.repeatOne:
        return Icon(Icons.repeat_one, color: Colors.white, size: 28);
      case PlaybackMode.off:
      default:
        return Icon(Icons.repeat, color: Colors.white.withOpacity(0.5), size: 28);
    }
  }
}