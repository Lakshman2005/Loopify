import 'package:flutter/material.dart';

class SongPlayerScreen extends StatelessWidget {
  final String albumImage;
  final String trackTitle;
  final String artistName;

  const SongPlayerScreen({super.key, 
    this.albumImage =
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
    this.trackTitle = 'Track Title',
    this.artistName = 'Artist Name',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Blurred album art background
          Positioned.fill(
            child: Image.network(
              albumImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    albumImage,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                Text(trackTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(artistName,
                    style: const TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous,
                          color: Colors.white, size: 36),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon:
                          const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon:
                          const Icon(Icons.skip_next, color: Colors.white, size: 36),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
