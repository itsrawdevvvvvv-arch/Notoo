import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../models/note.dart';
import '../theme/app_colors.dart';
import 'archive_screen.dart';
import 'canvas_editor_screen.dart';
import 'folders_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'tags_screen.dart';

/// Bottom-navigation shell. Bar: Home · Folders · Tags · Archive · Settings.
/// Trash lives inside Settings.
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
    SettingsScreen(),
  ];

  Future<void> _newNote() async {
    final store = context.read<NotesStore>();
    final note = await store.addNote(kind: NoteKind.canvas);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CanvasEditorScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.015),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey<int>(_index), child: _screens[_index]),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _newNote,
              tooltip: 'New note',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: _NotooNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _NotooNav extends StatelessWidget {
  const _NotooNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.folder_outlined, 'Folders'),
    (Icons.sell_outlined, 'Tags'),
    (Icons.inventory_2_outlined, 'Archive'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      decoration: BoxDecoration(
        color: light ? AppColors.navBg : theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: AppShadows.nav,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _items.length; i++)
            _NavItem(
              icon: _items[i].$1,
              label: _items[i].$2,
              on: i == index,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        on ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: on ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: on
                      ? theme.colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 19, color: color),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
