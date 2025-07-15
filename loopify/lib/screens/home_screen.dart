import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../providers/theme_provider.dart';
import '../services/device_music_service.dart';
import '../services/mock_device_music_service.dart';
import '../models/track.dart';
import '../widgets/playlist_card.dart';
import '../widgets/track_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.backgroundGradient,
            ),
            child: CustomScrollView(
              slivers: [
                // Epic App Bar
                SliverAppBar(
                  expandedHeight: 140,
                  floating: false,
                  pinned: true,
                  backgroundColor: themeProvider.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Loopify',
                      style: TextStyle(
                        color: themeProvider.textPrimaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: themeProvider.primaryGradient,
                      ),
                    ),
                  ),
                  actions: [
                    // Dynamic Theme Button
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () => themeProvider.nextTheme(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: themeProvider.accentGradient,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: themeProvider.accentColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              themeProvider.themeEmoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([


                      // Trending Tracks Section
                      Text(
                        'Trending Now',
                        style: TextStyle(
                          color: themeProvider.textPrimaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTrendingTracks(themeProvider),
                      const SizedBox(height: 32),

                      const SizedBox(
                          height: 100), // Bottom padding for mini player
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }





  // Updated trending tracks with theme support
  Widget _buildTrendingTracks(ThemeProvider themeProvider) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (musicProvider.featuredTracks.isEmpty) {
          return Center(
            child: Text(
              'No trending tracks available',
              style: TextStyle(
                color: themeProvider.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: musicProvider.featuredTracks.length,
          itemBuilder: (context, index) {
            final track = musicProvider.featuredTracks[index];
            return TrackCard(
              track: track,
              onTap: () {
                context.read<PlayerProvider>().playTrack(
                      track,
                      queue: musicProvider.featuredTracks,
                      index: index,
                    );
              },
            );
          },
        );
      },
    );
  }


}
