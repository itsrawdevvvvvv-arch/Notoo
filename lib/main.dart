import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/notes_store.dart';
import 'data/settings_store.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Show any UI build error on screen instead of a blank page, so problems
    // are visible (and screenshot-able) rather than a silent grey screen.
    ErrorWidget.builder = (details) => Material(
          color: const Color(0xFFF7F3EA),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  'Notoo UI error:\n\n${details.exception}',
                  style: const TextStyle(
                      color: Color(0xFF2E2A24), fontSize: 13),
                ),
              ),
            ),
          ),
        );

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };

    final settings = SettingsStore();
    final notes = NotesStore();

    // Startup must never be fatal: if a store fails to load we still launch
    // the app and show what went wrong.
    Object? startupError;
    try {
      await settings.load();
    } catch (e) {
      startupError = e;
    }
    try {
      await notes.load();
    } catch (e) {
      startupError ??= e;
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NotesStore>.value(value: notes),
          ChangeNotifierProvider<SettingsStore>.value(value: settings),
        ],
        child: startupError == null
            ? const NotooApp()
            : StartupErrorApp(message: startupError.toString()),
      ),
    );
  }, (error, stack) {
    debugPrint('Notoo uncaught error: $error');
  });
}

/// Shown only when the app could not finish starting up.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF7F3EA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 44, color: Color(0xFF4F6B57)),
                    const SizedBox(height: 14),
                    const Text(
                      'Notoo could not start',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2A24)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B6459)),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Please send a screenshot of this screen.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6B6459)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
