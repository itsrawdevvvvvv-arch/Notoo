import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import 'archive_screen.dart';
import 'editor_screen.dart';
import 'folders_screen.dart';
import 'home_screen.dart';
import 'tags_screen.dart';
import 'trash_screen.dart';

/// Bottom-navigation shell holding the five primary destinations.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    FoldersScreen(),
    TagsScreen(),
    ArchiveScreen(),
    TrashScreen(),
  ];

  Future<void> _newNote() async {
    final store = context.read<NotesStore>();
    final note = await store.addNote();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditorScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _newNote,
              tooltip: 'New note',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Folders'),
          NavigationDestination(
              icon: Icon(Icons.sell_outlined),
              selectedIcon: Icon(Icons.sell),
              label: 'Tags'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Archive'),
          NavigationDestination(
              icon: Icon(Icons.delete_outline),
              selectedIcon: Icon(Icons.delete),
              label: 'Trash'),
        ],
      ),
    );
  }
}
