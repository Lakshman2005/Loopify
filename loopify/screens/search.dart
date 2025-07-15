import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/music_player.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      drawer: Sidebar(),
      body: const Center(child: Text('Search your music here!')),
      bottomNavigationBar: MusicPlayer(),
    );
  }
}
