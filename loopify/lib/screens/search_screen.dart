import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/track_card.dart';
import '../models/track.dart'; // Added import for Track model

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _searchHistory = ['Blinding Lights', 'Levitating', 'Watermelon Sugar'];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Podcasts', 'icon': Icons.mic, 'color': Colors.orange},
    {'name': 'Made For You', 'icon': Icons.favorite, 'color': Colors.purple},
    {'name': 'Charts', 'icon': Icons.trending_up, 'color': Colors.blue},
    {'name': 'New Releases', 'icon': Icons.new_releases, 'color': Colors.green},
    {'name': 'Discover', 'icon': Icons.explore, 'color': Colors.pink},
    {'name': 'Concerts', 'icon': Icons.event, 'color': Colors.red},
    {'name': 'Hip-Hop', 'icon': Icons.music_note, 'color': Colors.yellow},
    {'name': 'Pop', 'icon': Icons.music_note, 'color': Colors.cyan},
    {'name': 'Rock', 'icon': Icons.music_note, 'color': Colors.brown},
    {'name': 'Jazz', 'icon': Icons.music_note, 'color': Colors.indigo},
    {'name': 'Classical', 'icon': Icons.music_note, 'color': Colors.teal},
    {'name': 'Electronic', 'icon': Icons.music_note, 'color': Colors.deepPurple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            title: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'What do you want to listen to?',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _searchQuery.isEmpty ? _buildSearchContent() : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Recent Searches
        if (_searchHistory.isNotEmpty) ...[
          const Text(
            'Recent Searches',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._searchHistory.map((query) => _buildRecentSearchItem(query)),
        ],
        
        const SizedBox(height: 100), // Bottom padding for mini player
      ]),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final localResults = musicProvider.searchTracks(_searchQuery);

        if (localResults.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$_searchQuery"',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching for a different song or artist',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final track = localResults[index];
              return TrackCard(
                track: track,
                onTap: () {
                  context.read<PlayerProvider>().playTrack(
                    track,
                    queue: localResults,
                    index: index,
                  );
                },
              );
            },
            childCount: localResults.length,
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category['color'],
              category['color'].withOpacity(0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                category['icon'],
                color: Colors.white,
                size: 32,
              ),
              Text(
                category['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String query) {
    return ListTile(
      leading: Icon(Icons.history, color: Colors.grey.shade400),
      title: Text(
        query,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Icon(Icons.arrow_upward, color: Colors.grey.shade400, size: 16),
      onTap: () {
        _searchController.text = query;
        setState(() {
          _searchQuery = query;
        });
      },
    );
  }
} 