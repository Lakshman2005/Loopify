import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppTheme {
  cyberNeon,
  sunsetVibes,
  oceanDeep,
  auroraNight,
}

class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.cyberNeon;

  AppTheme get currentTheme => _currentTheme;

  // 🎨 CYBER NEON THEME (Purple/Blue/Cyan)
  static const cyberNeonColors = {
    'primary': Color(0xFF1A0B2E), // Deep Purple
    'secondary': Color(0xFF7209B7), // Electric Blue
    'accent': Color(0xFF00F5FF), // Neon Cyan
    'background': Color(0xFF0F051D), // Dark Navy
    'surface': Color(0xFF2D1B3D), // Charcoal
    'textPrimary': Color(0xFFFFFFFF), // White
    'textSecondary': Color(0xFFB0B0B0), // Light Gray
  };

  // 🌅 SUNSET VIBES THEME (Orange/Purple/Yellow)
  static const sunsetVibesColors = {
    'primary': Color(0xFFFF6B35), // Deep Orange
    'secondary': Color(0xFF6A4C93), // Warm Purple
    'accent': Color(0xFFFFBE0B), // Golden Yellow
    'background': Color(0xFF2D1B2F), // Dark Maroon
    'surface': Color(0xFF3C2A4D), // Dark Purple
    'textPrimary': Color(0xFFFFFFFF), // White
    'textSecondary': Color(0xFFE0E0E0), // Light Gray
  };

  // 🌊 OCEAN DEEP THEME (Teal/Blue/Aqua)
  static const oceanDeepColors = {
    'primary': Color(0xFF004D4F), // Deep Teal
    'secondary': Color(0xFF006A6B), // Ocean Blue
    'accent': Color(0xFF40E0D0), // Aqua Mint
    'background': Color(0xFF001D23), // Dark Blue
    'surface': Color(0xFF2C3E50), // Slate Blue
    'textPrimary': Color(0xFFFFFFFF), // White
    'textSecondary': Color(0xFFA0A0A0), // Light Gray
  };

  // 🌌 AURORA NIGHT THEME (Violet/Purple/Green)
  static const auroraNightColors = {
    'primary': Color(0xFF2E0249), // Dark Violet
    'secondary': Color(0xFF570A57), // Purple Blue
    'accent': Color(0xFF39FF14), // Electric Green
    'background': Color(0xFF0D0221), // Almost Black
    'surface': Color(0xFF1A0B2E), // Deep Purple
    'textPrimary': Color(0xFFFFFFFF), // White
    'textSecondary': Color(0xFFC0C0C0), // Light Gray
  };

  // Get current theme colors
  Map<String, Color> get currentColors {
    switch (_currentTheme) {
      case AppTheme.cyberNeon:
        return cyberNeonColors;
      case AppTheme.sunsetVibes:
        return sunsetVibesColors;
      case AppTheme.oceanDeep:
        return oceanDeepColors;
      case AppTheme.auroraNight:
        return auroraNightColors;
    }
  }

  // Quick access to common colors
  Color get primaryColor => currentColors['primary']!;
  Color get secondaryColor => currentColors['secondary']!;
  Color get accentColor => currentColors['accent']!;
  Color get backgroundColor => currentColors['background']!;
  Color get surfaceColor => currentColors['surface']!;
  Color get textPrimaryColor => currentColors['textPrimary']!;
  Color get textSecondaryColor => currentColors['textSecondary']!;

  // Theme name getters
  String get themeName {
    switch (_currentTheme) {
      case AppTheme.cyberNeon:
        return 'Cyber Neon';
      case AppTheme.sunsetVibes:
        return 'Sunset Vibes';
      case AppTheme.oceanDeep:
        return 'Ocean Deep';
      case AppTheme.auroraNight:
        return 'Aurora Night';
    }
  }

  String get themeEmoji {
    switch (_currentTheme) {
      case AppTheme.cyberNeon:
        return '💜⚡';
      case AppTheme.sunsetVibes:
        return '🌅🔥';
      case AppTheme.oceanDeep:
        return '🌊💎';
      case AppTheme.auroraNight:
        return '🌌✨';
    }
  }

  // Generate Material Theme
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 8,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge:
            TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
        headlineMedium:
            TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
        titleLarge:
            TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimaryColor),
        bodyLarge: TextStyle(color: textPrimaryColor),
        bodyMedium: TextStyle(color: textSecondaryColor),
        labelLarge:
            TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w500),
      ),
      iconTheme: IconThemeData(color: textPrimaryColor),
      dividerColor: textSecondaryColor.withValues(alpha: 0.3),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        onPrimary: textPrimaryColor,
        onSecondary: textPrimaryColor,
        onSurface: textPrimaryColor,
      ),
    );
  }

  // Create epic gradients
  LinearGradient get primaryGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryColor, secondaryColor],
    );
  }

  LinearGradient get accentGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [accentColor.withValues(alpha: 0.8), primaryColor],
    );
  }

  LinearGradient get backgroundGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        backgroundColor,
        primaryColor.withValues(alpha: 0.1),
        backgroundColor,
      ],
    );
  }

  // Switch theme with smooth animation
  void switchTheme(AppTheme newTheme) {
    if (_currentTheme != newTheme) {
      _currentTheme = newTheme;
      notifyListeners();

      // Add haptic feedback for premium feel
      HapticFeedback.lightImpact();
    }
  }

  // Cycle through themes (for fun!)
  void nextTheme() {
    final themes = AppTheme.values;
    final currentIndex = themes.indexOf(_currentTheme);
    final nextIndex = (currentIndex + 1) % themes.length;
    switchTheme(themes[nextIndex]);
  }

  // Get all available themes for UI
  List<AppTheme> get availableThemes => AppTheme.values;

  // Static colors for backward compatibility (will be removed later)
  static const Color backgroundNavy = Color(0xFF0F051D);
  static const Color surfaceCharcoal = Color(0xFF2D1B3D);
  static const Color primaryPurple = Color(0xFF7209B7);
  static const Color accentAqua = Color(0xFF00F5FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Legacy compatibility methods
  AppTheme get theme => _currentTheme;
  void setTheme(AppTheme theme) => switchTheme(theme);
}
