import 'package:flutter/material.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomAppBar(
      color: Colors.deepPurple,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.skip_previous, color: Colors.white),
            Icon(Icons.play_arrow, color: Colors.white),
            Icon(Icons.skip_next, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
