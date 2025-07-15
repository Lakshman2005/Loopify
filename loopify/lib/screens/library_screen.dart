import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/track_card.dart';
import '../widgets/playlist_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF121212),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Your Library',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1DB954),
                        Color(0xFF121212),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    _showSearchDialog();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    _showCreatePlaylistDialog();
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade400,
                tabs: const [
                  Tab(text: 'Playlists'),
                  Tab(text: 'Liked Songs'),
                  Tab(text: 'Recently Played'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPlaylistsTab(),
            _buildLikedSongsTab(),
            _buildRecentlyPlayedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final playlists = musicProvider.userPlaylists.isEmpty 
            ? musicProvider.featuredPlaylists 
            : musicProvider.userPlaylists;
        
        if (playlists.isEmpty) {
          return _buildEmptyState(
            icon: Icons.library_music,
            title: 'Create your first playlist',
            subtitle: 'It\'s easy, we\'ll help you',
            actionText: 'Create Playlist',
            onAction: _showCreatePlaylistDialog,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: PlaylistCard(
                title: playlist.name,
                subtitle: '${playlist.tracks.length} songs',
                imageUrl: playlist.coverImage,
                onTap: () {
                  // Navigate to playlist detail
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLikedSongsTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (musicProvider.likedSongs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite,
            title: 'Songs you like will appear here',
            subtitle: 'Save songs by tapping the heart icon',
            actionText: 'Find Something to Like',
            onAction: () {
              // Navigate to search
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: musicProvider.likedSongs.length,
          itemBuilder: (context, index) {
            final track = musicProvider.likedSongs[index];
            return TrackCard(
              track: track,
              onTap: () {
                context.read<PlayerProvider>().playTrack(
                  track,
                  queue: musicProvider.likedSongs,
                  index: index,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecentlyPlayedTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (musicProvider.recentlyPlayed.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'No recently played tracks',
            subtitle: 'Start listening to see your history',
            actionText: 'Start Listening',
            onAction: () {
              // Navigate to home
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: musicProvider.recentlyPlayed.length,
          itemBuilder: (context, index) {
            final track = musicProvider.recentlyPlayed[index];
            return TrackCard(
              track: track,
              onTap: () {
                context.read<PlayerProvider>().playTrack(
                  track,
                  queue: musicProvider.recentlyPlayed,
                  index: index,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Search Library', style: TextStyle(color: Colors.white)),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search your library...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search', style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Create Playlist', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Playlist name',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create', style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }
} 