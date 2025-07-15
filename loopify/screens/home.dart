import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/music_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Sidebar(),
      body: const Center(child: Text('Welcome to Loopify Home!')),
      bottomNavigationBar: MusicPlayer(),
    );
  }
}
