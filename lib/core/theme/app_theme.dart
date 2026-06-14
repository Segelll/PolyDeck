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
    return ThemeData(
      primarySwatch: Colors.blueGrey,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        elevation: 1,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blueGrey,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        elevation: 1,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
