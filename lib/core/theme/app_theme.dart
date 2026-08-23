import 'package:flutter/material.dart';
import 'package:poly2/core/theme/app_palette.dart';

/// Centralized theme configuration for PolyDeck.
class AppTheme {
  AppTheme._();

  // Compatibility names used by the FSRS card state UI.
  static const Color primaryBlue = AppPalette.iceMelt;
  static const Color cardRed = AppPalette.raindropsOnRoses;
  static const Color cardGreen = AppPalette.almostAqua;
  static const Color cardYellow = AppPalette.lemonIcing;
  static const Color cardDefault = AppPalette.nimbusCloud;

  // FSRS 4-button rating colors. The on-color is intentionally shared so the
  // four soft surfaces remain consistent and readable on small screens.
  static const Color ratingAgain = AppPalette.raindropsOnRoses;
  static const Color ratingHard = AppPalette.peachDust;
  static const Color ratingGood = AppPalette.almostAqua;
  static const Color ratingEasy = AppPalette.iceMelt;
  static const Color ratingOnColor = AppPalette.ink;

  static const LinearGradient selectedDeckGradient = LinearGradient(
    colors: [AppPalette.almostAqua, AppPalette.iceMelt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient unselectedDeckGradient = LinearGradient(
    colors: [AppPalette.nimbusCloud, AppPalette.orchidTint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bodyGradient = LinearGradient(
    colors: [AppPalette.cloudDancer, AppPalette.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.almostAqua,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppPalette.almostAqua,
          onPrimary: AppPalette.ink,
          primaryContainer: AppPalette.almostAqua,
          onPrimaryContainer: AppPalette.ink,
          secondary: AppPalette.peachDust,
          onSecondary: AppPalette.ink,
          secondaryContainer: AppPalette.peachDust,
          onSecondaryContainer: AppPalette.ink,
          tertiary: AppPalette.iceMelt,
          onTertiary: AppPalette.ink,
          tertiaryContainer: AppPalette.iceMelt,
          onTertiaryContainer: AppPalette.ink,
          error: AppPalette.raindropsOnRoses,
          onError: AppPalette.ink,
          errorContainer: AppPalette.raindropsOnRoses,
          onErrorContainer: AppPalette.ink,
          surface: AppPalette.cloudDancer,
          onSurface: AppPalette.ink,
          surfaceContainer: AppPalette.cloudDancer,
          surfaceContainerHighest: AppPalette.nimbusCloud,
          onSurfaceVariant: AppPalette.mutedInk,
          outline: AppPalette.outline,
          outlineVariant: AppPalette.nimbusCloud,
        );

    return ThemeData(
      colorScheme: scheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppPalette.cloudDancer,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppPalette.cloudDancer,
        foregroundColor: AppPalette.ink,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 46),
          foregroundColor: AppPalette.ink,
          backgroundColor: AppPalette.almostAqua,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: AppPalette.ink,
          backgroundColor: AppPalette.almostAqua,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppPalette.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: AppPalette.cloudDancer,
        indicatorColor: AppPalette.almostAqua,
        surfaceTintColor: Colors.transparent,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppPalette.ink,
        unselectedLabelColor: AppPalette.mutedInk,
        indicatorColor: AppPalette.peachDust,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppPalette.ink),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.almostAqua,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(elevation: 0),
    );
  }
}
