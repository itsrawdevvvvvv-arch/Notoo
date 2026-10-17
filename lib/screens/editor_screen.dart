import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../data/storage_dir.dart';
import '../editor/embeds.dart';
import '../models/note.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../theme/patterns.dart';
import '../widgets/sticker_library.dart';

/// The note editor — the heart of Notoo.
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
      // Corrupt or legacy content — fall back to a clean document.
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
    if (_isEmpty) return;
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
        _store.deleteForever(_note);
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

  // ---------- Inserting content ----------

  int get _insertIndex =>
      _controller.selection.isValid
          ? _controller.selection.end
          : _controller.document.length - 1;

  void _insertEmbed(String src) {
    final index = _insertIndex;
    _controller.document.insert(index, BlockEmbed.image(src));
    _controller.updateSelection(
      TextSelection.collapsed(offset: index + 1),
      ChangeSource.local,
    );
  }

  void _insertText(String text) {
    final index = _insertIndex;
    _controller.document.insert(index, text);
    _controller.updateSelection(
      TextSelection.collapsed(offset: index + text.length),
      ChangeSource.local,
    );
  }

  Future<String?> _persist(String srcPath) async {
    try {
      final dir = await resolveStorageDir();
      final media = Directory('${dir.path}/media');
      if (!await media.exists()) await media.create(recursive: true);
      final dot = srcPath.lastIndexOf('.');
      final ext = dot >= 0 ? srcPath.substring(dot) : '.jpg';
      final dest =
          '${media.path}/media_${DateTime.now().microsecondsSinceEpoch}$ext';
      await File(srcPath).copy(dest);
      return dest;
    } catch (e) {
      debugPrint('persist failed: $e');
      return null;
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _insertSticker() async {
    final asset = await showStickerPicker(context);
    if (asset == null) return;
    _insertEmbed(asset);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 88);
      if (picked == null) return;
      final saved = await _persist(picked.path);
      if (saved != null) {
        _insertEmbed(saved);
      } else {
        _toast('Could not save that image.');
      }
    } catch (e) {
      _toast('Could not add image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsStore>();

    final paper = settings.editorPaperIndex == 0
        ? theme.scaffoldBackgroundColor
        : AppColors.papers[settings.editorPaperIndex];
    final paperBrightness = ThemeData.estimateBrightnessForColor(paper);
    final onPaper = paperBrightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF2E2A24);

    final paperTheme = theme.copyWith(
      colorScheme: theme.colorScheme
          .copyWith(brightness: paperBrightness, onSurface: onPaper),
      textTheme:
          theme.textTheme.apply(bodyColor: onPaper, displayColor: onPaper),
    );

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
              icon: Icon(
                  _note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
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
      body: PaperBackground(
        pattern: PaperPattern.values[settings.paperPatternIndex],
        color: paper,
        child: Theme(
          data: paperTheme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: TextField(
                  controller: _titleController,
                  readOnly: widget.readOnly,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: onPaper,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: onPaper.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              if (!widget.readOnly)
                _MinimalToolbar(
                  controller: _controller,
                  onSticker: _insertSticker,
                  onImage: () => _pickImage(ImageSource.gallery),
                  onCamera: () => _pickImage(ImageSource.camera),
                  onMore: _showFormatSheet,
                ),
              Divider(height: 1, color: onPaper.withValues(alpha: 0.12)),
              Expanded(
                child: QuillEditor.basic(
                  controller: _controller,
                  config: const QuillEditorConfig(
                    embedBuilders: [NotooImageEmbedBuilder()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Formatting extras ----------

  void _showFormatSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('More formatting',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('Numbered list'),
              onTap: () {
                Navigator.pop(ctx);
                _toggle(Attribute.ol);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_strikethrough),
              title: const Text('Strikethrough'),
              onTap: () {
                Navigator.pop(ctx);
                _toggle(Attribute.strikeThrough);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('Quote'),
              onTap: () {
                Navigator.pop(ctx);
                _toggle(Attribute.blockQuote);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Code block'),
              onTap: () {
                Navigator.pop(ctx);
                _toggle(Attribute.codeBlock);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_clear),
              title: const Text('Clear formatting'),
              onTap: () {
                Navigator.pop(ctx);
                _clearFormat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(Attribute attr) {
    final active =
        _controller.getSelectionStyle().attributes.containsKey(attr.key);
    _controller.formatSelection(active ? Attribute.clone(attr, null) : attr);
  }

  void _clearFormat() {
    for (final a in [
      Attribute.bold,
      Attribute.italic,
      Attribute.underline,
      Attribute.strikeThrough,
      Attribute.h1,
      Attribute.h2,
      Attribute.h3,
      Attribute.ul,
      Attribute.ol,
      Attribute.blockQuote,
      Attribute.codeBlock,
    ]) {
      _controller.formatSelection(Attribute.clone(a, null));
    }
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
                const Text('Export this note',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Save / Share'),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final path =
                            await ExportService.exportNote(_note, format);
                        await ExportService.shareFile(path,
                            text: _note.displayTitle);
                      } catch (e) {
                        _toast('Export failed: $e');
                      }
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
    final theme = Theme.of(context);
    final selected = value == current;
    return GestureDetector(
      onTap: () => onPick(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant)),
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
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Note colour'),
              onTap: () {
                Navigator.pop(ctx);
                _showColorPicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sell_outlined),
              title: const Text('Tags'),
              onTap: () {
                Navigator.pop(ctx);
                _showTagPicker();
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
              const Text('Note colour',
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
    final theme = Theme.of(context);
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
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: index == null
            ? Icon(Icons.block,
                size: 18, color: theme.colorScheme.onSurfaceVariant)
            : (selected
                ? const Icon(Icons.check, size: 18, color: AppColors.ink)
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
                    child: Text('No tags yet — create one below.'),
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
                      icon: const Icon(Icons.add_circle),
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

/// A compact, single-row toolbar — deliberately minimal.
class _MinimalToolbar extends StatelessWidget {
  const _MinimalToolbar({
    required this.controller,
    required this.onSticker,
    required this.onImage,
    required this.onCamera,
    required this.onMore,
  });

  final QuillController controller;
  final VoidCallback onSticker;
  final VoidCallback onImage;
  final VoidCallback onCamera;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        bool active(Attribute a) =>
            controller.getSelectionStyle().attributes.containsKey(a.key);
        void toggle(Attribute a) {
          controller
              .formatSelection(active(a) ? Attribute.clone(a, null) : a);
        }

        Widget btn(IconData icon, {bool on = false, VoidCallback? onTap}) =>
            IconButton(
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              color:
                  on ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              icon: Icon(icon),
              onPressed: onTap,
            );

        return SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              btn(Icons.undo, onTap: controller.undo),
              btn(Icons.redo, onTap: controller.redo),
              _sep(theme),
              btn(Icons.format_bold,
                  on: active(Attribute.bold),
                  onTap: () => toggle(Attribute.bold)),
              btn(Icons.format_italic,
                  on: active(Attribute.italic),
                  onTap: () => toggle(Attribute.italic)),
              btn(Icons.format_underlined,
                  on: active(Attribute.underline),
                  onTap: () => toggle(Attribute.underline)),
              _sep(theme),
              _HeadingMenu(controller: controller, active: active),
              _sep(theme),
              btn(Icons.format_list_bulleted,
                  on: active(Attribute.ul),
                  onTap: () => toggle(Attribute.ul)),
              btn(Icons.checklist,
                  on: active(Attribute.checked),
                  onTap: () => toggle(Attribute.checked)),
              _sep(theme),
              btn(Icons.image_outlined, onTap: onImage),
              btn(Icons.photo_camera_outlined, onTap: onCamera),
              btn(Icons.emoji_emotions_outlined, onTap: onSticker),
              btn(Icons.more_horiz, onTap: onMore),
            ],
          ),
        );
      },
    );
  }

  Widget _sep(ThemeData theme) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: VerticalDivider(
            width: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
      );
}

class _HeadingMenu extends StatelessWidget {
  const _HeadingMenu({required this.controller, required this.active});

  final QuillController controller;
  final bool Function(Attribute) active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = active(Attribute.h1)
        ? 'H1'
        : active(Attribute.h2)
            ? 'H2'
            : active(Attribute.h3)
                ? 'H3'
                : 'Normal';
    return PopupMenuButton<int>(
      tooltip: 'Text style',
      onSelected: (level) {
        if (level == 0) {
          for (final a in [Attribute.h1, Attribute.h2, Attribute.h3]) {
            controller.formatSelection(Attribute.clone(a, null));
          }
        } else {
          controller.formatSelection(level == 1
              ? Attribute.h1
              : (level == 2 ? Attribute.h2 : Attribute.h3));
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 0, child: Text('Normal')),
        PopupMenuItem(value: 1, child: Text('Heading 1')),
        PopupMenuItem(value: 2, child: Text('Heading 2')),
        PopupMenuItem(value: 3, child: Text('Heading 3')),
      ],
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Text(current,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
            Icon(Icons.arrow_drop_down,
                size: 18, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}
