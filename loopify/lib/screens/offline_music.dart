import 'package:flutter/material.dart';
import 'package:loopify/widgets/sidebar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../providers/theme_provider.dart';

class OfflineMusicScreen extends StatefulWidget {
  const OfflineMusicScreen({super.key});

  @override
  State<OfflineMusicScreen> createState() => _OfflineMusicScreenState();
}

class _OfflineMusicScreenState extends State<OfflineMusicScreen> {
  String? _pickedFolder;
  String? _folderName;
  List<FileSystemEntity> _audioFiles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentSong;
  bool _isPlaying = false;
  bool _hasPermission = false;
  String _debugMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
        setState(() {
          _hasPermission = false;
        });
      } else {
        setState(() {
          _hasPermission = status.isGranted;
        });
      }
    } else {
      setState(() {
        _hasPermission = true; // iOS handles permissions differently
      });
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      final result = await Permission.storage.request();
      setState(() {
        _hasPermission = result.isGranted;
      });
      if (result.isGranted) {
        _showDebug('Permission granted!');
      } else {
        _showDebug('Storage permission is required to access your music files.');
      }
    }
  }

  void _showDebug(String msg) {
    setState(() {
      _debugMessage = msg;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ThemeProvider.accentAqua),
    );
  }

  Future<void> _pickFolder() async {
    if (!_hasPermission) {
      await _requestPermission();
      return;
    }
    try {
      final String? directoryPath = await getDirectoryPath(
        initialDirectory: Platform.isAndroid ? '/storage/emulated/0' : null,
      );
      if (directoryPath != null) {
        final dir = Directory(directoryPath);
        if (await dir.exists()) {
          final files = await dir.list().toList();
          final audioFiles = files.where((f) {
            if (f is File) {
              final ext = f.path.split('.').last.toLowerCase();
              return ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'].contains(ext);
            }
            return false;
          }).toList();
          final pathParts = directoryPath.split(Platform.pathSeparator);
          final folderName = pathParts.last.isEmpty ? pathParts[pathParts.length - 2] : pathParts.last;
          setState(() {
            _pickedFolder = directoryPath;
            _folderName = folderName;
            _audioFiles = audioFiles;
          });
          if (audioFiles.isEmpty) {
            _showDebug('No audio files found in this folder.');
          } else {
            _showDebug('Found ${audioFiles.length} audio files in "$folderName"');
          }
        } else {
          _showDebug('Directory does not exist.');
        }
      } else {
        _showDebug('No folder selected.');
      }
    } catch (e) {
      _showDebug('Error accessing folder: $e');
    }
  }

  Future<void> _playSong(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
      setState(() {
        _currentSong = path;
        _isPlaying = true;
      });
      _showDebug('Playing: ${_getFileName(path)}');
    } catch (e) {
      _showDebug('Error playing file: $e');
    }
  }

  Future<void> _pauseSong() async {
    try {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
      _showDebug('Paused');
    } catch (e) {
      _showDebug('Error pausing: $e');
    }
  }

  String _getFileName(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    return fileName.replaceAll(RegExp(r'\.(mp3|wav|aac|m4a|flac|ogg)$', caseSensitive: false), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.backgroundNavy,
      appBar: AppBar(
        title: const Text('Offline Music'),
        backgroundColor: ThemeProvider.backgroundNavy,
        foregroundColor: ThemeProvider.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: ThemeProvider.accentAqua),
            onPressed: () => _showDebug(_debugMessage.isEmpty ? 'No debug info.' : _debugMessage),
            tooltip: 'Show Debug Info',
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: ThemeProvider.primaryPurple),
            onPressed: () => _showDebug('Test: Permission=$_hasPermission, Folder=$_pickedFolder, Files=${_audioFiles.length}'),
            tooltip: 'Test Offline',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_hasPermission) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Storage Permission Required',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Grant permission to access your music folders',
                            style: TextStyle(color: ThemeProvider.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _requestPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Grant Permission'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_special_rounded),
              label: Text(_pickedFolder == null ? 'Pick Music Folder' : 'Change Folder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeProvider.primaryPurple,
                foregroundColor: ThemeProvider.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              onPressed: _hasPermission ? _pickFolder : _requestPermission,
            ),
            if (_pickedFolder != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ThemeProvider.surfaceCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeProvider.primaryPurple.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeProvider.accentAqua.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.folder, color: ThemeProvider.accentAqua, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _folderName ?? 'Music Folder',
                            style: const TextStyle(color: ThemeProvider.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_audioFiles.length} songs',
                            style: const TextStyle(color: ThemeProvider.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              _pickedFolder == null ? 'Pick a folder to see your music files.' : 'Songs in this folder:',
              style: const TextStyle(color: ThemeProvider.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _pickedFolder == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open, size: 64, color: ThemeProvider.textSecondary),
                          const SizedBox(height: 16),
                          const Text('No folder selected.',
                              style: TextStyle(color: ThemeProvider.textSecondary, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Use the button above to select a folder containing your music.',
                              style: TextStyle(color: ThemeProvider.textSecondary.withOpacity(0.7), fontSize: 14),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : _audioFiles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_off, size: 64, color: ThemeProvider.textSecondary),
                              const SizedBox(height: 16),
                              const Text('No audio files found in this folder.',
                                  style: TextStyle(color: ThemeProvider.textSecondary, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text('Make sure the folder contains MP3, WAV, AAC, M4A, FLAC, or OGG files.',
                                  style: TextStyle(color: ThemeProvider.textSecondary.withOpacity(0.7), fontSize: 14),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _audioFiles.length,
                          itemBuilder: (context, index) {
                            final file = _audioFiles[index];
                            final path = file.path;
                            final isCurrent = path == _currentSong;
                            final fileName = _getFileName(path);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isCurrent ? ThemeProvider.primaryPurple.withOpacity(0.3) : ThemeProvider.surfaceCharcoal,
                                borderRadius: BorderRadius.circular(12),
                                border: isCurrent ? Border.all(color: ThemeProvider.accentAqua, width: 2) : null,
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        ThemeProvider.primaryPurple,
                                        ThemeProvider.accentAqua,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.music_note, color: ThemeProvider.textPrimary, size: 24),
                                ),
                                title: Text(fileName,
                                    style: const TextStyle(color: ThemeProvider.textPrimary, fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                  isCurrent && _isPlaying ? 'Now Playing' : 'Tap to play',
                                  style: const TextStyle(color: ThemeProvider.textSecondary, fontSize: 12)
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isCurrent && _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                    color: ThemeProvider.accentAqua,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    if (isCurrent && _isPlaying) {
                                      _pauseSong();
                                    } else {
                                      _playSong(path);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
} 