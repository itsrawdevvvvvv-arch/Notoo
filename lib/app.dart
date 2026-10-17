import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import 'data/settings_store.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

class NotooApp extends StatelessWidget {
  const NotooApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();
    final isLight = settings.appearance == Appearance.light;

    return MaterialApp(
      title: 'Notoo',
      debugShowCheckedModeBanner: false,
      theme: _applyFont(AppTheme.light(), settings),
      darkTheme: _applyFont(
        settings.appearance == Appearance.amoled
            ? AppTheme.amoled()
            : AppTheme.dark(),
        settings,
      ),
      themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeShell(),
    );
  }

  /// Applies the chosen font family without rebuilding the whole theme.
  ThemeData _applyFont(ThemeData base, SettingsStore settings) {
    if (settings.fontFamily == 'System') return base;
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: settings.fontFamily),
      primaryTextTheme:
          base.primaryTextTheme.apply(fontFamily: settings.fontFamily),
    );
  }
}
