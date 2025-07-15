import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/player_provider.dart';
import '../services/device_music_service.dart';
import '../models/track.dart';
import '../widgets/track_card.dart';

class OfflineMusicScreen extends StatefulWidget {
  const OfflineMusicScreen({super.key});

  @override
  State<OfflineMusicScreen> createState() => _OfflineMusicScreenState();
}

class _OfflineMusicScreenState extends State<OfflineMusicScreen> {
  Map<String, List<Track>> _musicByFolder = {};
  bool _loadingDeviceMusic = false;
  String? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _loadDeviceMusic();
  }

  Future<void> _loadDeviceMusic() async {
    setState(() => _loadingDeviceMusic = true);
    try {
      print('[OfflineMusicScreen] Starting device music scan...');
      List<Track> tracks;
      try {
        tracks = await DeviceMusicService.scanDeviceMusic(limit: 5000); // Large limit to get all
        print('[OfflineMusicScreen] Real device music scan completed, found \\${tracks.length} tracks');
      } catch (e) {
        print('[OfflineMusicScreen] Real device music not available, using mock: $e');
        tracks = await DeviceMusicService.scanDeviceMusic(limit: 5000);
      }
      // Group tracks by folder
      final Map<String, List<Track>> byFolder = {};
      for (final track in tracks) {
        final folder = _getFolderName(track.audioUrl);
        if (!byFolder.containsKey(folder)) {
          byFolder[folder] = [];
        }
        byFolder[folder]!.add(track);
      }
      setState(() => _musicByFolder = byFolder);
    } catch (e) {
      print('[OfflineMusicScreen] Error loading device music: $e');
    }
    setState(() => _loadingDeviceMusic = false);
  }

  String _getFolderName(String path) {
    final parts = path.split('/');
    if (parts.length > 1) {
      return parts.sublist(0, parts.length - 1).join('/');
    }
    return '/';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.backgroundGradient,
            ),
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: themeProvider.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Offline Music',
                      style: TextStyle(
                        color: themeProvider.textPrimaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: themeProvider.primaryGradient,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: themeProvider.textPrimaryColor,
                      ),
                      onPressed: _loadDeviceMusic,
                    ),
                  ],
                ),
                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_selectedFolder == null)
                        _buildFolderList(themeProvider)
                      else
                        _buildTrackList(themeProvider, _selectedFolder!),
                      const SizedBox(height: 100), // Bottom padding for mini player
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFolderList(ThemeProvider themeProvider) {
    if (_loadingDeviceMusic) {
      return Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: themeProvider.accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Scanning your device for music...',
              style: TextStyle(
                color: themeProvider.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    if (_musicByFolder.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.accentColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 48,
              color: themeProvider.textSecondaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              'No music found on device',
              style: TextStyle(
                color: themeProvider.textSecondaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _loadDeviceMusic,
                  child: const Text('Scan Again'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await DeviceMusicService.requestPermissions();
                      _loadDeviceMusic();
                    } catch (e) {
                      print('[OfflineMusicScreen] Error requesting permissions: $e');
                    }
                  },
                  child: const Text('Grant Permissions'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    final folders = _musicByFolder.keys.toList()..sort();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        final tracks = _musicByFolder[folder]!;
        return ListTile(
          leading: const Icon(Icons.folder, color: Colors.deepPurple),
          title: Text(
            folder.split('/').last,
            style: TextStyle(
              color: themeProvider.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('${tracks.length} tracks'),
          onTap: () {
            setState(() {
              _selectedFolder = folder;
            });
          },
        );
      },
    );
  }

  Widget _buildTrackList(ThemeProvider themeProvider, String folder) {
    final tracks = _musicByFolder[folder]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
              onPressed: () {
                setState(() {
                  _selectedFolder = null;
                });
              },
            ),
            Text(
              folder.split('/').last,
              style: TextStyle(
                color: themeProvider.textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text('(${tracks.length} tracks)',
                style: TextStyle(color: themeProvider.textSecondaryColor)),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return TrackCard(
              track: track,
              onTap: () {
                context.read<PlayerProvider>().playTrack(
                      track,
                      queue: tracks,
                      index: index,
                    );
              },
            );
          },
        ),
      ],
    );
  }
} 