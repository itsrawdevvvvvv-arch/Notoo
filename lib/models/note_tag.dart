/// A tag / label that can be applied to many notes.
class NoteTag {
  String id;
  String name;
  int colorIndex;

  NoteTag({required this.id, required this.name, this.colorIndex = 0});

  factory NoteTag.create(String name, {int colorIndex = 0}) => NoteTag(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        colorIndex: colorIndex,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorIndex': colorIndex,
      };

  factory NoteTag.fromMap(Map<String, dynamic> m) => NoteTag(
        id: m['id'] as String,
        name: (m['name'] ?? 'Untitled') as String,
        colorIndex: (m['colorIndex'] ?? 0) as int,
      );
}
