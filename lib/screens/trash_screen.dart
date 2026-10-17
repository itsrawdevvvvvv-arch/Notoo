import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'editor_screen.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final notes = store.trashed;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: AppColors.greenDeep),
                const SizedBox(width: 10),
                const Text('Trash',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
                const Spacer(),
                if (notes.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmEmpty(context),
                    child: const Text('Empty trash'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const EmptyState(
                    icon: Icons.delete_outline,
                    title: 'Trash is empty',
                    subtitle: 'Deleted notes stay here until you remove them.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => NoteCard(
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
        ],
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
