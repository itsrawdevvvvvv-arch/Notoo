import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../generated/sticker_manifest.dart';
import '../theme/app_colors.dart';

/// Returns a doodle asset by index (wraps), or null if none are bundled.
String? doodleAsset(int index) {
  if (kDoodleStickers.isEmpty) return null;
  return kDoodleStickers[index % kDoodleStickers.length]['asset'];
}

/// A soft field of drifting blobs, like the mockup's background splotches.
class BlobField extends StatefulWidget {
  const BlobField({super.key, required this.child});

  final Widget child;

  @override
  State<BlobField> createState() => _BlobFieldState();
}

class _BlobFieldState extends State<BlobField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: _BlobPainter(t: _c.value),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final a = t * 2 * math.pi;
    void blob(Offset c, double r, Color color, double phase) {
      final p = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        c.translate(math.sin(a + phase) * 6, math.cos(a + phase) * 6),
        r,
        p,
      );
    }

    blob(Offset(-size.width * 0.08, size.height * 0.10), 45,
        const Color(0xFFB9CFB8), 0);
    blob(Offset(size.width * 1.02, size.height * 0.72), 35,
        const Color(0xFFF6C9B0), 1.6);
    blob(Offset(size.width * 0.95, size.height * 0.18), 26,
        const Color(0xFFDCE6F2), 2.8);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}

/// The mockup's hand-written margin note (Caveat, tilted, gently swaying).
class StickyNote extends StatelessWidget {
  const StickyNote({
    super.key,
    required this.text,
    this.rotation = 0.052,
    this.color = AppColors.sticky,
  });

  final String text;
  final double rotation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _Sway(
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: 96,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Caveat',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.05,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Handwriting in Caveat, for the little in-app captions.
class HandText extends StatelessWidget {
  const HandText(
    this.text, {
    super.key,
    this.size = 15,
    this.color,
    this.align = TextAlign.left,
  });

  final String text;
  final double size;
  final Color? color;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontFamily: 'Caveat',
        fontWeight: FontWeight.w600,
        fontSize: size,
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// A doodle placed at a slight rotation.
class Doodle extends StatelessWidget {
  const Doodle({
    super.key,
    required this.asset,
    this.size = 64,
    this.rotation = 0,
  });

  final String asset;
  final double size;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child:
          Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
    );
  }
}

class _Sway extends StatefulWidget {
  const _Sway({required this.child});
  final Widget child;

  @override
  State<_Sway> createState() => _SwayState();
}

class _SwayState extends State<_Sway> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -2.5 * _c.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}
