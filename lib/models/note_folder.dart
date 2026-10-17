/// A notebook / folder that groups notes.
class NoteFolder {
  String id;
  String name;
  String iconKey;
  int colorIndex;

  NoteFolder({
    required this.id,
    required this.name,
    this.iconKey = 'folder',
    this.colorIndex = 0,
  });

  factory NoteFolder.create(String name, {String iconKey = 'folder', int colorIndex = 0}) =>
      NoteFolder(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        iconKey: iconKey,
        colorIndex: colorIndex,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'colorIndex': colorIndex,
      };

  factory NoteFolder.fromMap(Map<String, dynamic> m) => NoteFolder(
        id: m['id'] as String,
        name: (m['name'] ?? 'Untitled') as String,
        iconKey: (m['iconKey'] ?? 'folder') as String,
        colorIndex: (m['colorIndex'] ?? 0) as int,
      );
}
