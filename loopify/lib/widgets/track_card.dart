import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/player_provider.dart';
import '../models/track.dart';
import '../services/device_music_service.dart';

class TrackCard extends StatefulWidget {
  final Track track;
  final VoidCallback onTap;

  const TrackCard({
    Key? key,
    required this.track,
    required this.onTap,
  }) : super(key: key);

  @override
  State<TrackCard> createState() => _TrackCardState();
}

class _TrackCardState extends State<TrackCard> {
  String? _albumArtPath;
  bool _isLoadingAlbumArt = false;

  @override
  void initState() {
    super.initState();
    _loadAlbumArt();
  }

  Future<void> _loadAlbumArt() async {
    if (widget.track.isLocal &&
        widget.track.audioUrl.isNotEmpty &&
        !_isLoadingAlbumArt) {
      setState(() {
        _isLoadingAlbumArt = true;
      });

      try {
        final albumArtPath =
            await DeviceMusicService.extractAlbumArt(widget.track.audioUrl);
        if (mounted && albumArtPath.isNotEmpty) {
          setState(() {
            _albumArtPath = albumArtPath;
            _isLoadingAlbumArt = false;
          });
        } else {
          setState(() {
            _isLoadingAlbumArt = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingAlbumArt = false;
          });
        }
      }
    }
  }

  Widget _buildAlbumArtWidget(Track track) {
    // If we have a local album art path, use it
    if (_albumArtPath != null && _albumArtPath!.isNotEmpty) {
      return Image.file(
        File(_albumArtPath!),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    // If we have network album art, use it
    if (track.albumArt.isNotEmpty && !track.albumArt.startsWith('content://')) {
      if (track.albumArt.startsWith('/') ||
          track.albumArt.startsWith('file://')) {
        return Image.file(
          File(track.albumArt.replaceFirst('file://', '')),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      } else {
        return Image.network(
          track.albumArt,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      }
    }

    // Show loading indicator while extracting album art
    if (_isLoadingAlbumArt) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    // Show placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.music_note, color: Colors.white),
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
              leading: const Icon(Icons.queue_music, color: Colors.white),
              title: const Text('Add to Queue',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                final playerProvider =
                    Provider.of<PlayerProvider>(context, listen: false);
                playerProvider.addToQueue(track);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Added to queue'),
                      backgroundColor: Color(0xFF1DB954)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Add to Playlist',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Add to playlist feature coming soon'),
                      backgroundColor: Color(0xFF1DB954)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Share feature coming soon'),
                      backgroundColor: Color(0xFF1DB954)),
                );
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
            Text('Title: ${track.title}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Artist: ${track.artist}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Album: ${track.album}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Duration: ${_formatDuration(track.duration)}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            // Remove 'Type: Online' display, only show local or nothing
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Close', style: TextStyle(color: Color(0xFF1DB954))),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final isPlaying = playerProvider.isPlaying &&
            playerProvider.currentTrack?.id == widget.track.id;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _buildAlbumArtWidget(widget.track),
                ),
                if (isPlaying)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: PlayingBarsAnimation(),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.track.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPlaying)
                  const Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Icon(Icons.equalizer,
                        color: Color(0xFF00F5D4), size: 18),
                  ),
              ],
            ),
            subtitle: Text(
              widget.track.artist,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Three dots menu
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: Colors.grey.shade400, size: 20),
                  onPressed: () => _showSongOptions(context, widget.track),
                ),
              ],
            ),
            onTap: widget.onTap,
          ),
        );
      },
    );
  }
}

class PlayingBarsAnimation extends StatefulWidget {
  const PlayingBarsAnimation({super.key});

  @override
  _PlayingBarsAnimationState createState() => _PlayingBarsAnimationState();
}

class _PlayingBarsAnimationState extends State<PlayingBarsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bar1, _bar2, _bar3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _bar1 = Tween<double>(begin: 10, end: 24)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _bar2 = Tween<double>(begin: 18, end: 32).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
    _bar3 = Tween<double>(begin: 14, end: 28).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  width: 3,
                  height: _bar1.value,
                  color: const Color(0xFF00F5D4)),
              const SizedBox(width: 2),
              Container(
                  width: 3,
                  height: _bar2.value,
                  color: const Color(0xFF00F5D4)),
              const SizedBox(width: 2),
              Container(
                  width: 3,
                  height: _bar3.value,
                  color: const Color(0xFF00F5D4)),
            ],
          );
        },
      ),
    );
  }
}
