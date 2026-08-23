import 'package:flutter/material.dart';

/// The small, low-saturation palette used across PolyDeck.
///
/// The names mirror the supplied Pantone reference. Semantic colors that are
/// not part of the reference use the same neutral family so the palette stays
/// calm while text still has enough contrast to remain readable.
class AppPalette {
  AppPalette._();

  static const Color lemonIcing = Color(0xFFF3EBCB);
  static const Color nimbusCloud = Color(0xFFD6D6D8);
  static const Color raindropsOnRoses = Color(0xFFE8D8DC);
  static const Color cloudDancer = Color(0xFFF5F4F1);
  static const Color iceMelt = Color(0xFFC9E0EF);
  static const Color peachDust = Color(0xFFEACFC0);
  static const Color almostAqua = Color(0xFFC4D3BD);
  static const Color orchidTint = Color(0xFFD8D0DB);

  static const Color ink = Color(0xFF354047);
  static const Color mutedInk = Color(0xFF69757A);
  static const Color outline = Color(0xFFBFC7C7);
  static const Color shadow = Color(0x26000000);
  static const Color white = Color(0xFFFFFFFF);
}
