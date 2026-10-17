import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../models/note.dart';
import '../widgets/decor.dart';
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

    return BlobBackground(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: (pinned.isEmpty && recent.isEmpty)
                  ? const EmptyState(
                      icon: Icons.edit_note,
                      title: 'No notes yet',
                      subtitle:
                          'Tap + to create your first note.\nGood ideas live here.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      children: [
                        _Greeting(settings: settings),
                        const SizedBox(height: 14),
                        _SearchPill(),
                        const SizedBox(height: 20),
                        if (pinned.isNotEmpty) ...[
                          _SectionHeader(
                              title: 'Pinned', count: pinned.length),
                          _NotesBlock(notes: pinned, isGrid: isGrid),
                          const SizedBox(height: 22),
                        ],
                        if (recent.isNotEmpty) ...[
                          _SectionHeader(
                              title: 'All Notes', count: recent.length),
                          _NotesBlock(notes: recent, isGrid: isGrid),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.settings});
  final SettingsStore settings;

  String get _timeOfDay {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notoo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$_timeOfDay,',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                settings.userName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const StickyNote(text: 'Small\nnotes.\nBig ideas.', rotation: 0.06),
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Bouncy(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(Icons.search,
                size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(
              'Search notes, tags, folders…',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 12, top: 2),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Text('$count',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
        ],
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
          childAspectRatio: 0.84,
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
