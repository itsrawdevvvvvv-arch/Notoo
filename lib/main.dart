import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/notes_store.dart';
import 'data/settings_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Show any UI build error on screen instead of a blank page.
  ErrorWidget.builder = (details) => Material(
        color: const Color(0xFFF7F3EA),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                'Notoo UI error:\n\n${details.exception}',
                style: const TextStyle(color: Color(0xFF2E2A24), fontSize: 13),
              ),
            ),
          ),
        ),
      );

  FlutterError.onError = (details) => FlutterError.presentError(details);

  // Render the very first frame immediately, with NO async work before it.
  // All initialisation happens inside the widget tree, so the app can never
  // get stuck on a black screen waiting for a plugin.
  runApp(const NotooBootstrap());
}

/// Boots Notoo: draws a frame instantly, loads data in the background, then
/// swaps in the real app (or an error screen if something failed).
class NotooBootstrap extends StatefulWidget {
  const NotooBootstrap({super.key});

  @override
  State<NotooBootstrap> createState() => _NotooBootstrapState();
}

class _NotooBootstrapState extends State<NotooBootstrap> {
  NotesStore? _notes;
  SettingsStore? _settings;
  Object? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final settings = SettingsStore();
    final notes = NotesStore();
    Object? err;
    try {
      await settings.load();
    } catch (e) {
      err = e;
    }
    try {
      await notes.load();
    } catch (e) {
      err ??= e;
    }
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _notes = notes;
      _error = err;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_done) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFFF7F3EA),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF4F6B57)),
          ),
        ),
      );
    }

    if (_error != null) {
      return StartupErrorApp(message: _error.toString());
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NotesStore>.value(value: _notes!),
        ChangeNotifierProvider<SettingsStore>.value(value: _settings!),
      ],
      child: const NotooApp(),
    );
  }
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
