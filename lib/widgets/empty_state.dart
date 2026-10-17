import 'package:flutter/material.dart';

import '../generated/sticker_manifest.dart';
import 'motion.dart';

/// A calm, playful empty-state placeholder. Shows an editorial doodle when
/// the sticker pack is available, otherwise a themed icon.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasDoodle = kDoodleStickers.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Floating(
              child: hasDoodle
                  ? SizedBox(
                      height: 130,
                      child: Image.asset(
                        kDoodleStickers[
                                title.length % kDoodleStickers.length]['asset']!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 40, color: primary),
                    ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
