import 'package:flutter/material.dart';

/// What a canvas element holds.
enum ElementKind { text, image, sticker }

/// One freely-placed item on a canvas note: text, an image, or a sticker.
/// Position, size and rotation are all free — nothing is constrained.
class CanvasElement {
  String id;
  ElementKind kind;
  double x;
  double y;
  double w;
  double h;
  double rotation; // radians
  String text; // for text elements
  String src; // asset path or file path, for image/sticker
  int colorIndex; // text colour (index into the ink palette)
  double fontSize;
  bool bold;
  bool italic;

  CanvasElement({
    required this.id,
    required this.kind,
    this.x = 40,
    this.y = 40,
    this.w = 200,
    this.h = 120,
    this.rotation = 0,
    this.text = '',
    this.src = '',
    this.colorIndex = 0,
    this.fontSize = 18,
    this.bold = false,
    this.italic = false,
  });

  factory CanvasElement.create(ElementKind kind) => CanvasElement(
        id: DateTime.now().microsecondsSinceEpoch.toString() +
            (kind.index.toString()),
        kind: kind,
      );

  CanvasElement copy() => CanvasElement(
        id: id,
        kind: kind,
        x: x,
        y: y,
        w: w,
        h: h,
        rotation: rotation,
        text: text,
        src: src,
        colorIndex: colorIndex,
        fontSize: fontSize,
        bold: bold,
        italic: italic,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'kind': kind.index,
        'x': x,
        'y': y,
        'w': w,
        'h': h,
        'rotation': rotation,
        'text': text,
        'src': src,
        'colorIndex': colorIndex,
        'fontSize': fontSize,
        'bold': bold,
        'italic': italic,
      };

  factory CanvasElement.fromMap(Map<String, dynamic> m) => CanvasElement(
        id: (m['id'] ?? '') as String,
        kind: ElementKind
            .values[((m['kind'] as int?) ?? 0).clamp(0, ElementKind.values.length - 1)],
        x: ((m['x'] as num?) ?? 40).toDouble(),
        y: ((m['y'] as num?) ?? 40).toDouble(),
        w: ((m['w'] as num?) ?? 200).toDouble(),
        h: ((m['h'] as num?) ?? 120).toDouble(),
        rotation: ((m['rotation'] as num?) ?? 0).toDouble(),
        text: (m['text'] ?? '') as String,
        src: (m['src'] ?? '') as String,
        colorIndex: (m['colorIndex'] as int?) ?? 0,
        fontSize: ((m['fontSize'] as num?) ?? 18).toDouble(),
        bold: (m['bold'] ?? false) as bool,
        italic: (m['italic'] ?? false) as bool,
      );
}

/// Text colours offered on the canvas.
const List<Color> kInkColors = <Color>[
  Color(0xFF3A3A34), // ink
  Color(0xFF5F7F6E), // green
  Color(0xFFC15F3C), // terracotta
  Color(0xFF2B6CB0), // blue
  Color(0xFF8E4585), // plum
  Color(0xFFB03060), // berry
  Color(0xFF8D8A7E), // mute
];
