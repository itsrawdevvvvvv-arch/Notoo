import 'package:flutter/material.dart';

/// One selectable accent theme. Each has a colour tuned for light
/// backgrounds and a brighter one for dark / AMOLED.
class AccentOption {
  final String name;
  final Color light;
  final Color dark;
  const AccentOption(this.name, this.light, this.dark);
}

/// Accent themes offered in Settings. The first is the mockup's green.
const List<AccentOption> kAccents = [
  AccentOption('Sage', Color(0xFF5F7F6E), Color(0xFF9DC0AB)),
  AccentOption('Forest', Color(0xFF2F6B4F), Color(0xFF7FD1A6)),
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
  AccentOption('Moss', Color(0xFF4F6B57), Color(0xFF9CC0A6)),
];

/// Notoo's palette — taken directly from the UI mockup's CSS variables.
class AppColors {
  AppColors._();

  // Light canvas (mockup: --bg / --card / --ink / --mute)
  static const cream = Color(0xFFF7EEE2);
  static const creamSurface = Color(0xFFFCF6EC);
  static const ink = Color(0xFF3A3A34);
  static const inkSoft = Color(0xFF8D8A7E);
  static const hairline = Color(0xFFEFE6D6);

  // Supporting mockup tones
  static const page = Color(0xFFEFE3D3);
  static const navBg = Color(0xFFFBF4E9);
  static const pill = Color(0xFFF0E6D6);
  static const chip = Color(0xFFEFE3D0);
  static const sticky = Color(0xFFF6D9A8);
  static const lockBg = Color(0xFF7D9A86);

  // Dark canvas
  static const darkBg = Color(0xFF221F1B);
  static const darkSurface = Color(0xFF2B2721);
  static const darkInk = Color(0xFFEFE9DD);
  static const darkInkSoft = Color(0xFFA49E90);
  static const darkHairline = Color(0xFF3A342C);

  // AMOLED canvas
  static const amoledBg = Color(0xFF000000);
  static const amoledSurface = Color(0xFF0E0D0B);
  static const amoledInk = Color(0xFFEEEEEE);
  static const amoledInkSoft = Color(0xFF9A958A);
  static const amoledHairline = Color(0xFF262421);

  // Mockup accents, used for note tints and category dots.
  static const green = Color(0xFF5F7F6E);
  static const greenLight = Color(0xFFDFE8DC);
  static const peach = Color(0xFFF2A98A);
  static const yellow = Color(0xFFF5C26B);
  static const blue = Color(0xFF9BB5DC);
  static const purple = Color(0xFFB9A3D6);
  static const pink = Color(0xFFEE9C9C);
  static const grey = Color(0xFFC9C4B6);

  /// Note tints (mockup's card colours).
  static const pastels = <Color>[
    Color(0xFFDFE8DC), // green
    Color(0xFFF8DFCE), // peach
    Color(0xFFFBE9C6), // yellow
    Color(0xFFDCE6F2), // blue
    Color(0xFFE9E0F2), // purple
    Color(0xFFF8DCDC), // pink
  ];

  static const pastelNames = <String>[
    'Sage',
    'Peach',
    'Butter',
    'Sky',
    'Lilac',
    'Blush',
  ];

  static Color pastel(int? i) =>
      i == null ? Colors.transparent : pastels[i % pastels.length];

  /// Canvas / writing-pad backgrounds. Index 0 means "match the theme".
  static const papers = <Color>[
    Color(0xFFF7EEE2), // cream
    Color(0xFFFFFFFF), // white
    Color(0xFFFBF3E4), // parchment
    Color(0xFFEFF6EF), // sage mist
    Color(0xFFFDF1F2), // rose
    Color(0xFFF0F3FA), // blue
    Color(0xFFF5F0FA), // lilac
    Color(0xFF2A2721), // dark
    Color(0xFF000000), // black
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

/// The mockup's soft card shadow: 0 6px 18px rgba(120,100,70,.14)
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x241E140A),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get nav => const [
        BoxShadow(
          color: Color(0x141E140A),
          blurRadius: 14,
          offset: Offset(0, -4),
        ),
      ];
}
