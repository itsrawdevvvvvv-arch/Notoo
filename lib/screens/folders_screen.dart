import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../models/note_folder.dart';
import '../theme/app_colors.dart';
import '../widgets/decor.dart';
import '../widgets/motion.dart';
import '../widgets/ui.dart';
import 'folder_notes_screen.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final doodle = doodleAsset(2);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _Bar(
            title: 'Folders',
            onAdd: () => _createFolder(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              children: [
                if (doodle != null)
                  ArtCaption(asset: doodle, caption: 'Organise your chaos'),
                const SizedBox(height: 10),
                if (store.folders.isEmpty)
                  HandText('No folders yet — tap + to add one.',
                      size: 16, align: TextAlign.center),
                for (var i = 0; i < store.folders.length; i++)
                  RiseIn(
                    index: i,
                    child: NotooRow(
                      title: store.folders[i].name,
                      subtitle: '${store.notesInFolder(store.folders[i].id)} notes',
                      badgeColor: AppColors.pastel(store.folders[i].colorIndex),
                      badge: Icon(Icons.folder_rounded,
                          size: 18, color: AppColors.ink),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              FolderNotesScreen(folder: store.folders[i]),
                        ),
                      ),
                      onLongPress: () =>
                          _folderMenu(context, store.folders[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createFolder(BuildContext context) async {
    final store = context.read<NotesStore>();
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Create')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await store.addFolder(name.trim(),
          colorIndex: store.folders.length % AppColors.pastels.length);
    }
  }

  void _folderMenu(BuildContext context, NoteFolder f) {
    final store = context.read<NotesStore>();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete folder'),
              onTap: () {
                Navigator.pop(ctx);
                store.deleteFolder(f);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.title, required this.onAdd});
  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add, size: 22)),
        ],
      ),
    );
  }
}
