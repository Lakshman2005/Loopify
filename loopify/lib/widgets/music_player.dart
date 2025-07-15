import 'package:flutter/material.dart';
import 'package:loopify/screens/player.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  bool isPlaying = false;
  String trackTitle = 'Track Title';
  String artistName = 'Artist Name';
  String albumImage =
      'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4';

  void playPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPlaying ? 'Playing' : 'Paused'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void nextTrack() {
    setState(() {
      trackTitle = 'Next Track';
      artistName = 'Next Artist';
      isPlaying = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playing next track'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void previousTrack() {
    setState(() {
      trackTitle = 'Previous Track';
      artistName = 'Previous Artist';
      isPlaying = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playing previous track'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void openPlayerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongPlayerScreen(
          albumImage: albumImage,
          trackTitle: trackTitle,
          artistName: artistName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF27272A),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: openPlayerScreen,
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              backgroundImage: NetworkImage(albumImage),
              child: const Icon(Icons.music_note, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(trackTitle,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(artistName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            onPressed: previousTrack,
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white, size: 32),
            onPressed: playPause,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: nextTrack,
          ),
        ],
      ),
    );
  }
}
