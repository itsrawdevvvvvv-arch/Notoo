import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_colors.dart';
import 'motion.dart';

/// A single note card, used across Home / Archive / Trash / Search.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.trailing,
    this.tagLabel,
  });

  final Note note;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? tagLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tinted = note.colorIndex != null;
    final cardColor =
        tinted ? AppColors.pastel(note.colorIndex) : theme.colorScheme.surface;
    final titleColor = tinted ? AppColors.ink : theme.colorScheme.onSurface;
    final bodyColor = tinted ? AppColors.inkSoft : theme.colorScheme.onSurfaceVariant;

    return Bouncy(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: tinted
              ? null
              : Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
                if (note.isPinned)
                  Icon(Icons.push_pin, size: 15, color: theme.colorScheme.primary),
                if (trailing != null) ...[
                  const SizedBox(width: 6),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              note.preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: bodyColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (tagLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tinted
                          ? Colors.white.withValues(alpha: 0.55)
                          : theme.colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tagLabel!,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: tinted
                            ? AppColors.ink
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  _date(note.updatedAt),
                  style: TextStyle(fontSize: 10.5, color: bodyColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _date(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
