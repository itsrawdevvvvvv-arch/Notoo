import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'decor.dart';
import 'motion.dart';

/// The mockup's card: soft cream surface, 16 radius, gentle lift on press.
class NotooCard extends StatelessWidget {
  const NotooCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
    this.color,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Bouncy(onTap: onTap, child: box);
  }
}

/// Section label with an optional trailing hint, like "Pinned … See all".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailing!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The mockup's rounded search bar.
class SearchBarPill extends StatelessWidget {
  const SearchBarPill({super.key, required this.onTap, this.hint});

  final VoidCallback onTap;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Bouncy(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.pill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.search,
                size: 17, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint ?? 'Search notes, tags, folders…',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list row: pastel squircle badge, title + subtitle, trailing chevron.
class NotooRow extends StatelessWidget {
  const NotooRow({
    super.key,
    required this.title,
    required this.badgeColor,
    required this.badge,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.leadingDot,
  });

  final String title;
  final String? subtitle;
  final Color badgeColor;
  final Widget badge;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? leadingDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: NotooCard(
        onTap: onTap,
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Row(
            children: [
              if (leadingDot != null)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: leadingDot,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: badge,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 9.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill button, like the mockup's "Unarchive" / "Restore".
class MiniButton extends StatelessWidget {
  const MiniButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = AppColors.greenLight;
    return Bouncy(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? light
              : theme.colorScheme.primary.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Big centred doodle + handwritten caption used on empty screens.
class ArtCaption extends StatelessWidget {
  const ArtCaption({
    super.key,
    required this.asset,
    required this.caption,
  });

  final String asset;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Floating(
          child: SizedBox(
            height: 92,
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 4),
        HandText(caption, size: 16, align: TextAlign.center),
      ],
    );
  }
}
