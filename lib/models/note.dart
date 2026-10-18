import 'canvas_element.dart';

/// How a note's content is stored.
enum NoteKind { rich, canvas }

/// A single note.
///
/// Rich notes keep a Quill Delta plus a cached plain-text copy.
/// Canvas notes keep a list of freely-placed elements.
class Note {
  String id;
  String title;
  NoteKind kind;
  List<dynamic> deltaJson;
  String plainText;
  List<CanvasElement> canvas;
  String? folderId;
  List<String> tagIds;
  int? colorIndex;
  bool isPinned;
  bool isArchived;
  bool isTrashed;
  bool isLocked;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    this.title = '',
    this.kind = NoteKind.canvas,
    List<dynamic>? deltaJson,
    this.plainText = '',
    List<CanvasElement>? canvas,
    this.folderId,
    List<String>? tagIds,
    this.colorIndex,
    this.isPinned = false,
    this.isArchived = false,
    this.isTrashed = false,
    this.isLocked = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : deltaJson = deltaJson ?? <dynamic>[],
        canvas = canvas ?? <CanvasElement>[],
        tagIds = tagIds ?? <String>[],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Note.create({NoteKind kind = NoteKind.canvas}) => Note(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        kind: kind,
      );

  String get displayTitle => title.trim().isEmpty ? 'Untitled' : title.trim();

  String get preview {
    final t = plainText.replaceAll('\n', ' ').trim();
    if (t.isEmpty) {
      return kind == NoteKind.canvas ? 'Blank canvas' : 'No additional text';
    }
    return t.length > 90 ? '${t.substring(0, 90)}…' : t;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'kind': kind.index,
        'delta': deltaJson,
        'plainText': plainText,
        'canvas': canvas.map((e) => e.toMap()).toList(),
        'folderId': folderId,
        'tagIds': tagIds,
        'colorIndex': colorIndex,
        'isPinned': isPinned,
        'isArchived': isArchived,
        'isTrashed': isTrashed,
        'isLocked': isLocked,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> m) => Note(
        id: m['id'] as String,
        title: (m['title'] ?? '') as String,
        kind: NoteKind.values[
            ((m['kind'] as int?) ?? 0).clamp(0, NoteKind.values.length - 1)],
        deltaJson: (m['delta'] as List?) ?? <dynamic>[],
        plainText: (m['plainText'] ?? '') as String,
        canvas: ((m['canvas'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => CanvasElement.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        folderId: m['folderId'] as String?,
        tagIds: ((m['tagIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        colorIndex: m['colorIndex'] as int?,
        isPinned: (m['isPinned'] ?? false) as bool,
        isArchived: (m['isArchived'] ?? false) as bool,
        isTrashed: (m['isTrashed'] ?? false) as bool,
        isLocked: (m['isLocked'] ?? false) as bool,
        createdAt: DateTime.tryParse((m['createdAt'] ?? '') as String) ??
            DateTime.now(),
        updatedAt: DateTime.tryParse((m['updatedAt'] ?? '') as String) ??
            DateTime.now(),
      );
}
