import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../generated/sticker_manifest.dart';
import '../theme/app_colors.dart';

/// Returns a doodle asset by index (wraps), or null if none are bundled.
String? doodleAsset(int index) {
  if (kDoodleStickers.isEmpty) return null;
  return kDoodleStickers[index % kDoodleStickers.length]['asset'];
}

/// A slowly drifting field of soft organic blobs, drawn behind content.
class BlobBackground extends StatefulWidget {
  const BlobBackground({super.key, required this.child});

  final Widget child;

  @override
  State<BlobBackground> createState() => _BlobBackgroundState();
}

class _BlobBackgroundState extends State<BlobBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: _BlobPainter(t: _c.value, accent: primary),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.t, required this.accent});

  final double t;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final a = t * 2 * math.pi;

    void blob(Offset c, double r, Color color, double phase) {
      final p = Paint()..color = color.withValues(alpha: 0.18);
      final dx = math.sin(a + phase) * 10;
      final dy = math.cos(a + phase) * 10;
      canvas.drawCircle(c.translate(dx, dy), r, p);
    }

    blob(Offset(w * 0.02, h * 0.03), w * 0.22, accent, 0);
    blob(Offset(w * 0.98, h * 0.12), w * 0.18, AppColors.pastels[1], 1.2);
    blob(Offset(w * 0.9, h * 0.62), w * 0.24, AppColors.pastels[2], 2.1);
    blob(Offset(w * 0.05, h * 0.92), w * 0.2, AppColors.pastels[0], 3.0);
    blob(Offset(w * 0.5, h * 1.02), w * 0.16, AppColors.pastels[5], 4.2);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t || old.accent != accent;
}

/// A doodle placed at a slight rotation — an editorial accent.
class Doodle extends StatelessWidget {
  const Doodle({
    super.key,
    required this.asset,
    this.size = 64,
    this.rotation = 0,
    this.opacity = 1,
  });

  final String asset;
  final double size;
  final double rotation;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: rotation,
        child: Image.asset(asset, width: size, height: size,
            fit: BoxFit.contain),
      ),
    );
  }
}

/// A small handwritten "sticky note" accent, like the mockup's margin notes.
class StickyNote extends StatelessWidget {
  const StickyNote({
    super.key,
    required this.text,
    this.rotation = 0.05,
    this.color,
  });

  final String text;
  final double rotation;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color ?? AppColors.pastels[3],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Caveat',
            fontSize: 17,
            height: 1.1,
            fontWeight: FontWeight.w600,
            color: theme.brightness == Brightness.dark
                ? AppColors.ink
                : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
