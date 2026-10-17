import 'package:flutter/material.dart';

/// One selectable accent theme. Each has a colour tuned for light
/// backgrounds and a brighter one for dark / AMOLED.
class AccentOption {
  final String name;
  final Color light;
  final Color dark;
  const AccentOption(this.name, this.light, this.dark);
}

/// The 24 accent themes offered in Settings.
const List<AccentOption> kAccents = [
  AccentOption('Moss', Color(0xFF4F6B57), Color(0xFF9CC0A6)),
  AccentOption('Forest', Color(0xFF2F6B4F), Color(0xFF7FD1A6)),
  AccentOption('Sage', Color(0xFF6E8B72), Color(0xFFAFCBAF)),
  AccentOption('Teal', Color(0xFF2E7D7B), Color(0xFF7FD1CF)),
  AccentOption('Ocean', Color(0xFF2B6CB0), Color(0xFF7FB2E8)),
  AccentOption('Sky', Color(0xFF3E8ED0), Color(0xFF8FC6EE)),
  AccentOption('Indigo', Color(0xFF4C51BF), Color(0xFF9FA3EC)),
  AccentOption('Violet', Color(0xFF7C5CBF), Color(0xFFBFA6EC)),
  AccentOption('Plum', Color(0xFF8E4585), Color(0xFFD79BCE)),
  AccentOption('Berry', Color(0xFFB03060), Color(0xFFE88AA8)),
  AccentOption('Rose', Color(0xFFD9536F), Color(0xFFF2A0B0)),
  AccentOption('Coral', Color(0xFFE86A5B), Color(0xFFF5A79C)),
  AccentOption('Terracotta', Color(0xFFC15F3C), Color(0xFFE6A184)),
  AccentOption('Amber', Color(0xFFC8892A), Color(0xFFEEC178)),
  AccentOption('Honey', Color(0xFFD9A441), Color(0xFFF0CF8A)),
  AccentOption('Olive', Color(0xFF7A8B3A), Color(0xFFBCCB84)),
  AccentOption('Lime', Color(0xFF6B9E3A), Color(0xFFB0D684)),
  AccentOption('Emerald', Color(0xFF2E9E6B), Color(0xFF84D6B0)),
  AccentOption('Cyan', Color(0xFF2AA5B5), Color(0xFF84D6E0)),
  AccentOption('Slate', Color(0xFF546E7A), Color(0xFFA3BAC4)),
  AccentOption('Charcoal', Color(0xFF3A3F44), Color(0xFFB0B6BC)),
  AccentOption('Cocoa', Color(0xFF7A5C4A), Color(0xFFC9A894)),
  AccentOption('Blush', Color(0xFFC98B9B), Color(0xFFEEC1CC)),
  AccentOption('Lavender', Color(0xFF8E7CC3), Color(0xFFC6BCEC)),
];

/// Notoo's palette: a warm, editorial, paper-like system.
class AppColors {
  AppColors._();

  // Light canvas
  static const cream = Color(0xFFF7F3EA);
  static const creamSurface = Color(0xFFFFFDF8);
  static const ink = Color(0xFF2E2A24);
  static const inkSoft = Color(0xFF6B6459);
  static const hairline = Color(0xFFE7DFD0);

  // Dark canvas (a touch warmer and lighter than pure black so text breathes)
  static const darkBg = Color(0xFF1B1A17);
  static const darkSurface = Color(0xFF272521);
  static const darkInk = Color(0xFFF3EFE6);
  static const darkInkSoft = Color(0xFFB9B2A4);
  static const darkHairline = Color(0xFF3A3730);

  // AMOLED canvas
  static const amoledBg = Color(0xFF000000);
  static const amoledSurface = Color(0xFF111110);
  static const amoledInk = Color(0xFFEFEFEF);
  static const amoledInkSoft = Color(0xFF9E9E9E);
  static const amoledHairline = Color(0xFF2A2A28);

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

  /// Writing-pad paper backgrounds. Index 0 means "match the theme".
  static const papers = <Color>[
    Color(0xFFF7F3EA), // cream
    Color(0xFFFFFFFF), // white
    Color(0xFFFBF3E4), // parchment
    Color(0xFFEFF6EF), // sage mist
    Color(0xFFFDF1F2), // rose paper
    Color(0xFFF0F3FA), // blue paper
    Color(0xFFF5F0FA), // lilac paper
    Color(0xFF2A2721), // dark paper
    Color(0xFF000000), // black paper
  ];

  static const paperNames = <String>[
    'Theme',
    'White',
    'Parchment',
    'Sage',
    'Rose',
    'Blue',
    'Lilac',
    'Dark',
    'Black',
  ];
}
