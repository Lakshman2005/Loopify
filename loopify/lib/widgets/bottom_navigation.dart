import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/player_provider.dart';

class ModernBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, PlayerProvider>(
      builder: (context, themeProvider, playerProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                themeProvider.surfaceColor.withValues(alpha: 0.95),
                themeProvider.backgroundColor.withValues(alpha: 0.98),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: themeProvider.accentColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: themeProvider.primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context,
                    themeProvider,
                    index: 0,
                    icon: Icons.home_filled,
                    label: 'Home',
                    emoji: '🏠',
                  ),
                  _buildNavItem(
                    context,
                    themeProvider,
                    index: 1,
                    icon: Icons.search_rounded,
                    label: 'Search',
                    emoji: '🔍',
                  ),
                  _buildNavItem(
                    context,
                    themeProvider,
                    index: 2,
                    icon: Icons.music_note_rounded,
                    label: 'Offline',
                    emoji: '📱',
                  ),
                  _buildNavItem(
                    context,
                    themeProvider,
                    index: 3,
                    icon: Icons.library_music_rounded,
                    label: 'Library',
                    emoji: '📚',
                  ),
                  _buildNavItem(
                    context,
                    themeProvider,
                    index: 4,
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    emoji: '👤',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    ThemeProvider themeProvider, {
    required int index,
    required IconData icon,
    required String label,
    required String emoji,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    themeProvider.accentColor.withValues(alpha: 0.2),
                    themeProvider.primaryColor.withValues(alpha: 0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(
                  color: themeProvider.accentColor.withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with emoji overlay
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    icon,
                    size: isSelected ? 22 : 18,
                    color: isSelected
                        ? themeProvider.accentColor
                        : themeProvider.textSecondaryColor,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected
                    ? themeProvider.accentColor
                    : themeProvider.textSecondaryColor,
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
            // Active indicator
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 2),
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.accentColor,
                      themeProvider.primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Tab Bar for additional style
class SpotifyStyleTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String> labels;
  final List<IconData> icons;

  const SpotifyStyleTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.labels,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: themeProvider.accentGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: themeProvider.accentColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: List.generate(
              labels.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: currentIndex == index
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[index],
                          color: currentIndex == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          size: currentIndex == index ? 24 : 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            color: currentIndex == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: currentIndex == index
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
