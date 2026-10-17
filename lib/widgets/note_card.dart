import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_colors.dart';

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
    final tint = note.colorIndex == null
        ? theme.colorScheme.surface
        : AppColors.pastel(note.colorIndex);
    final onTint = AppColors.ink;

    return Material(
      color: tint,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
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
                        color: onTint,
                      ),
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(Icons.push_pin,
                        size: 15, color: AppColors.green),
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
                  color: AppColors.inkSoft,
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
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tagLabel!,
                        style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _date(note.updatedAt),
                    style: const TextStyle(
                        fontSize: 10.5, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ],
          ),
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
