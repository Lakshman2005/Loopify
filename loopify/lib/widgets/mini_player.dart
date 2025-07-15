import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/player_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/now_playing_screen.dart';
import '../services/device_music_service.dart';
import '../models/track.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final Map<String, Future<String>> _albumArtFutures = {};

  Future<String> _getAlbumArtFuture(Track track) {
    if (!_albumArtFutures.containsKey(track.audioUrl)) {
      _albumArtFutures[track.audioUrl] = DeviceMusicService.extractAlbumArt(track.audioUrl);
    }
    return _albumArtFutures[track.audioUrl]!;
  }

  Widget buildTrackAlbumArt(Track track, {double size = 54}) {
    print('[MiniPlayer] Building album art for track: ${track.title}');
    print('[MiniPlayer] Track audioUrl: ${track.audioUrl}');
    print('[MiniPlayer] Track isLocal: ${track.isLocal}');
    
    // For local tracks, use FutureBuilder to extract album art
    if (track.isLocal && track.audioUrl.isNotEmpty) {
      return FutureBuilder<String>(
        key: ValueKey(track.audioUrl),
        future: _getAlbumArtFuture(track),
        builder: (context, snapshot) {
          print('[MiniPlayer] FutureBuilder state: ${snapshot.connectionState}');
          print('[MiniPlayer] FutureBuilder hasData: ${snapshot.hasData}');
          print('[MiniPlayer] FutureBuilder data: ${snapshot.data}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _albumArtPlaceholder(size);
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final filePath = snapshot.data!;
            final file = File(filePath);
            if (file.existsSync()) {
              return AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            }
          }
          return _albumArtPlaceholder(size);
        },
      );
    }
    
    // For network tracks, use network image
    if (track.albumArt.isNotEmpty && track.albumArt.startsWith('http')) {
      return Image.network(
        track.albumArt,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _albumArtPlaceholder(size);
        },
      );
    }
    
    // For local album art files
    if (track.albumArt.isNotEmpty && (track.albumArt.startsWith('/') || track.albumArt.startsWith('file://'))) {
      final filePath = track.albumArt.replaceFirst('file://', '');
      final file = File(filePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _albumArtPlaceholder(size);
          },
        );
      }
    }
    
    return _albumArtPlaceholder(size);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerProvider, ThemeProvider>(
      builder: (context, playerProvider, themeProvider, child) {
        final track = playerProvider.currentTrack;
        if (track == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NowPlayingScreen(),
              ),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  themeProvider.surfaceColor,
                  themeProvider.primaryColor.withValues(alpha: 0.3),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: themeProvider.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.accentColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: buildTrackAlbumArt(track, size: 54),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Track Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          track.title,
                          style: TextStyle(
                            color: themeProvider.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.artist,
                          style: TextStyle(
                            color: themeProvider.textSecondaryColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          playerProvider.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: themeProvider.accentColor,
                          size: 28,
                        ),
                        onPressed: () {
                          playerProvider.togglePlayPause();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: themeProvider.accentColor,
                          size: 24,
                        ),
                        onPressed: () {
                          playerProvider.nextTrack();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(dynamic track) {
    // Handle local album art files (extracted album art)
    if (track.albumArt.isNotEmpty && (track.albumArt.startsWith('/') || track.albumArt.startsWith('file://'))) {
      final filePath = track.albumArt.replaceFirst('file://', '');
      final file = File(filePath);
      debugPrint('[MiniPlayer] Using albumArt path: $filePath, exists: ${file.existsSync()}');
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      }
    }
    // Handle network images
    if (track.albumArt.isNotEmpty && track.albumArt.startsWith('http')) {
      debugPrint('[MiniPlayer] Using albumArt network URL: ${track.albumArt}');
      return Image.network(
        track.albumArt,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    // For local music files without album art, try to extract it
    if (track.isLocal && track.audioUrl.isNotEmpty) {
      return FutureBuilder<String>(
        key: ValueKey(track.audioUrl),
        future: _extractAlbumArt(track.audioUrl),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final file = File(snapshot.data!);
            debugPrint('[MiniPlayer] Extracted album art path: ${snapshot.data}, exists: ${file.existsSync()}');
            if (file.existsSync()) {
              return Image.file(
                file,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              );
            }
          }
          return _buildPlaceholder();
        },
      );
    }
    // Show placeholder for content:// URIs or empty album art
    return _buildPlaceholder();
  }

  Future<String> _extractAlbumArt(String audioUrl) async {
    try {
      return await DeviceMusicService.extractAlbumArt(audioUrl);
    } catch (e) {
      return '';
    }
  }

  Widget _buildPlaceholder() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: themeProvider.primaryGradient,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.music_note,
            color: themeProvider.textPrimaryColor,
            size: 24,
          ),
        );
      },
    );
  }
}

Widget _albumArtPlaceholder(double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue.shade300,
          Colors.purple.shade300,
        ],
      ),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Icon(
      Icons.music_note,
      color: Colors.white,
      size: size * 0.4,
    ),
  );
}
