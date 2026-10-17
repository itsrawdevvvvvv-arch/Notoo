import 'package:flutter/material.dart';

import '../generated/sticker_manifest.dart';

/// The editorial sticker library — CC0 Open Doodles plus CC-BY Twemoji.
/// Returns the asset path of the chosen sticker (or null).
Future<String?> showStickerPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => const _StickerSheet(),
  );
}

class _StickerSheet extends StatefulWidget {
  const _StickerSheet();

  @override
  State<_StickerSheet> createState() => _StickerSheetState();
}

class _StickerSheetState extends State<_StickerSheet> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doodles = kDoodleStickers;
    final emoji = kEmojiStickers;

    if (doodles.isEmpty && emoji.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Stickers are loading…')),
      );
    }

    final items = _tab == 0 ? doodles : emoji;

    return SizedBox(
      height: 420,
      child: Column(
        children: [
          Row(
            children: [
              _tabBtn(theme, 'Doodles', 0),
              _tabBtn(theme, 'Emoji', 1),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                final asset = items[i]['asset']!;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pop(context, asset),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(asset, fit: BoxFit.contain),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(ThemeData theme, String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
