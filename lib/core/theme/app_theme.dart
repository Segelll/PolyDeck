import 'package:flutter/material.dart';

/// Centralized theme configuration for PolyDeck.
class AppTheme {
  AppTheme._();

  // ── Brand Colors ──

  static const Color primaryBlue = Color(0xFFADD8E6);
  static const Color cardRed = Colors.red;
  static const Color cardGreen = Colors.green;
  static const Color cardYellow = Color.fromARGB(255, 179, 130, 8);
  static const Color cardDefault = Colors.grey;

  // FSRS 4-button rating colors
  static const Color ratingAgain = Colors.red;
  static const Color ratingHard = Colors.orange;
  static const Color ratingGood = Color(0xFF8BC34A); // Light green
  static const Color ratingEasy = Colors.blue;

  // ── Gradients ──

  static const LinearGradient selectedDeckGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient unselectedDeckGradient = LinearGradient(
    colors: [Color(0xFF9E9E9E), Color(0xFFBDBDBD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bodyGradient = LinearGradient(
    colors: [Color(0xFFECEFF1), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Theme Data ──

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4E8572),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF31554A),
      onPrimary: Colors.white,
      secondary: const Color(0xFFD9785A),
      surface: const Color(0xFFF8FAF8),
    );
    return ThemeData(
      colorScheme: scheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAF8),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFFF8FAF8),
        foregroundColor: Color(0xFF162A32),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 46),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: Color(0xFFF8FAF8),
        indicatorColor: Color(0xFFD5E5DE),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF31554A),
        unselectedLabelColor: Color(0xFF6D7C80),
        indicatorColor: Color(0xFFD9785A),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4E8572),
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(elevation: 0),
    );
  }
}
