import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// A themed, freely movable text-selection menu (cut / copy / paste /
/// select all). Drag it anywhere with your finger.
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
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A little grab handle hint.
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 6),
                    child: Icon(Icons.drag_indicator,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  for (final item in items)
                    _MenuButton(
                      item: item,
                      theme: theme,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.item, required this.theme});

  final ContextMenuButtonItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: item.onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(item.type), size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              _labelFor(item.type),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
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
        return 'All';
      default:
        return '';
    }
  }
}
