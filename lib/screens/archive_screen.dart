import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/motion.dart';
import '../widgets/note_card.dart';
import 'editor_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final notes = store.archived;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                const Text('Archive',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Empty archive',
                    subtitle: 'Your archived notes will appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => RiseIn(
                      index: i,
                      child: NoteCard(
                        note: notes[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => EditorScreen(note: notes[i])),
                        ),
                        trailing: TextButton(
                          onPressed: () => store.toggleArchive(notes[i]),
                          child: const Text('Unarchive'),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
