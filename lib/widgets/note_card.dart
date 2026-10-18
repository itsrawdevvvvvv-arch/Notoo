import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_colors.dart';
import 'motion.dart';

/// The mockup's note card: title, preview, and a coloured dot + date.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.trailing,
    this.tagLabel,
    this.accent,
  });

  final Note note;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? tagLabel;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tinted = note.colorIndex != null;
    final cardColor =
        tinted ? AppColors.pastel(note.colorIndex) : theme.colorScheme.surface;
    final dot = accent ??
        (note.colorIndex != null
            ? theme.colorScheme.primary
            : AppColors.grey);

    return Bouncy(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (note.isPinned)
                  Icon(Icons.push_pin,
                      size: 13, color: theme.colorScheme.primary),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 4),
            Text(
              note.preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.5,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                if (tagLabel != null) ...[
                  const SizedBox(width: 5),
                  Text(
                    tagLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 9.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  _date(note.updatedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
