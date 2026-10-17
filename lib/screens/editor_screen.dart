import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../models/note.dart';
import '../models/note_tag.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';

/// The note editor — the heart of Notoo.
///
/// Built on `flutter_quill` (a battle-tested rich-text engine) rather than a
/// hand-rolled field, so caret/IME behaviour stays solid. Saves are debounced
/// off the keystroke path so typing never blocks on disk I/O.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.note, this.readOnly = false});

  final Note note;
  final bool readOnly;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late Note _note;
  late QuillController _controller;
  late TextEditingController _titleController;
  late NotesStore _store;

  Timer? _debounce;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleController = TextEditingController(text: _note.title);
    _controller = QuillController(
      document: _loadDocument(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _controller.readOnly = widget.readOnly;
    _titleController.addListener(_scheduleSave);
    _controller.addListener(_scheduleSave);
  }

  Document _loadDocument() {
    try {
      if (_note.deltaJson.isNotEmpty) {
        return Document.fromJson(_note.deltaJson);
      }
    } catch (_) {
      // Corrupt or legacy content — fall back to a clean document rather
      // than crashing the editor.
    }
    return Document();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = context.read<NotesStore>();
  }

  void _scheduleSave() {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _save);
  }

  bool get _isEmpty =>
      _titleController.text.trim().isEmpty &&
      _controller.document.toPlainText().trim().isEmpty;

  Future<void> _save() async {
    if (!_dirty || widget.readOnly) return;
    _dirty = false;
    _note.title = _titleController.text;
    _note.deltaJson = _controller.document.toDelta().toJson();
    _note.plainText = _controller.document.toPlainText();
    if (_isEmpty) return; // don't persist blank notes
    await _store.updateNote(_note);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (!widget.readOnly) {
      _note.title = _titleController.text;
      _note.deltaJson = _controller.document.toDelta().toJson();
      _note.plainText = _controller.document.toPlainText();
      if (_isEmpty) {
        _store.deleteForever(_note); // discard an untouched blank note
      } else {
        _store.updateNote(_note);
      }
    }
    _titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _togglePin() async {
    setState(() => _note.isPinned = !_note.isPinned);
    await _store.togglePin(_note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (!widget.readOnly)
            IconButton(
              tooltip: _note.isPinned ? 'Unpin' : 'Pin',
              icon: Icon(_note.isPinned
                  ? Icons.push_pin
                  : Icons.push_pin_outlined),
              onPressed: _togglePin,
            ),
          IconButton(
            tooltip: 'Export',
            icon: const Icon(Icons.ios_share),
            onPressed: _showExportSheet,
          ),
          if (!widget.readOnly)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showMoreSheet,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: TextField(
              controller: _titleController,
              readOnly: widget.readOnly,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          if (!widget.readOnly)
            QuillSimpleToolbar(
              controller: _controller,
              config: const QuillSimpleToolbarConfig(),
            ),
          const Divider(height: 1, color: AppColors.hairline),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              config: const QuillEditorConfig(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Sheets ----------

  void _showExportSheet() {
    final settings = context.read<SettingsStore>();
    ExportFormat format = settings.exportFormat;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Export what?',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('This note is exported by default.',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                const SizedBox(height: 12),
                const Text('Format',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    _fmtChip('PDF', ExportFormat.pdf, format,
                        (f) => setSheet(() => format = f)),
                    const SizedBox(width: 10),
                    _fmtChip('.txt', ExportFormat.txt, format,
                        (f) => setSheet(() => format = f)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Save / Share'),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final path =
                          await ExportService.exportNote(_note, format);
                      await ExportService.shareFile(path,
                          text: _note.displayTitle);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fmtChip(
    String label,
    ExportFormat value,
    ExportFormat current,
    ValueChanged<ExportFormat> onPick,
  ) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onPick(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.green.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
              color: selected ? AppColors.green : AppColors.hairline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.greenDeep : AppColors.inkSoft)),
      ),
    );
  }

  void _showMoreSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sell_outlined),
              title: const Text('Tags'),
              onTap: () {
                Navigator.pop(ctx);
                _showTagPicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Colour'),
              onTap: () {
                Navigator.pop(ctx);
                _showColorPicker();
              },
            ),
            ListTile(
              leading: Icon(_note.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined),
              title: Text(_note.isArchived ? 'Unarchive' : 'Archive'),
              onTap: () async {
                Navigator.pop(ctx);
                await _store.toggleArchive(_note);
                if (mounted) setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(_note.isTrashed ? 'Delete forever' : 'Move to trash'),
              onTap: () async {
                Navigator.pop(ctx);
                if (_note.isTrashed) {
                  await _store.deleteForever(_note);
                } else {
                  await _store.trashNote(_note);
                }
                if (mounted) Navigator.of(context).maybePop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Colour',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _swatch(ctx, null),
                  for (var i = 0; i < AppColors.pastels.length; i++)
                    _swatch(ctx, i),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swatch(BuildContext sheetCtx, int? index) {
    final selected = _note.colorIndex == index;
    return GestureDetector(
      onTap: () async {
        setState(() => _note.colorIndex = index);
        await _store.updateNote(_note);
        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: index == null ? Colors.transparent : AppColors.pastel(index),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.green : AppColors.hairline,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: index == null
            ? const Icon(Icons.block, size: 18, color: AppColors.inkSoft)
            : (selected
                ? const Icon(Icons.check, size: 18, color: AppColors.greenDeep)
                : null),
      ),
    );
  }

  void _showTagPicker() {
    final all = _store.tags;
    final selected = Set<String>.from(_note.tagIds);
    final newTagController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tags',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                if (all.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No tags yet — create one below.',
                        style: TextStyle(color: AppColors.inkSoft)),
                  ),
                for (final t in all)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: selected.contains(t.id),
                    title: Text(t.name),
                    onChanged: (v) => setSheet(() {
                      if (v == true) {
                        selected.add(t.id);
                      } else {
                        selected.remove(t.id);
                      }
                    }),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newTagController,
                        decoration: const InputDecoration(
                          hintText: 'New tag…',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.green),
                      onPressed: () async {
                        final name = newTagController.text.trim();
                        if (name.isEmpty) return;
                        final t = await _store.addTag(name);
                        newTagController.clear();
                        setSheet(() => selected.add(t.id));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green),
                    onPressed: () async {
                      _note.tagIds = selected.toList();
                      await _store.updateNote(_note);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
