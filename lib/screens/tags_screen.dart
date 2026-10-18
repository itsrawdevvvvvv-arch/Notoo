import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../models/note_tag.dart';
import '../theme/app_colors.dart';
import '../widgets/decor.dart';
import '../widgets/motion.dart';
import '../widgets/ui.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
            child: Row(
              children: [
                const Text('Tags',
                    style:
                        TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: () => _createTag(context),
                  icon: const Icon(Icons.add, size: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: HandText('Tag it so you can find it later',
                      size: 16, align: TextAlign.center),
                ),
                const SizedBox(height: 8),
                if (store.tags.isEmpty)
                  HandText('No tags yet — tap + to add one.',
                      size: 16, align: TextAlign.center),
                for (var i = 0; i < store.tags.length; i++)
                  RiseIn(
                    index: i,
                    child: NotooRow(
                      title: store.tags[i].name,
                      badgeColor: Colors.transparent,
                      badge: const SizedBox.shrink(),
                      leadingDot: AppColors.pastel(store.tags[i].colorIndex),
                      trailing: Text(
                        '${store.notesWithTag(store.tags[i].id)}  ›',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () {},
                      onLongPress: () => _tagMenu(context, store.tags[i]),
                    ),
                  ),
              ],
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
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Create')),
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
