import 'package:flutter/foundation.dart';
import '../models/track.dart';

class Playlist {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final List<Track> tracks;
  final String type; // 'offline' only now

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.tracks,
    this.type = 'offline',
  });
}

class MusicProvider with ChangeNotifier {
  List<Track> _featuredTracks = [];
  List<Playlist> _featuredPlaylists = [];
  List<Track> _recentlyPlayed = [];
  List<Track> _likedSongs = [];
  final List<Playlist> _userPlaylists = [];
  bool _isLoading = false;
  String _error = '';

  // Sample data
  MusicProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _featuredTracks = [
      Track(
        id: '1',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        albumArt:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        duration: const Duration(seconds: 200),
        audioUrl: 'sample_url_1',
        isLocal: false,
      ),
      Track(
        id: '2',
        title: 'Levitating',
        artist: 'Dua Lipa',
        album: 'Future Nostalgia',
        albumArt:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        duration: const Duration(seconds: 203),
        audioUrl: 'sample_url_2',
        isLocal: false,
      ),
      Track(
        id: '3',
        title: 'Watermelon Sugar',
        artist: 'Harry Styles',
        album: 'Fine Line',
        albumArt:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        duration: const Duration(seconds: 174),
        audioUrl: 'sample_url_3',
        isLocal: false,
      ),
    ];

    _featuredPlaylists = [
      Playlist(
        id: '1',
        name: 'Today\'s Top Hits',
        description: 'The hottest tracks right now',
        coverImage:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        tracks: _featuredTracks,
        type: 'offline',
      ),
      Playlist(
        id: '2',
        name: 'Chill Vibes',
        description: 'Relaxing music for your day',
        coverImage:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        tracks: _featuredTracks,
        type: 'offline',
      ),
      Playlist(
        id: '3',
        name: 'Workout Mix',
        description: 'High energy tracks for your workout',
        coverImage:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        tracks: _featuredTracks,
        type: 'offline',
      ),
    ];

    _recentlyPlayed = _featuredTracks;
    _likedSongs = _featuredTracks.take(2).toList();
  }

  // Format duration from seconds to MM:SS
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Format Duration to MM:SS string
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Getters
  List<Track> get featuredTracks => _featuredTracks;
  List<Playlist> get featuredPlaylists => _featuredPlaylists;
  List<Track> get recentlyPlayed => _recentlyPlayed;
  List<Track> get likedSongs => _likedSongs;
  List<Playlist> get userPlaylists => _userPlaylists;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Methods
  void addToLikedSongs(Track track) {
    if (!_likedSongs.any((song) => song.id == track.id)) {
      _likedSongs.add(track);
      notifyListeners();
    }
  }

  void removeFromLikedSongs(String trackId) {
    _likedSongs.removeWhere((song) => song.id == trackId);
    notifyListeners();
  }

  void addToRecentlyPlayed(Track track) {
    _recentlyPlayed.removeWhere((song) => song.id == track.id);
    _recentlyPlayed.insert(0, track);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed = _recentlyPlayed.take(20).toList();
    }
    notifyListeners();
  }

  List<Track> searchTracks(String query) {
    if (query.isEmpty) return [];

    return _featuredTracks
        .where((track) =>
            track.title.toLowerCase().contains(query.toLowerCase()) ||
            track.artist.toLowerCase().contains(query.toLowerCase()) ||
            track.album.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
