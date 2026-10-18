import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// A compact, pill-shaped text-selection menu (cut / copy / paste / select
/// all). Icon-only so it stays small, and draggable so you can move it out of
/// the way.
class MovableSelectionMenu extends StatefulWidget {
  const MovableSelectionMenu({super.key, required this.editorState});

  final QuillRawEditorState editorState;

  @override
  State<MovableSelectionMenu> createState() => _MovableSelectionMenuState();
}

class _MovableSelectionMenuState extends State<MovableSelectionMenu> {
  Offset _drag = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = widget.editorState.contextMenuButtonItems;
    if (items.isEmpty) return const SizedBox.shrink();

    return TextFieldTapRegion(
      child: Transform.translate(
        offset: _drag,
        child: GestureDetector(
          onPanUpdate: (d) => setState(() => _drag += d.delta),
          child: Material(
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(26),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border:
                    Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(Icons.drag_indicator,
                        size: 15,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  for (final item in items)
                    _PillButton(item: item, theme: theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.item, required this.theme});

  final ContextMenuButtonItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _labelFor(item.type),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            _iconFor(item.type),
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ContextMenuButtonType type) {
    switch (type) {
      case ContextMenuButtonType.cut:
        return Icons.content_cut;
      case ContextMenuButtonType.copy:
        return Icons.content_copy;
      case ContextMenuButtonType.paste:
        return Icons.content_paste;
      case ContextMenuButtonType.selectAll:
        return Icons.select_all;
      default:
        return Icons.more_horiz;
    }
  }

  String _labelFor(ContextMenuButtonType type) {
    switch (type) {
      case ContextMenuButtonType.cut:
        return 'Cut';
      case ContextMenuButtonType.copy:
        return 'Copy';
      case ContextMenuButtonType.paste:
        return 'Paste';
      case ContextMenuButtonType.selectAll:
        return 'Select all';
      default:
        return '';
    }
  }
}
