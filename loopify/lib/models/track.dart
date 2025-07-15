class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String albumArt;
  final String audioUrl;
  final Duration duration;
  final bool isLocal;
  final bool isFavorite;
  final int playCount;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArt,
    required this.audioUrl,
    this.duration = const Duration(minutes: 3, seconds: 30),
    this.isLocal = false,
    this.isFavorite = false,
    this.playCount = 0,
  });

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    String? audioUrl,
    Duration? duration,
    bool? isLocal,
    bool? isFavorite,
    int? playCount,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isLocal: isLocal ?? this.isLocal,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'albumArt': albumArt,
      'audioUrl': audioUrl,
      'duration': duration.inSeconds,
      'isLocal': isLocal,
      'isFavorite': isFavorite,
      'playCount': playCount,
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'] ?? 'Unknown Album',
      albumArt: json['albumArt'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 180),
      isLocal: json['isLocal'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      playCount: json['playCount'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'Track(id: $id, title: $title, artist: $artist, album: $album, isLocal: $isLocal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper getters
  String get displayTitle => title.isNotEmpty ? title : 'Unknown Title';
  String get displayArtist => artist.isNotEmpty ? artist : 'Unknown Artist';
  String get displayAlbum => album.isNotEmpty ? album : 'Unknown Album';

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get hasValidAudioUrl => audioUrl.isNotEmpty;
  bool get hasValidAlbumArt => albumArt.isNotEmpty;
}
