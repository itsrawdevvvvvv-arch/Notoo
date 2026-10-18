import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../data/storage_dir.dart';
import '../models/canvas_element.dart';
import '../models/note.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../theme/patterns.dart';
import '../widgets/sticker_library.dart';

/// A free-form canvas note: drop text, images and stickers anywhere, then
/// drag / resize / rotate each one freely. Pan and zoom with two fingers.
class CanvasEditorScreen extends StatefulWidget {
  const CanvasEditorScreen({super.key, required this.note});

  final Note note;

  @override
  State<CanvasEditorScreen> createState() => _CanvasEditorScreenState();
}

class _CanvasEditorScreenState extends State<CanvasEditorScreen> {
  static const double _canvasSize = 2400;

  late Note _note;
  final List<CanvasElement> _els = [];
  String? _selected;
  late NotesStore _store;
  Timer? _debounce;
  final TransformationController _tc = TransformationController();

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _els.addAll(_note.canvas);
    // Any older, text-only note is carried onto the canvas as a text block,
    // so every note opens as a canvas from now on.
    if (_els.isEmpty && _note.plainText.trim().isNotEmpty) {
      _els.add(CanvasElement.create(ElementKind.text)
        ..text = _note.plainText.trim()
        ..x = 40
        ..y = 60
        ..w = 300
        ..h = 220
        ..fontSize = 16);
    }
    _note.kind = NoteKind.canvas;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = context.read<NotesStore>();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _save();
    _tc.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _save);
  }

  Future<void> _save() async {
    _note.canvas = _els.map((e) => e.copy()).toList();
    _note.plainText = _els
        .where((e) => e.kind == ElementKind.text)
        .map((e) => e.text)
        .join('\n');
    if (_note.title.trim().isEmpty && _els.isEmpty) return;
    await _store.updateNote(_note);
  }

  double get _scale => _tc.value.getMaxScaleOnAxis();

  CanvasElement? get _selEl {
    for (final e in _els) {
      if (e.id == _selected) return e;
    }
    return null;
  }

  // ---------- Adding ----------

  void _addText() {
    final el = CanvasElement.create(ElementKind.text)
      ..text = 'Write here'
      ..x = 60
      ..y = 80
      ..w = 240
      ..h = 70
      ..fontSize = 20;
    setState(() {
      _els.add(el);
      _selected = el.id;
    });
    _scheduleSave();
    _editText(el);
  }

  Future<void> _addImage(ImageSource source) async {
    try {
      final picked =
          await ImagePicker().pickImage(source: source, imageQuality: 88);
      if (picked == null) return;
      final path = await _persist(picked.path);
      if (path == null) return;
      setState(() {
        _els.add(CanvasElement.create(ElementKind.image)
          ..src = path
          ..x = 80
          ..y = 120
          ..w = 220
          ..h = 220);
      });
      _scheduleSave();
    } catch (e) {
      _toast('Could not add image: $e');
    }
  }

  Future<void> _addSticker() async {
    final asset = await showStickerPicker(context);
    if (asset == null) return;
    setState(() {
      _els.add(CanvasElement.create(ElementKind.sticker)
        ..src = asset
        ..x = 120
        ..y = 160
        ..w = 120
        ..h = 120);
    });
    _scheduleSave();
  }

  Future<String?> _persist(String src) async {
    try {
      final dir = await resolveStorageDir();
      final media = Directory('${dir.path}/media');
      if (!await media.exists()) await media.create(recursive: true);
      final dot = src.lastIndexOf('.');
      final ext = dot >= 0 ? src.substring(dot) : '.jpg';
      final dest =
          '${media.path}/media_${DateTime.now().microsecondsSinceEpoch}$ext';
      await File(src).copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  // ---------- Editing ----------

  void _editText(CanvasElement el) {
    final controller = TextEditingController(text: el.text);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: 18 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Text',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: null,
                style: TextStyle(
                  fontSize: el.fontSize,
                  fontWeight: el.bold ? FontWeight.w700 : FontWeight.w400,
                  fontStyle: el.italic ? FontStyle.italic : FontStyle.normal,
                  color: kInkColors[el.colorIndex % kInkColors.length],
                ),
                decoration: const InputDecoration(
                  hintText: 'Type something…',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => el.text = v),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _toolToggle(Icons.format_bold, el.bold, () {
                    setSheet(() => el.bold = !el.bold);
                    setState(() {});
                  }),
                  _toolToggle(Icons.format_italic, el.italic, () {
                    setSheet(() => el.italic = !el.italic);
                    setState(() {});
                  }),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setSheet(() => el.fontSize = (el.fontSize - 2).clamp(10, 72));
                      setState(() {});
                    },
                    icon: const Icon(Icons.text_decrease),
                  ),
                  IconButton(
                    onPressed: () {
                      setSheet(() => el.fontSize = (el.fontSize + 2).clamp(10, 72));
                      setState(() {});
                    },
                    icon: const Icon(Icons.text_increase),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                children: [
                  for (var i = 0; i < kInkColors.length; i++)
                    GestureDetector(
                      onTap: () {
                        setSheet(() => el.colorIndex = i);
                        setState(() {});
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: kInkColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: el.colorIndex == i
                                ? Theme.of(ctx).colorScheme.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {});
                    _scheduleSave();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolToggle(IconData icon, bool on, VoidCallback onTap) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon,
          color: on ? theme.colorScheme.primary : theme.colorScheme.onSurface),
    );
  }

  void _deleteSelected() {
    if (_selected == null) return;
    setState(() {
      _els.removeWhere((e) => e.id == _selected);
      _selected = null;
    });
    _scheduleSave();
  }

  void _bringToFront() {
    final el = _selEl;
    if (el == null) return;
    setState(() {
      _els.remove(el);
      _els.add(el);
    });
    _scheduleSave();
  }

  void _setColor(int index) {
    final el = _selEl;
    if (el == null) return;
    setState(() => el.colorIndex = index);
    _scheduleSave();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsStore>();
    final paper = settings.editorPaperIndex == 0
        ? theme.scaffoldBackgroundColor
        : AppColors.papers[settings.editorPaperIndex];
    final darkPaper =
        ThemeData.estimateBrightnessForColor(paper) == Brightness.dark;

    return Scaffold(
      backgroundColor: darkPaper ? const Color(0xFF14120F) : AppColors.page,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: TextFormField(
          initialValue: _note.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            hintText: 'Untitled',
            border: InputBorder.none,
            isDense: true,
          ),
          onChanged: (v) {
            _note.title = v;
            _scheduleSave();
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Export',
            icon: const Icon(Icons.ios_share),
            onPressed: _showExport,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRect(
              child: InteractiveViewer(
                transformationController: _tc,
                constrained: false,
                minScale: 0.4,
                maxScale: 3,
                boundaryMargin: const EdgeInsets.all(600),
                child: GestureDetector(
                  onTap: () => setState(() => _selected = null),
                  child: SizedBox(
                    width: _canvasSize,
                    height: _canvasSize,
                    child: PaperBackground(
                      pattern: PaperPattern.values[settings.paperPatternIndex],
                      color: paper,
                      child: Stack(
                        children: [
                          for (final el in _els)
                            Positioned(
                              left: el.x,
                              top: el.y,
                              child: Transform.rotate(
                                angle: el.rotation,
                                child: _CanvasItem(
                                  el: el,
                                  selected: el.id == _selected,
                                  scale: _scale,
                                  onSelect: () =>
                                      setState(() => _selected = el.id),
                                  onMove: (d) {
                                    setState(() {
                                      el.x += d.dx / _scale;
                                      el.y += d.dy / _scale;
                                    });
                                    _scheduleSave();
                                  },
                                  onResize: (d) {
                                    setState(() {
                                      el.w = (el.w + d.dx / _scale).clamp(40, 1600);
                                      el.h = (el.h + d.dy / _scale).clamp(30, 1600);
                                    });
                                    _scheduleSave();
                                  },
                                  onRotate: (d) {
                                    setState(() => el.rotation += d.dx / 120);
                                    _scheduleSave();
                                  },
                                  onEditText: () => _editText(el),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _CanvasToolbar(
            selected: _selEl,
            onAddText: _addText,
            onAddImage: () => _addImage(ImageSource.gallery),
            onAddCamera: () => _addImage(ImageSource.camera),
            onAddSticker: _addSticker,
            onDelete: _deleteSelected,
            onFront: _bringToFront,
            onColor: _setColor,
            onZoomReset: () => setState(() => _tc.value = Matrix4.identity()),
          ),
        ],
      ),
    );
  }

  void _showExport() {
    ExportFormat format = context.read<SettingsStore>().exportFormat;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Export this note',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _chip('PDF', format == ExportFormat.pdf,
                        () => setSheet(() => format = ExportFormat.pdf)),
                    const SizedBox(width: 10),
                    _chip('.txt', format == ExportFormat.txt,
                        () => setSheet(() => format = ExportFormat.txt)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
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

  Widget _chip(String label, bool on, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: on
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
              color: on ? theme.colorScheme.primary : theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: on
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

/// One element on the canvas, with selection frame + resize/rotate handles.
class _CanvasItem extends StatelessWidget {
  const _CanvasItem({
    required this.el,
    required this.selected,
    required this.scale,
    required this.onSelect,
    required this.onMove,
    required this.onResize,
    required this.onRotate,
    required this.onEditText,
  });

  final CanvasElement el;
  final bool selected;
  final double scale;
  final VoidCallback onSelect;
  final void Function(Offset) onMove;
  final void Function(Offset) onResize;
  final void Function(Offset) onRotate;
  final VoidCallback onEditText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    Widget content;
    switch (el.kind) {
      case ElementKind.text:
        content = Container(
          width: el.w,
          height: el.h,
          alignment: Alignment.topLeft,
          child: Text(
            el.text.isEmpty ? 'Write here' : el.text,
            style: TextStyle(
              fontSize: el.fontSize,
              height: 1.3,
              fontWeight: el.bold ? FontWeight.w700 : FontWeight.w400,
              fontStyle: el.italic ? FontStyle.italic : FontStyle.normal,
              color: kInkColors[el.colorIndex % kInkColors.length],
            ),
          ),
        );
        break;
      case ElementKind.image:
      case ElementKind.sticker:
        content = SizedBox(
          width: el.w,
          height: el.h,
          child: el.src.startsWith('assets/')
              ? Image.asset(el.src, fit: BoxFit.contain)
              : Image.file(File(el.src), fit: BoxFit.contain),
        );
        break;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      onPanStart: (_) => onSelect(),
      onPanUpdate: (d) => onMove(d.delta),
      onDoubleTap: el.kind == ElementKind.text ? onEditText : null,
      child: SizedBox(
        width: el.w,
        height: el.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: selected
                      ? Border.all(color: accent, width: 1.5 / scale)
                      : null,
                ),
                child: content,
              ),
            ),
            if (selected) ...[
              // rotate handle
              Positioned(
                top: -26 / scale,
                left: el.w / 2 - 12 / scale,
                child: GestureDetector(
                  onPanUpdate: (d) => onRotate(d.delta),
                  child: Icon(Icons.rotate_right,
                      size: 24 / scale, color: accent),
                ),
              ),
              // resize handle
              Positioned(
                right: -12 / scale,
                bottom: -12 / scale,
                child: GestureDetector(
                  onPanUpdate: (d) => onResize(d.delta),
                  child: Container(
                    width: 20 / scale,
                    height: 20 / scale,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2 / scale),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Floating pill toolbar. Changes with the selection.
class _CanvasToolbar extends StatelessWidget {
  const _CanvasToolbar({
    required this.selected,
    required this.onAddText,
    required this.onAddImage,
    required this.onAddCamera,
    required this.onAddSticker,
    required this.onDelete,
    required this.onFront,
    required this.onColor,
    required this.onZoomReset,
  });

  final CanvasElement? selected;
  final VoidCallback onAddText;
  final VoidCallback onAddImage;
  final VoidCallback onAddCamera;
  final VoidCallback onAddSticker;
  final VoidCallback onDelete;
  final VoidCallback onFront;
  final void Function(int) onColor;
  final VoidCallback onZoomReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final el = selected;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Pill(
              children: [
                _btn(context, Icons.text_fields, 'Text', onAddText),
                _btn(context, Icons.image_outlined, 'Image', onAddImage),
                _btn(context, Icons.photo_camera_outlined, 'Camera',
                    onAddCamera),
                _btn(context, Icons.emoji_emotions_outlined, 'Sticker',
                    onAddSticker),
                _btn(context, Icons.center_focus_strong, 'Fit', onZoomReset),
              ],
            ),
            if (el != null) ...[
              const SizedBox(width: 10),
              _Pill(
                children: [
                  for (var i = 0; i < kInkColors.length; i++)
                    GestureDetector(
                      onTap: () => onColor(i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 8),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: kInkColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: el.colorIndex == i
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  _btn(context, Icons.flip_to_front, 'Front', onFront),
                  _btn(context, Icons.delete_outline, 'Delete', onDelete),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon,
              size: 20, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
