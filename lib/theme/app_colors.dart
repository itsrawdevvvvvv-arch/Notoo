import 'package:flutter/material.dart';

/// Notoo's palette: a warm, editorial, paper-like system.
class AppColors {
  AppColors._();

  // Light canvas
  static const cream = Color(0xFFF7F3EA);
  static const creamSurface = Color(0xFFFFFDF8);
  static const ink = Color(0xFF2E2A24);
  static const inkSoft = Color(0xFF6B6459);
  static const hairline = Color(0xFFE7DFD0);

  // Dark canvas
  static const darkBg = Color(0xFF1E1C18);
  static const darkSurface = Color(0xFF2A2721);
  static const darkInk = Color(0xFFF1ECE0);
  static const darkInkSoft = Color(0xFFB6AE9F);

  // AMOLED canvas
  static const amoledBg = Color(0xFF000000);
  static const amoledSurface = Color(0xFF0E0E0E);
  static const amoledInk = Color(0xFFEDEDED);
  static const amoledInkSoft = Color(0xFF9A9A9A);

  // Accents
  static const green = Color(0xFF4F6B57);
  static const greenDeep = Color(0xFF3A5142);

  /// Pastel note tints, matching the mockup's muted palette.
  static const pastels = <Color>[
    Color(0xFFCDE7D5), // mint
    Color(0xFFF6D9BE), // peach
    Color(0xFFDCD6F0), // lavender
    Color(0xFFF6E7A8), // butter
    Color(0xFFF3CFCF), // pink
    Color(0xFFC9E0EE), // sky
  ];

  static Color pastel(int? i) =>
      i == null ? Colors.transparent : pastels[i % pastels.length];

  static const pastelNames = <String>[
    'Mint',
    'Peach',
    'Lavender',
    'Butter',
    'Pink',
    'Sky',
  ];
}
