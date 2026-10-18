import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../models/note_folder.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'canvas_editor_screen.dart';

/// Notes inside a single folder.
class FolderNotesScreen extends StatelessWidget {
  const FolderNotesScreen({super.key, required this.folder});
  final NoteFolder folder;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final notes = store.active.where((n) => n.folderId == folder.id).toList();

    return Scaffold(
      appBar: AppBar(title: Text(folder.name)),
      body: notes.isEmpty
          ? const EmptyState(
              icon: Icons.note_outlined,
              title: 'No notes here yet',
              subtitle: 'Notes you move into this folder will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => NoteCard(
                note: notes[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => CanvasEditorScreen(note: notes[i])),
                ),
              ),
            ),
    );
  }
}
