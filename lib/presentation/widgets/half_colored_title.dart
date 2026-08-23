import 'package:flutter/material.dart';
import 'package:poly2/core/theme/app_palette.dart';

/// A title widget where the second half of the text is colored light blue.
///
/// Used across the app for the PolyDeck branding style in AppBar titles.
class HalfColoredTitle extends StatelessWidget {
  final String text;

  const HalfColoredTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final half = text.length ~/ 2;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: text.substring(0, half),
            style: const TextStyle(color: AppPalette.ink),
          ),
          TextSpan(
            text: text.substring(half),
            style: const TextStyle(color: AppPalette.iceMelt),
          ),
        ],
      ),
    );
  }
}
