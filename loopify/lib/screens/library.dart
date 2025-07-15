import 'package:flutter/material.dart';
import 'package:loopify/widgets/sidebar.dart';
import 'package:loopify/widgets/music_player.dart';
import 'package:loopify/widgets/track_card.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/track.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Map<String, String>> tracks = [
    {
      'title': 'Sunset Drive',
      'artist': 'DJ Nova',
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
    },
    {
      'title': 'Morning Chill',
      'artist': 'Chillout Crew',
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
    },
    {
      'title': 'Night Beats',
      'artist': 'Night Owls',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    },
  ];

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void uploadMusic() {
    showToast('Music upload feature coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: const Color(0xFF27272A),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Upload Music',
            onPressed: uploadMusic,
          ),
        ],
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Library',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  // Convert to Track object for TrackCard
                  final trackObj = Track(
                    id: 'library_$index',
                    title: track['title']!,
                    artist: track['artist']!,
                    album: 'Library',
                    albumArt: track['image']!,
                    audioUrl: '',
                    duration: const Duration(minutes: 3, seconds: 30),
                    isLocal: true,
                  );
                  return TrackCard(
                    track: trackObj,
                    onTap: () {
                      showToast('Playing ${track['title']}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MusicPlayer(),
    );
  }
}
