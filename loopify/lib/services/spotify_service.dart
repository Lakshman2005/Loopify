import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class SpotifyService {
  static const String _baseUrl = 'https://api.spotify.com/v1';
  static const String _searchEndpoint = '/search';
  static const String _albumsEndpoint = '/albums';
  static const String _tracksEndpoint = '/tracks';
  static const String _artistsEndpoint = '/artists';
  static const String _playlistsEndpoint = '/playlists';
  
  // You'll need to replace this with your actual Spotify access token
  static String _accessToken = 'YOUR_SPOTIFY_ACCESS_TOKEN';
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Debug callback for UI feedback
  void Function(String)? onDebug;

  void setDebugCallback(void Function(String) cb) {
    onDebug = cb;
  }

  void _debug(String msg) {
    print('[SpotifyService] $msg');
    if (onDebug != null) onDebug!(msg);
  }

  // Get headers with authentication
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_accessToken',
    'Content-Type': 'application/json',
  };

  // Add a public static getter for the access token
  static String get accessToken => _accessToken;

  // Search for tracks
  Future<List<Map<String, dynamic>>> searchTracks(String query) async {
    try {
      _debug('Searching Spotify tracks for "$query"...');
      final response = await http.get(
        Uri.parse('$_baseUrl$_searchEndpoint?q=${Uri.encodeComponent(query)}&type=track&limit=20'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'] as List;
        _debug('Found ${tracks.length} Spotify tracks for "$query".');
        
        return tracks.map((track) => {
          'id': track['id'],
          'title': track['name'],
          'artist': track['artists'].isNotEmpty ? track['artists'][0]['name'] : 'Unknown Artist',
          'album': track['album']['name'],
          'duration': track['duration_ms'],
          'preview_url': track['preview_url'],
          'cover': track['album']['images'].isNotEmpty ? track['album']['images'][0]['url'] : null,
          'album_id': track['album']['id'],
          'type': 'spotify',
          'spotify_url': track['external_urls']['spotify'],
        }).toList();
      } else {
        _debug('Failed to search Spotify tracks: ${response.statusCode}');
      }
    } catch (e) {
      _debug('Error searching Spotify tracks: $e');
    }
    return [];
  }

  // Get album details
  Future<Map<String, dynamic>?> getAlbumDetails(String albumId) async {
    try {
      _debug('Fetching Spotify album details for $albumId...');
      final response = await http.get(
        Uri.parse('$_baseUrl$_albumsEndpoint/$albumId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _debug('Fetched Spotify album: ${data['name']}');
        
        return {
          'id': data['id'],
          'name': data['name'],
          'artist': data['artists'].isNotEmpty ? data['artists'][0]['name'] : 'Unknown Artist',
          'cover': data['images'].isNotEmpty ? data['images'][0]['url'] : null,
          'total_tracks': data['total_tracks'],
          'release_date': data['release_date'],
          'type': 'spotify_album',
        };
      } else {
        _debug('Failed to fetch Spotify album: ${response.statusCode}');
      }
    } catch (e) {
      _debug('Error fetching Spotify album: $e');
    }
    return null;
  }

  // Get album tracks
  Future<List<Map<String, dynamic>>> getAlbumTracks(String albumId) async {
    try {
      _debug('Fetching Spotify album tracks for $albumId...');
      final response = await http.get(
        Uri.parse('$_baseUrl$_albumsEndpoint/$albumId/tracks?limit=50'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['items'] as List;
        _debug('Fetched ${tracks.length} Spotify album tracks.');
        
        return tracks.map((track) => {
          'id': track['id'],
          'title': track['name'],
          'artist': track['artists'].isNotEmpty ? track['artists'][0]['name'] : 'Unknown Artist',
          'duration': track['duration_ms'],
          'track_number': track['track_number'],
          'preview_url': track['preview_url'],
          'type': 'spotify',
          'spotify_url': track['external_urls']['spotify'],
        }).toList();
      } else {
        _debug('Failed to fetch Spotify album tracks: ${response.statusCode}');
      }
    } catch (e) {
      _debug('Error fetching Spotify album tracks: $e');
    }
    return [];
  }

  // Get new releases
  Future<List<Map<String, dynamic>>> getNewReleases() async {
    try {
      _debug('Fetching Spotify new releases...');
      final response = await http.get(
        Uri.parse('$_baseUrl/browse/new-releases?limit=20'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final albums = data['albums']['items'] as List;
        _debug('Fetched ${albums.length} Spotify new releases.');
        
        return albums.map((album) => {
          'id': album['id'],
          'name': album['name'],
          'artist': album['artists'].isNotEmpty ? album['artists'][0]['name'] : 'Unknown Artist',
          'cover': album['images'].isNotEmpty ? album['images'][0]['url'] : null,
          'total_tracks': album['total_tracks'],
          'release_date': album['release_date'],
          'type': 'spotify_album',
        }).toList();
      } else {
        _debug('Failed to fetch Spotify new releases: ${response.statusCode}');
      }
    } catch (e) {
      _debug('Error fetching Spotify new releases: $e');
    }
    return [];
  }

  // Get featured playlists
  Future<List<Map<String, dynamic>>> getFeaturedPlaylists() async {
    try {
      _debug('Fetching Spotify featured playlists...');
      final response = await http.get(
        Uri.parse('$_baseUrl/browse/featured-playlists?limit=20'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final playlists = data['playlists']['items'] as List;
        _debug('Fetched ${playlists.length} Spotify featured playlists.');
        
        return playlists.map((playlist) => {
          'id': playlist['id'],
          'name': playlist['name'],
          'description': playlist['description'] ?? '',
          'cover': playlist['images'].isNotEmpty ? playlist['images'][0]['url'] : null,
          'track_count': playlist['tracks']['total'],
          'type': 'spotify_playlist',
        }).toList();
      } else {
        _debug('Failed to fetch Spotify featured playlists: ${response.statusCode}');
      }
    } catch (e) {
      _debug('Error fetching Spotify featured playlists: $e');
    }
    return [];
  }

  // Get playlist tracks
  Future<List<Map<String, dynamic>>> getPlaylistTracks(String playlistId) async {
    try {
      _debug('Fetching Spotify playlist tracks for $playlistId...');
      final response = await http.get(
        Uri.parse('$_baseUrl$_playlistsEndpoint/$playlistId/tracks?limit=50'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['items'] as List;
        _debug('Fetched ${tracks.length} Spotify playlist tracks.');
        
        return tracks.map((item) {
          final track = item['track'];
          return {
            'id': track['id'],
            'title': track['name'],
            'artist': track['artists'].isNotEmpty ? track['artists'][0]['name'] : 'Unknown Artist',
            'album': track['album']['name'],
            'duration': track['duration_ms'],
            'preview_url': track['preview_url'],
            'cover': track['album']['images'].isNotEmpty ? track['album']['images'][0]['url'] : null,
            'type': 'spotify',
            'spotify_url': track['external_urls']['spotify'],
          };
        }).toList();
      } else {
        _debug('Failed to fetch Spotify playlist tracks: ${response.statusCode}');
      }
    } catch (e) {
      _debug('Error fetching Spotify playlist tracks: $e');
    }
    return [];
  }

  // Play preview track (30-second preview)
  Future<void> playPreviewTrack(String previewUrl) async {
    try {
      _debug('Attempting to play Spotify preview: $previewUrl');
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(previewUrl);
      await _audioPlayer.play();
      _debug('Now playing Spotify preview.');
    } catch (e) {
      _debug('Error playing Spotify preview: $e');
      rethrow;
    }
  }

  // Pause track
  Future<void> pauseTrack() async {
    try {
      await _audioPlayer.pause();
      _debug('Paused Spotify track.');
    } catch (e) {
      _debug('Error pausing Spotify track: $e');
    }
  }

  // Stop track
  Future<void> stopTrack() async {
    try {
      await _audioPlayer.stop();
      _debug('Stopped Spotify track.');
    } catch (e) {
      _debug('Error stopping Spotify track: $e');
    }
  }

  // Get current position
  Duration get position => _audioPlayer.position;
  
  // Get duration
  Duration? get duration => _audioPlayer.duration;
  
  // Check if playing
  bool get isPlaying => _audioPlayer.playing;
  
  // Listen to position changes
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  // Listen to playing state changes
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  
  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
} 