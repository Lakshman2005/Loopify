import 'dart:math';
import '../models/track.dart';

class MockDeviceMusicService {
  static final Random _random = Random();

  // Mock local music files that would typically be found on a device
  static final List<Map<String, String>> _mockLocalTracks = [
    {
      'title': 'Midnight Drive',
      'artist': 'Local Artist',
      'album': 'Night Sessions',
      'path': 'assets/audio/sample1.mp3',
      'image': 'https://picsum.photos/300/300?random=1',
    },
    {
      'title': 'Coffee Shop Blues',
      'artist': 'Indie Band',
      'album': 'Acoustic Collection',
      'path': 'assets/audio/sample2.mp3',
      'image': 'https://picsum.photos/300/300?random=2',
    },
    {
      'title': 'Digital Dreams',
      'artist': 'Synthwave',
      'album': 'Retro Future',
      'path': 'assets/audio/sample3.mp3',
      'image': 'https://picsum.photos/300/300?random=3',
    },
    {
      'title': 'Ocean Waves',
      'artist': 'Nature Sounds',
      'album': 'Relaxation',
      'path': 'assets/audio/sample4.mp3',
      'image': 'https://picsum.photos/300/300?random=4',
    },
    {
      'title': 'City Lights',
      'artist': 'Urban Vibes',
      'album': 'Metro Collection',
      'path': 'assets/audio/sample5.mp3',
      'image': 'https://picsum.photos/300/300?random=5',
    },
    {
      'title': 'Forest Path',
      'artist': 'Ambient Explorer',
      'album': 'Natural Soundscapes',
      'path': 'assets/audio/sample6.mp3',
      'image': 'https://picsum.photos/300/300?random=6',
    },
    {
      'title': 'Electric Pulse',
      'artist': 'EDM Producer',
      'album': 'Bass Drop',
      'path': 'assets/audio/sample7.mp3',
      'image': 'https://picsum.photos/300/300?random=7',
    },
    {
      'title': 'Sunset Boulevard',
      'artist': 'Jazz Quartet',
      'album': 'Evening Sessions',
      'path': 'assets/audio/sample8.mp3',
      'image': 'https://picsum.photos/300/300?random=8',
    },
  ];

  /// Simulates scanning device for music files
  static Future<List<Track>> scanDeviceMusic({int limit = 20}) async {
    print('[MockDeviceMusicService] Scanning device for music...');

    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    final List<Track> tracks = [];
    final shuffledTracks = List.from(_mockLocalTracks)..shuffle(_random);

    for (int i = 0;
        i < (limit < shuffledTracks.length ? limit : shuffledTracks.length);
        i++) {
      final trackData = shuffledTracks[i];
      tracks.add(Track(
        id: 'local_${i + 1}',
        title: trackData['title']!,
        artist: trackData['artist']!,
        album: trackData['album']!,
        albumArt: trackData['image']!,
        audioUrl: trackData['path']!,
        duration: _getRandomDuration(),
        isLocal: true,
      ));
    }

    print('[MockDeviceMusicService] Found ${tracks.length} local tracks');
    return tracks;
  }

  /// Simulates checking if we have permission to access device music
  static Future<bool> hasPermission() async {
    // Simulate permission check
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Mock always has permission
  }

  /// Simulates requesting permission to access device music
  static Future<bool> requestPermission() async {
    // Simulate permission request
    await Future.delayed(const Duration(seconds: 1));
    return true; // Mock always grants permission
  }

  /// Get random duration for mock tracks
  static Duration _getRandomDuration() {
    final minutes = _random.nextInt(4) + 2; // 2-5 minutes
    final seconds = _random.nextInt(60);
    return Duration(minutes: minutes, seconds: seconds);
  }

  /// Simulates getting recently played tracks
  static Future<List<Track>> getRecentlyPlayed() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final allTracks = await scanDeviceMusic(limit: 5);
    return allTracks.take(3).toList();
  }

  /// Simulates getting most played tracks
  static Future<List<Track>> getMostPlayed() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final allTracks = await scanDeviceMusic(limit: 8);
    return allTracks.take(5).toList();
  }

  /// Simulates searching local music
  static Future<List<Track>> searchLocal(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final allTracks = await scanDeviceMusic();

    return allTracks.where((track) {
      return track.title.toLowerCase().contains(query.toLowerCase()) ||
          track.artist.toLowerCase().contains(query.toLowerCase()) ||
          track.album.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Generate themed playlists based on current theme
  static Future<List<Map<String, dynamic>>> getThemedPlaylists(
      String theme) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final Map<String, List<String>> themeBasedPlaylists = {
      'Cyber Neon': [
        'Digital Dreams',
        'Electric Pulse',
        'Neon Nights',
        'Cyber Highway',
      ],
      'Sunset Vibes': [
        'Sunset Boulevard',
        'Golden Hour',
        'Evening Glow',
        'Warm Breeze',
      ],
      'Ocean Deep': [
        'Ocean Waves',
        'Deep Blue',
        'Tidal Flow',
        'Coral Reef',
      ],
      'Aurora Night': [
        'Northern Lights',
        'Midnight Aurora',
        'Stellar Dance',
        'Cosmic Journey',
      ],
    };

    final playlistNames =
        themeBasedPlaylists[theme] ?? themeBasedPlaylists['Cyber Neon']!;
    final List<Map<String, dynamic>> playlists = [];

    for (int i = 0; i < playlistNames.length; i++) {
      final tracks = await scanDeviceMusic(limit: _random.nextInt(8) + 5);
      playlists.add({
        'id': 'themed_${theme.toLowerCase()}_$i',
        'name': playlistNames[i],
        'description': 'Perfect for $theme mood',
        'tracks': tracks.take(_random.nextInt(6) + 3).toList(),
        'coverImage': 'https://picsum.photos/300/300?random=${100 + i}',
      });
    }

    return playlists;
  }
}
