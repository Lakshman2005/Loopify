import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/offline_music_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/now_playing_screen.dart';
import 'screens/downloads_screen.dart';

import 'providers/music_provider.dart';
import 'providers/player_provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/mini_player.dart';
import 'services/audio_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = LoopifyAudioHandler();
  runApp(MyApp(audioHandler: audioHandler));
}

class MyApp extends StatelessWidget {
  final LoopifyAudioHandler audioHandler;
  const MyApp({required this.audioHandler, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider(audioHandler)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
              child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Loopify',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: const MainScreen(),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const OfflineMusicScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Player
          Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              final currentTrack = playerProvider.currentTrack;
              print('[MainScreen] Building mini player, currentTrack: ${currentTrack?.title}');
              if (currentTrack != null) {
                return MiniPlayer();
              }
              return const SizedBox.shrink();
            },
          ),
          // Modern Spotify-Style Bottom Navigation
          ModernBottomNavigation(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
