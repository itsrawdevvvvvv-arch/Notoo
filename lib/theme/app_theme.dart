import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The three appearances Notoo supports.
enum Appearance { light, dark, amoled }

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: AppColors.cream,
        surface: AppColors.creamSurface,
        ink: AppColors.ink,
        inkSoft: AppColors.inkSoft,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBg,
        surface: AppColors.darkSurface,
        ink: AppColors.darkInk,
        inkSoft: AppColors.darkInkSoft,
      );

  static ThemeData amoled() => _build(
        brightness: Brightness.dark,
        background: AppColors.amoledBg,
        surface: AppColors.amoledSurface,
        ink: AppColors.amoledInk,
        inkSoft: AppColors.amoledInkSoft,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color ink,
    required Color inkSoft,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.green,
      surface: surface,
      onSurface: ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: ink,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
