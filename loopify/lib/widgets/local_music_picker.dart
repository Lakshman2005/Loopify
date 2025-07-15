import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart'; // Temporarily disabled

class LocalMusicPicker extends StatefulWidget {
  final Function(String path) onSongPicked;
  const LocalMusicPicker({required this.onSongPicked, Key? key})
      : super(key: key);

  @override
  State<LocalMusicPicker> createState() => _LocalMusicPickerState();
}

class _LocalMusicPickerState extends State<LocalMusicPicker> {
  String? pickedSongPath;

  Future<void> pickSong() async {
    // Temporarily disabled file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Use "My Device Music" in Home screen instead'),
      ),
    );
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.audio,
    // );
    // if (result != null && result.files.single.path != null) {
    //   setState(() {
    //     pickedSongPath = result.files.single.path;
    //   });
    //   widget.onSongPicked(pickedSongPath!);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.library_music),
          label: const Text('Pick Local Song'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
          ),
          onPressed: pickSong,
        ),
        if (pickedSongPath != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Selected: ${pickedSongPath!.split('/').last}',
                style: const TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
