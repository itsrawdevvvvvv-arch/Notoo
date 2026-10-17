import 'package:flutter/material.dart';

/// A small, cheerful sticker (emoji) library that can be dropped into notes.
class StickerCategory {
  final String name;
  final String icon;
  final List<String> stickers;
  const StickerCategory(this.name, this.icon, this.stickers);
}

const List<StickerCategory> kStickerCategories = [
  StickerCategory('Smiles', '😀', [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '🥲', '😊', '😇', '🙂',
    '😉', '😍', '🥰', '😘', '😜', '🤪', '🤗', '🤩', '😎', '🥳', '😴', '🤔',
  ]),
  StickerCategory('Hands', '👍', [
    '👍', '👎', '👏', '🙌', '🤝', '🙏', '💪', '✌️', '🤞', '👋', '🤙', '👌',
    '✋', '🫶', '☝️', '👇', '👆', '🖐️',
  ]),
  StickerCategory('Hearts', '❤️', [
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💖', '💗', '💓',
    '💕', '💞', '💘', '💝', '❣️', '💟',
  ]),
  StickerCategory('Nature', '🌸', [
    '🌸', '🌼', '🌻', '🌹', '🌷', '🌱', '🌿', '🍀', '🍁', '🌙', '⭐', '✨',
    '☀️', '🌈', '☁️', '❄️', '🔥', '🌊',
  ]),
  StickerCategory('Animals', '🐱', [
    '🐱', '🐶', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵',
    '🐔', '🦉', '🦄', '🐢', '🐳', '🦋',
  ]),
  StickerCategory('Food', '🍕', [
    '🍕', '🍔', '🍟', '🌮', '🍣', '🍩', '🍪', '🍰', '🧁', '🍫', '🍎', '🍓',
    '🍉', '🥑', '☕', '🍵', '🍹', '🍦',
  ]),
  StickerCategory('Fun', '🎉', [
    '🎉', '🎊', '🎈', '🎁', '🏆', '🥇', '🎯', '🎨', '🎵', '🎮', '⚽', '🏀',
    '📚', '✏️', '💡', '🔔', '🚀', '🌟',
  ]),
];

/// Opens the sticker library and returns the chosen sticker (or null).
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
  int _cat = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = kStickerCategories[_cat];
    return SizedBox(
      height: 380,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kStickerCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = i == _cat;
                return GestureDetector(
                  onTap: () => setState(() => _cat = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${kStickerCategories[i].icon} '
                        '${kStickerCategories[i].name}'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: cat.stickers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (_, i) => InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context, cat.stickers[i]),
                child: Center(
                  child: Text(cat.stickers[i],
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
