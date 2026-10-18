import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../models/note.dart';
import '../theme/app_colors.dart';
import '../widgets/decor.dart';
import '../widgets/motion.dart';
import '../widgets/note_card.dart';
import '../widgets/ui.dart';
import 'canvas_editor_screen.dart';
import 'editor_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final settings = context.watch<SettingsStore>();
    final pinned = store.pinned;
    final recent = store.unpinned;
    final isGrid = settings.viewMode == ViewMode.grid;
    final hasAny = pinned.isNotEmpty || recent.isNotEmpty;

    return BlobField(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            _Header(),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: HandText(
                      '${_greeting()},\n${settings.userName}',
                      size: 26,
                    ),
                  ),
                ),
                const StickyNote(text: 'Small notes.\nBig ideas.'),
              ],
            ),
            const SizedBox(height: 14),
            FractionallySizedBox(
              widthFactor: 0.72,
              alignment: Alignment.centerLeft,
              child: SearchBarPill(
                hint: 'Search notes, tags…',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
              ),
            ),
            if (!hasAny)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    if (doodleAsset(0) != null)
                      Floating(
                        child: Doodle(
                            asset: doodleAsset(0)!, size: 150, rotation: -0.03),
                      ),
                    const SizedBox(height: 12),
                    HandText('No notes yet — tap + to start.',
                        size: 18, align: TextAlign.center),
                  ],
                ),
              ),
            if (pinned.isNotEmpty) ...[
              const SectionHeader(title: 'Pinned', trailing: 'See all'),
              _Grid(notes: pinned, isGrid: isGrid),
            ],
            if (recent.isNotEmpty) ...[
              SectionHeader(
                title: 'All Notes',
                trailing: isGrid ? 'List' : 'Grid',
                onTrailingTap: () => settings.setViewMode(
                    isGrid ? ViewMode.list : ViewMode.grid),
              ),
              _Grid(notes: recent, isGrid: isGrid),
            ],
          ],
        ),
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.primary, width: 3),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          'Notoo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.search, size: 20),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.notes, required this.isGrid});

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
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (_, i) => RiseIn(index: i, child: _card(context, notes[i])),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < notes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RiseIn(index: i, child: _card(context, notes[i])),
          ),
      ],
    );
  }

  Widget _card(BuildContext context, Note n) => NoteCard(
        note: n,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => n.kind == NoteKind.canvas
                ? CanvasEditorScreen(note: n)
                : EditorScreen(note: n),
          ),
        ),
      );
}
