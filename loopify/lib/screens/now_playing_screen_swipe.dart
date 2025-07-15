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
  static final Map<String, String> _albumArtCache = {};

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
            Text('Title: 24{track.title}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Artist: 24{track.artist}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Album: 24{track.album}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Duration: 24{_formatDuration(track.duration)}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            // Remove 'Type: Online' display, only show local or nothing
          ],
        ),
``` 