import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../theme/app_colors.dart';
import '../widgets/decor.dart';
import '../widgets/motion.dart';
import '../widgets/ui.dart';
import 'canvas_editor_screen.dart';
import 'search_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final notes = store.archived;
    final doodle = doodleAsset(3);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
            child: Row(
              children: [
                const Text('Archive',
                    style:
                        TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              children: [
                if (doodle != null)
                  ArtCaption(asset: doodle, caption: 'Past notes, still useful.'),
                const SizedBox(height: 10),
                if (notes.isEmpty)
                  HandText('Nothing archived yet.', size: 16, align: TextAlign.center),
                for (var i = 0; i < notes.length; i++)
                  RiseIn(
                    index: i,
                    child: NotooRow(
                      title: notes[i].displayTitle,
                      subtitle: notes[i].preview,
                      badgeColor: AppColors.chip,
                      badge: const Icon(Icons.description_outlined,
                          size: 18, color: AppColors.ink),
                      trailing: MiniButton(
                        label: 'Unarchive',
                        onTap: () => store.toggleArchive(notes[i]),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CanvasEditorScreen(note: notes[i]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
