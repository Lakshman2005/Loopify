import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/music_provider.dart';
import '../models/track.dart';

class DeviceMusicService {
  static MethodChannel? _channel;

  // Initialize method channel
  static MethodChannel get _methodChannel {
    _channel ??= const MethodChannel('device_music_service');
    return _channel!;
  }

  // Common music directories to scan
  static const List<String> _musicDirectories = [
    '/storage/emulated/0/Music',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Downloads',
    '/storage/emulated/0/Audio',
    '/storage/emulated/0/DCIM',
    '/storage/emulated/0/Pictures',
    '/storage/emulated/0/Documents',
  ];

  // Supported audio formats
  static const List<String> _audioExtensions = [
    '.mp3',
    '.aac',
    '.wav',
    '.m4a',
    '.ogg',
    '.flac',
    '.wma'
  ];

  /// Request all necessary permissions for device music access
  static Future<bool> requestPermissions() async {
    try {
      // For Android 13+ (API 33+)
      if (Platform.isAndroid) {
        final androidInfo =
            await _methodChannel.invokeMethod('getAndroidVersion');
        final sdkVersion = androidInfo['sdkVersion'] as int? ?? 0;

        if (sdkVersion >= 33) {
          // Android 13+ uses READ_MEDIA_AUDIO
          final status = await Permission.audio.request();
          return status.isGranted;
        } else {
          // Android 12 and below use READ_EXTERNAL_STORAGE
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      }

      // For iOS
      if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.request();
        return status.isGranted;
      }

      return false;
    } catch (e) {
      print('[DeviceMusicService] Permission request error: $e');
      return false;
    }
  }

  /// Check if we have permission to access device music
  static Future<bool> hasPermission() async {
    try {
      print('[DeviceMusicService] Checking permission...');
      final bool hasPermission =
          await _methodChannel.invokeMethod('hasPermission') ?? false;
      print('[DeviceMusicService] Permission check result: $hasPermission');
      return hasPermission;
    } catch (e) {
      print('[DeviceMusicService] Permission check error: $e');
      // If there's an error, try to request permission
      try {
        print('[DeviceMusicService] Requesting permission...');
        await _methodChannel.invokeMethod('requestPermission');
        print('[DeviceMusicService] Permission request completed');
        return true; // Assume permission granted after request
      } catch (requestError) {
        print('[DeviceMusicService] Permission request error: $requestError');
        return false;
      }
    }
  }

  /// Extract album art from a local music file
  static Future<String> extractAlbumArt(String filePath) async {
    try {
      print('[DeviceMusicService] Extracting album art from: $filePath');
      final result = await _methodChannel
          .invokeMethod('extractAlbumArt', {'filePath': filePath});
      final albumArtPath = result['albumArtPath'] ?? '';
      print('[DeviceMusicService] Album art extraction result: ${albumArtPath.isNotEmpty ? "Success" : "No album art found"}');
      return albumArtPath;
    } catch (e) {
      print('[DeviceMusicService] Error extracting album art: $e');
      return '';
    }
  }

  /// Scan device for music files using MediaStore API
  static Future<List<Track>> scanDeviceMusic({int? limit}) async {
    try {
      print('[DeviceMusicService] Starting device music scan...');
      
      if (!await hasPermission()) {
        print('[DeviceMusicService] No permission to access device music');
        return [];
      }

      print('[DeviceMusicService] Permission granted, scanning MediaStore...');
      
      // Use MediaStore API to get all music files
      final List<dynamic> musicFiles =
          await _methodChannel.invokeMethod('scanMediaStore');
      
      print('[DeviceMusicService] MediaStore scan completed, found ${musicFiles.length} files');

      List<Track> tracks = [];
      int count = 0;

      for (var file in musicFiles) {
        try {
          // Apply limit if specified
          if (limit != null && count >= limit) break;

          final filePath = file['path'] ?? '';
          String albumArt = file['albumArt'] ?? '';
          final duration = file['duration'] ?? 0;

          // Debug duration values
          print(
              '[DeviceMusicService] Track: ${file['title']} - Duration: $duration ms');

          // For now, use empty string for album art to avoid UI hangs
          // We'll implement proper album art loading later
          albumArt = '';

          final track = Track(
            id: file['id'] ?? '',
            title: file['title'] ?? 'Unknown Title',
            artist: file['artist'] ?? 'Unknown Artist',
            album: file['album'] ?? 'Unknown Album',
            albumArt: albumArt,
            duration: Duration(milliseconds: duration),
            audioUrl: filePath,
            isLocal: true,
          );

          tracks.add(track);
          count++;
        } catch (e) {
          print('[DeviceMusicService] Error parsing track: $e');
        }
      }

      print(
          '[DeviceMusicService] Found ${tracks.length} music files on device');
      return tracks;
    } catch (e) {
      print('[DeviceMusicService] Error scanning device music: $e');
      return [];
    }
  }

  /// Get all directories that might contain music
  static Future<List<Directory>> getMusicDirectories() async {
    List<Directory> directories = [];

    try {
      // Add common music directories
      for (String path in _musicDirectories) {
        final dir = Directory(path);
        if (await dir.exists()) {
          directories.add(dir);
        }
      }

      // Add app-specific directories
      final appDir = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${appDir.path}/Music');
      if (await musicDir.exists()) {
        directories.add(musicDir);
      }

      // Add external storage directories if available
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final externalMusicDir = Directory('${externalDir.path}/Music');
        if (await externalMusicDir.exists()) {
          directories.add(externalMusicDir);
        }
      }
    } catch (e) {
      print('[DeviceMusicService] Error getting music directories: $e');
    }

    return directories;
  }

  /// Scan a specific directory for music files
  static Future<List<Track>> scanDirectory(Directory directory) async {
    List<Track> tracks = [];

    try {
      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File) {
          final extension = entity.path.split('.').last.toLowerCase();
          if (_audioExtensions.contains('.$extension')) {
            try {
              final stat = await entity.stat();
              // Get duration using native method
              int durationMs = 0;
              try {
                durationMs = await _methodChannel.invokeMethod(
                        'getAudioFileDuration', {'filePath': entity.path}) ??
                    0;
              } catch (e) {
                print(
                    '[DeviceMusicService] Error getting duration for ${entity.path}: $e');
              }
              final track = Track(
                id: entity.path,
                title:
                    entity.path.split('/').last.replaceAll('.$extension', ''),
                artist: 'Unknown Artist',
                album: 'Unknown Album',
                albumArt: '',
                duration: Duration(milliseconds: durationMs),
                audioUrl: entity.path,
                isLocal: true,
              );

              tracks.add(track);
            } catch (e) {
              print(
                  '[DeviceMusicService] Error processing file ${entity.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      print(
          '[DeviceMusicService] Error scanning directory ${directory.path}: $e');
    }

    return tracks;
  }

  /// Get storage usage information
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final tracks = await scanDeviceMusic();
      return {
        'totalTracks': tracks.length,
        'totalSize': 0, // File size calculation removed for now
        'formattedSize': 'N/A',
      };
    } catch (e) {
      print('[DeviceMusicService] Error getting storage info: $e');
      return {
        'totalTracks': 0,
        'totalSize': 0,
        'formattedSize': '0 MB',
      };
    }
  }

  /// Format file size in human readable format
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Refresh media store (useful after adding new files)
  static Future<void> refreshMediaStore() async {
    try {
      await _methodChannel.invokeMethod('refreshMediaStore');
      print('[DeviceMusicService] Media store refreshed');
    } catch (e) {
      print('[DeviceMusicService] Error refreshing media store: $e');
    }
  }
}
