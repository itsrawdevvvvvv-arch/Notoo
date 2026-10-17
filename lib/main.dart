import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/notes_store.dart';
import 'data/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsStore();
  await settings.load();

  final notes = NotesStore();
  await notes.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NotesStore>.value(value: notes),
        ChangeNotifierProvider<SettingsStore>.value(value: settings),
      ],
      child: const NotooApp(),
    ),
  );
}
