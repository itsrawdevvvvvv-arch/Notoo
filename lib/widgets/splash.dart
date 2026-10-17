import 'package:flutter/material.dart';

import '../generated/sticker_manifest.dart';

/// A soft, animated splash shown while Notoo loads.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    final rise = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: rise,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kDoodleStickers.isNotEmpty)
                  SizedBox(
                    height: 140,
                    child: Image.asset(
                      kDoodleStickers.first['asset']!,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Icon(Icons.edit_note,
                      size: 84, color: theme.colorScheme.primary),
                const SizedBox(height: 18),
                Text(
                  'Notoo',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Good ideas live here.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
