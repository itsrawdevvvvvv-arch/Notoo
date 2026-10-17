import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../models/note_folder.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/motion.dart';
import 'folder_notes_screen.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();

    return SafeArea(
      child: Column(
        children: [
          _Header(
            title: 'Folders',
            onAdd: () => _createFolder(context),
          ),
          Expanded(
            child: store.folders.isEmpty
                ? const EmptyState(
                    icon: Icons.folder_outlined,
                    title: 'No folders yet',
                    subtitle:
                        'Create folders to keep your notes organised.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: store.folders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final f = store.folders[i];
                      return RiseIn(
                        index: i,
                        child: _FolderTile(
                          folder: f,
                          count: store.notesInFolder(f.id),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FolderNotesScreen(folder: f),
                            ),
                          ),
                          onLongPress: () => _folderMenu(context, f),
                        ),
                      );
                    },
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create'),
          ),
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

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onAdd});
  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800)),
          const Spacer(),
          IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 26)),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.count,
    required this.onTap,
    required this.onLongPress,
  });

  final NoteFolder folder;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.pastel(folder.colorIndex),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder_rounded,
                    color: AppColors.ink, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(folder.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('$count notes',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
