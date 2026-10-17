import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A calm empty-state placeholder with a soft pastel medallion.
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.pastel(0),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.greenDeep),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.inkSoft, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
