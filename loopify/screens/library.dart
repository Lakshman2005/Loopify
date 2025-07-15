import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/music_player.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      drawer: Sidebar(),
      body: const Center(child: Text('Your music library!')),
      bottomNavigationBar: MusicPlayer(),
    );
  }
}
