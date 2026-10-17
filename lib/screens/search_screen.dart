import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'editor_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search notes…',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.trim().isEmpty
          ? const EmptyState(
              icon: Icons.search,
              title: 'Search Notoo',
              subtitle: 'Find notes by title or content.',
            )
          : results.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'No matches',
                  subtitle: 'Try a different word.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => NoteCard(
                    note: results[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => EditorScreen(note: results[i])),
                    ),
                  ),
                ),
    );
  }
}
