import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/core/theme/app_theme.dart';

void main() {
  test('Pantone palette exposes the complete brand palette', () {
    expect(AppPalette.lemonIcing, isA<Color>());
    expect(AppPalette.nimbusCloud, isA<Color>());
    expect(AppPalette.raindropsOnRoses, isA<Color>());
    expect(AppPalette.cloudDancer, isA<Color>());
    expect(AppPalette.iceMelt, isA<Color>());
    expect(AppPalette.peachDust, isA<Color>());
    expect(AppPalette.almostAqua, isA<Color>());
    expect(AppPalette.orchidTint, isA<Color>());
  });

  test('light theme is sourced from the centralized palette', () {
    final scheme = AppTheme.lightTheme.colorScheme;

    expect(scheme.primary, AppPalette.almostAqua);
    expect(scheme.onPrimary, AppPalette.ink);
    expect(scheme.surface, AppPalette.cloudDancer);
    expect(scheme.onSurface, AppPalette.ink);
    expect(AppTheme.ratingAgain, AppPalette.raindropsOnRoses);
    expect(AppTheme.ratingHard, AppPalette.peachDust);
    expect(AppTheme.ratingGood, AppPalette.almostAqua);
    expect(AppTheme.ratingEasy, AppPalette.iceMelt);
  });
}
