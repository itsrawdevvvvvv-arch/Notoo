import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The three appearances Notoo supports.
enum Appearance { light, dark, amoled }

class AppTheme {
  AppTheme._();

  static bool isLight(Appearance a) => a == Appearance.light;

  static Color bg(Appearance a) {
    switch (a) {
      case Appearance.light:
        return AppColors.cream;
      case Appearance.dark:
        return AppColors.darkBg;
      case Appearance.amoled:
        return AppColors.amoledBg;
    }
  }

  static Color surface(Appearance a) {
    switch (a) {
      case Appearance.light:
        return AppColors.creamSurface;
      case Appearance.dark:
        return AppColors.darkSurface;
      case Appearance.amoled:
        return AppColors.amoledSurface;
    }
  }

  static Color ink(Appearance a) {
    switch (a) {
      case Appearance.light:
        return AppColors.ink;
      case Appearance.dark:
        return AppColors.darkInk;
      case Appearance.amoled:
        return AppColors.amoledInk;
    }
  }

  static Color softInk(Appearance a) {
    switch (a) {
      case Appearance.light:
        return AppColors.inkSoft;
      case Appearance.dark:
        return AppColors.darkInkSoft;
      case Appearance.amoled:
        return AppColors.amoledInkSoft;
    }
  }

  static Color hairline(Appearance a) {
    switch (a) {
      case Appearance.light:
        return AppColors.hairline;
      case Appearance.dark:
        return AppColors.darkHairline;
      case Appearance.amoled:
        return AppColors.amoledHairline;
    }
  }

  static Color accentFor(Appearance a, AccentOption accent) =>
      isLight(a) ? accent.light : accent.dark;

  /// Builds the full theme from appearance + accent + font choice.
  static ThemeData build({
    required Appearance appearance,
    required AccentOption accent,
    required String fontFamily,
  }) {
    final light = isLight(appearance);
    final brightness = light ? Brightness.light : Brightness.dark;
    final bgC = bg(appearance);
    final surfaceC = surface(appearance);
    final inkC = ink(appearance);
    final softC = softInk(appearance);
    final lineC = hairline(appearance);
    final seed = light ? accent.light : accent.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(
      primary: seed,
      surface: surfaceC,
      onSurface: inkC,
      outlineVariant: lineC,
    );

    var theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bgC,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: bgC,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: inkC,
      ),
      dividerTheme: DividerThemeData(color: lineC, thickness: 1, space: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seed,
        foregroundColor: light ? Colors.white : const Color(0xFF12110F),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceC,
        indicatorColor: seed.withValues(alpha: 0.18),
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PlayfulPageTransitionsBuilder(),
          TargetPlatform.iOS: PlayfulPageTransitionsBuilder(),
        },
      ),
    );

    if (fontFamily != 'System') {
      theme = theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: fontFamily),
        primaryTextTheme:
            theme.primaryTextTheme.apply(fontFamily: fontFamily),
      );
    }
    return theme;
  }
}

/// A gentle fade + rise transition used for every page push.
class PlayfulPageTransitionsBuilder extends PageTransitionsBuilder {
  const PlayfulPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
