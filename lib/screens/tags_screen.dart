import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../models/note_tag.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                const Text('Tags',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(
                  onPressed: () => _createTag(context),
                  icon: const Icon(Icons.add, size: 26),
                ),
              ],
            ),
          ),
          Expanded(
            child: store.tags.isEmpty
                ? const EmptyState(
                    icon: Icons.sell_outlined,
                    title: 'No tags yet',
                    subtitle: 'Add tags to find your notes faster.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: store.tags.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final t = store.tags[i];
                      return Material(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          leading: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.pastel(t.colorIndex),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(t.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          trailing: Text('${store.notesWithTag(t.id)}',
                              style: const TextStyle(
                                  color: AppColors.inkSoft,
                                  fontWeight: FontWeight.w600)),
                          onLongPress: () => _tagMenu(context, t),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _createTag(BuildContext context) async {
    final store = context.read<NotesStore>();
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tag name'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await store.addTag(name.trim(),
          colorIndex: store.tags.length % AppColors.pastels.length);
    }
  }

  void _tagMenu(BuildContext context, NoteTag t) {
    final store = context.read<NotesStore>();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete tag'),
              onTap: () {
                Navigator.pop(ctx);
                store.deleteTag(t);
              },
            ),
          ],
        ),
      ),
    );
  }
}
