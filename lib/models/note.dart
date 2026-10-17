/// A single note. Rich text is stored as a Quill Delta JSON list, plus a
/// cached plain-text copy for previews and fast full-text search.
class Note {
  String id;
  String title;
  List<dynamic> deltaJson;
  String plainText;
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
    List<dynamic>? deltaJson,
    this.plainText = '',
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
        tagIds = tagIds ?? <String>[],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Note.create() => Note(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
      );

  String get displayTitle => title.trim().isEmpty ? 'Untitled' : title.trim();

  String get preview {
    final t = plainText.replaceAll('\n', ' ').trim();
    if (t.isEmpty) return 'No additional text';
    return t.length > 90 ? '${t.substring(0, 90)}…' : t;
  }

  Note copy() => Note(
        id: id,
        title: title,
        deltaJson: deltaJson,
        plainText: plainText,
        folderId: folderId,
        tagIds: List<String>.from(tagIds),
        colorIndex: colorIndex,
        isPinned: isPinned,
        isArchived: isArchived,
        isTrashed: isTrashed,
        isLocked: isLocked,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'delta': deltaJson,
        'plainText': plainText,
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
        deltaJson: (m['delta'] as List?) ?? <dynamic>[],
        plainText: (m['plainText'] ?? '') as String,
        folderId: m['folderId'] as String?,
        tagIds: ((m['tagIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        colorIndex: m['colorIndex'] as int?,
        isPinned: (m['isPinned'] ?? false) as bool,
        isArchived: (m['isArchived'] ?? false) as bool,
        isTrashed: (m['isTrashed'] ?? false) as bool,
        isLocked: (m['isLocked'] ?? false) as bool,
        createdAt:
            DateTime.tryParse((m['createdAt'] ?? '') as String) ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse((m['updatedAt'] ?? '') as String) ?? DateTime.now(),
      );
}
