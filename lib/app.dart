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

    return MaterialApp(
      title: 'Notoo',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeOutCubic,
      theme: AppTheme.build(
        appearance: settings.appearance,
        accent: settings.accent,
        fontFamily: settings.fontFamily,
      ),
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
}
