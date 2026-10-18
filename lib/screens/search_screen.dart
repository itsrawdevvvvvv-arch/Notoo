import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../models/note.dart';
import '../theme/app_colors.dart';
import '../widgets/decor.dart';
import '../widgets/ui.dart';
import 'canvas_editor_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NotesStore>();
    final results = store.search(_query);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.pill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.search,
                    size: 17, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search notes…',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                    child: Icon(Icons.close,
                        size: 18, color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in ['All', 'Tag', 'Folder', 'Date', 'Has image', 'Pinned'])
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: c == 'All' ? theme.colorScheme.primary : AppColors.chip,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: c == 'All' ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
            ],
          ),
          const SectionHeader(title: 'Results'),
          if (_query.trim().isEmpty)
            HandText('Start typing to search.', size: 16)
          else if (results.isEmpty)
            HandText('Nothing found.', size: 16),
          for (final n in results)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: NotooRow(
                title: n.displayTitle,
                subtitle: n.preview,
                badgeColor: AppColors.chip,
                badge: const Icon(Icons.description_outlined,
                    size: 18, color: AppColors.ink),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CanvasEditorScreen(note: n),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
