import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../models/note.dart';
import '../widgets/empty_state.dart';
import '../widgets/motion.dart';
import '../widgets/note_card.dart';
import 'editor_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final settings = context.watch<SettingsStore>();
    final pinned = store.pinned;
    final recent = store.unpinned;
    final isGrid = settings.viewMode == ViewMode.grid;

    return SafeArea(
      child: Column(
        children: [
          _Header(settings: settings),
          Expanded(
            child: (pinned.isEmpty && recent.isEmpty)
                ? const EmptyState(
                    icon: Icons.edit_note,
                    title: 'No notes yet',
                    subtitle:
                        'Tap + to create your first note.\nGood ideas live here.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        const _SectionLabel('Pinned'),
                        _NotesBlock(notes: pinned, isGrid: isGrid),
                        const SizedBox(height: 18),
                      ],
                      if (recent.isNotEmpty) ...[
                        const _SectionLabel('Recent Notes'),
                        _NotesBlock(notes: recent, isGrid: isGrid),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.settings});
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGrid = settings.viewMode == ViewMode.grid;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notoo',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Good ideas live here.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.grid_view_rounded,
                        size: 15, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('All Notes',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary)),
                  ],
                ),
              ),
              const Spacer(),
              _ViewToggle(
                isGrid: isGrid,
                onChanged: (g) =>
                    settings.setViewMode(g ? ViewMode.grid : ViewMode.list),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isGrid, required this.onChanged});
  final bool isGrid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(theme, Icons.grid_view_rounded, isGrid, () => onChanged(true)),
          _btn(theme, Icons.view_agenda_outlined, !isGrid, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _btn(ThemeData theme, IconData icon, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(7),
        child: Icon(icon,
            size: 18,
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10, top: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _NotesBlock extends StatelessWidget {
  const _NotesBlock({required this.notes, required this.isGrid});

  final List<Note> notes;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (_, i) =>
            RiseIn(index: i, child: _card(context, notes[i])),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < notes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RiseIn(index: i, child: _card(context, notes[i])),
          ),
      ],
    );
  }

  Widget _card(BuildContext context, Note n) => NoteCard(
        note: n,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EditorScreen(note: n)),
        ),
      );
}
