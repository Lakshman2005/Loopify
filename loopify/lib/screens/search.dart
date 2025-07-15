import 'package:flutter/material.dart';
import 'package:loopify/widgets/sidebar.dart';
import 'package:loopify/widgets/music_player.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/track_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<Map<String, String>> tracks = [
    {
      'title': 'Dreams',
      'artist': 'Fleetwood Mac',
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
    },
    {
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
    },
    {
      'title': 'Levitating',
      'artist': 'Dua Lipa',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    },
  ];

  String searchQuery = '';
  List<dynamic> onlineSearchResults = [];
  bool isSearching = false;

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeProvider.accentAqua,
      ),
    );
  }

  Future<void> searchOnline(String query) async {
    if (query.isEmpty) {
      setState(() {
        onlineSearchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final musicProvider = context.read<MusicProvider>();
      final results = await musicProvider.searchOnlineTracks(query);
      setState(() {
        onlineSearchResults = results;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      showToast('Error searching online: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTracks = tracks
        .where((track) =>
            track['title']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            track['artist']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: ThemeProvider.backgroundNavy,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: ThemeProvider.backgroundNavy,
        foregroundColor: ThemeProvider.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tracks, artists, albums...',
                filled: true,
                fillColor: ThemeProvider.surfaceCharcoal,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: ThemeProvider.textSecondary),
              ),
              style: const TextStyle(color: ThemeProvider.textPrimary),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (searchQuery == value) {
                    searchOnline(value);
                  }
                });
              },
            ),
          ),
        ),
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchQuery.isNotEmpty) ...[
              const Text(
                'Local Search Results',
                style: TextStyle(
                  color: ThemeProvider.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredTracks.isEmpty
                    ? const Center(
                        child: Text(
                          'No local tracks found.',
                          style: TextStyle(color: ThemeProvider.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTracks.length,
                        itemBuilder: (context, index) {
                          final track = filteredTracks[index];
                          // Convert to Track object for TrackCard
                          final trackObj = Track(
                            id: 'local_$index',
                            title: track['title']!,
                            artist: track['artist']!,
                            album: 'Unknown Album',
                            albumArt: track['image']!,
                            duration: const Duration(minutes: 3, seconds: 30),
                            url: '',
                            type: 'offline',
                          );
                          return TrackCard(
                            track: trackObj,
                            onTap: () {
                              showToast('Playing: ${track['title']}');
                            },
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: MusicPlayer(),
    );
  }
}
