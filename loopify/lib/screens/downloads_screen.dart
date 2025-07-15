import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../providers/theme_provider.dart';
import '../services/device_music_service.dart';
import '../models/track.dart';
import '../widgets/track_card.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  _DownloadsScreenState createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<Directory> deviceFolders = [];
  List<Track> downloadedTracks = [];
  bool isLoading = true;
  bool isOfflineMode = false;
  Map<String, dynamic> storageInfo = {};
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeDeviceMusic();
  }

  Future<void> _initializeDeviceMusic() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Request permissions automatically
      final hasPermission = await DeviceMusicService.requestPermissions();

      if (hasPermission) {
        // Use compute to scan device music on background thread
        final result = await compute(_scanDeviceMusic, null);

        setState(() {
          downloadedTracks = result['tracks'] ?? [];
          deviceFolders = result['directories'] ?? [];
          storageInfo = result['storageInfo'] ?? {};
          isLoading = false;
        });

        print(
            '[DownloadsScreen] Found ${downloadedTracks.length} tracks and ${deviceFolders.length} directories');
      } else {
        setState(() {
          errorMessage =
              'Storage permission denied. Please grant permission to access device music.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error accessing device music: $e';
        isLoading = false;
      });
      print('[DownloadsScreen] Error: $e');
    }
  }

  // Static method for compute
  static Future<Map<String, dynamic>> _scanDeviceMusic(dynamic _) async {
    try {
      // Scan device music using MediaStore API - limit to first 50 tracks for performance
      final tracks = await DeviceMusicService.scanDeviceMusic(limit: 50);

      // Get music directories for folder browsing
      final directories = await DeviceMusicService.getMusicDirectories();

      // Get storage information
      final info = await DeviceMusicService.getStorageInfo();

      return {
        'tracks': tracks,
        'directories': directories,
        'storageInfo': info,
      };
    } catch (e) {
      print('[DownloadsScreen] Error in background scan: $e');
      return {
        'tracks': [],
        'directories': [],
        'storageInfo': {},
      };
    }
  }

  Future<void> _refreshMusic() async {
    await _initializeDeviceMusic();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Music library refreshed')),
    );
  }

  void _toggleOfflineMode() {
    setState(() {
      isOfflineMode = !isOfflineMode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            isOfflineMode ? 'Offline mode enabled' : 'Offline mode disabled'),
        backgroundColor: isOfflineMode ? Colors.orange : Colors.green,
      ),
    );
  }

  Future<void> _playTrack(Track track) async {
    try {
      final playerProvider =
          Provider.of<PlayerProvider>(context, listen: false);

      // Ensure the track has a valid file path
      if (track.audioUrl.isNotEmpty && track.audioUrl.startsWith('/')) {
        await playerProvider.playTrack(track);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing: ${track.title}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Invalid file path'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('[DownloadsScreen] Play error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing track: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _browseFolder(Directory directory) async {
    try {
      final tracks = await DeviceMusicService.scanDirectory(directory);

      if (tracks.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderTracksScreen(
              folderName: directory.path.split('/').last,
              tracks: tracks,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No music files found in this folder')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error browsing folder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.backgroundNavy,
      appBar: AppBar(
        title: const Text(
          'Downloads',
          style: TextStyle(
            color: ThemeProvider.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeProvider.backgroundNavy,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: ThemeProvider.textPrimary),
            onPressed: _refreshMusic,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ThemeProvider.accentAqua),
                  SizedBox(height: 16),
                  Text(
                    'Scanning device music...',
                    style: TextStyle(color: ThemeProvider.textSecondary),
                  ),
                ],
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: ThemeProvider.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style:
                            const TextStyle(color: ThemeProvider.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeDeviceMusic,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.accentAqua,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Offline Mode Toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ThemeProvider.surfaceCharcoal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isOfflineMode ? Icons.cloud_off : Icons.cloud,
                              color: isOfflineMode
                                  ? Colors.orange
                                  : ThemeProvider.accentAqua,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Offline Mode',
                                    style: TextStyle(
                                      color: ThemeProvider.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isOfflineMode
                                        ? 'Only showing downloaded music'
                                        : 'Showing all device music',
                                    style: const TextStyle(
                                        color: ThemeProvider.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isOfflineMode,
                              onChanged: (value) => _toggleOfflineMode(),
                              activeColor: ThemeProvider.accentAqua,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Storage Information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ThemeProvider.surfaceCharcoal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.storage,
                              color: ThemeProvider.accentAqua,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Storage Usage',
                                    style: TextStyle(
                                      color: ThemeProvider.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${storageInfo['totalTracks']} tracks • ${storageInfo['formattedSize']}',
                                    style: const TextStyle(
                                        color: ThemeProvider.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Device Music Tracks
                      if (downloadedTracks.isNotEmpty) ...[
                        Text(
                          'Device Music (${downloadedTracks.length})',
                          style: const TextStyle(
                            color: ThemeProvider.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: downloadedTracks.length,
                          itemBuilder: (context, index) {
                            final track = downloadedTracks[index];
                            return TrackCard(
                              track: track,
                              onTap: () => _playTrack(track),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Music Folders
                      Text(
                        'Music Folders (${deviceFolders.length})',
                        style: const TextStyle(
                          color: ThemeProvider.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: deviceFolders.length,
                        itemBuilder: (context, index) {
                          final folder = deviceFolders[index];
                          final folderName = folder.path.split('/').last;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: ThemeProvider.surfaceCharcoal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      ThemeProvider.accentAqua.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.folder,
                                  color: ThemeProvider.accentAqua,
                                ),
                              ),
                              title: Text(
                                folderName,
                                style: const TextStyle(
                                  color: ThemeProvider.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                folder.path,
                                style: const TextStyle(
                                    color: ThemeProvider.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    color: ThemeProvider.textSecondary),
                                onPressed: () => _browseFolder(folder),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}

class FolderTracksScreen extends StatelessWidget {
  final String folderName;
  final List<Track> tracks;

  const FolderTracksScreen(
      {super.key, required this.folderName, required this.tracks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.backgroundNavy,
      appBar: AppBar(
        title: Text(
          folderName,
          style: const TextStyle(
            color: ThemeProvider.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeProvider.backgroundNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeProvider.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return TrackCard(
            track: track,
            onTap: () async {
              try {
                final playerProvider =
                    Provider.of<PlayerProvider>(context, listen: false);
                await playerProvider.playTrack(track,
                    queue: tracks, index: index);

                // Show success message only if the widget is still mounted
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Playing: ${track.title}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print('[FolderTracksScreen] Error playing track: $e');
                // Show error message only if the widget is still mounted
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error playing track: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
