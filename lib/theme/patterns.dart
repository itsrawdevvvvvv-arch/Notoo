import 'package:flutter/material.dart';

/// Paper background patterns for the writing pad: plain, dotted, squared
/// (grid), ruled, and notebook. Drawn in code so they are crisp at any size
/// and add nothing to the download.
enum PaperPattern { plain, dots, grid, ruled, notebook }

const List<String> kPaperPatternNames = [
  'Plain',
  'Dots',
  'Grid',
  'Ruled',
  'Notebook',
];

class PaperBackground extends StatelessWidget {
  const PaperBackground({
    super.key,
    required this.pattern,
    required this.color,
    required this.child,
    this.lineColor,
  });

  final PaperPattern pattern;
  final Color color;
  final Widget child;
  final Color? lineColor;

  @override
  Widget build(BuildContext context) {
    if (pattern == PaperPattern.plain) {
      return Container(color: color, child: child);
    }
    final dark = ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    final line = lineColor ??
        (dark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08));
    return Container(
      color: color,
      child: CustomPaint(
        painter: _PaperPainter(pattern: pattern, line: line),
        child: child,
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  _PaperPainter({required this.pattern, required this.line});

  final PaperPattern pattern;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = line
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gap = 26.0;

    switch (pattern) {
      case PaperPattern.dots:
        final dot = Paint()..color = line;
        for (double y = gap; y < size.height; y += gap) {
          for (double x = gap; x < size.width; x += gap) {
            canvas.drawCircle(Offset(x, y), 1.3, dot);
          }
        }
        break;
      case PaperPattern.grid:
        for (double x = gap; x < size.width; x += gap) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = gap; y < size.height; y += gap) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;
      case PaperPattern.ruled:
        for (double y = gap; y < size.height; y += gap) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;
      case PaperPattern.notebook:
        for (double y = gap; y < size.height; y += gap) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        final margin = Paint()
          ..color = line
          ..strokeWidth = 1.4;
        canvas.drawLine(
            const Offset(gap, 0), Offset(gap, size.height), margin);
        break;
      case PaperPattern.plain:
        break;
    }
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.pattern != pattern || old.line != line;
}
