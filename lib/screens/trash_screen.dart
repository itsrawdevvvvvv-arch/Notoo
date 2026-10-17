import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/motion.dart';
import '../widgets/note_card.dart';
import 'editor_screen.dart';

/// Trash — opened from Settings (no longer a bottom-bar tab).
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final notes = store.trashed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (notes.isNotEmpty)
            TextButton(
              onPressed: () => _confirmEmpty(context),
              child: const Text('Empty trash'),
            ),
        ],
      ),
      body: notes.isEmpty
          ? const EmptyState(
              icon: Icons.delete_outline,
              title: 'Trash is empty',
              subtitle: 'Deleted notes stay here until you remove them.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => RiseIn(
                index: i,
                child: NoteCard(
                  note: notes[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            EditorScreen(note: notes[i], readOnly: true)),
                  ),
                  trailing: TextButton(
                    onPressed: () => store.restoreNote(notes[i]),
                    child: const Text('Restore'),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _confirmEmpty(BuildContext context) async {
    final store = context.read<NotesStore>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty trash?'),
        content: const Text(
            'This permanently deletes all notes in the trash. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
    if (ok == true) await store.emptyTrash();
  }
}
