import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../models/note_folder.dart';
import '../models/note_tag.dart';
import 'storage_dir.dart';

/// Local-first store. Everything lives in JSON files in the app's documents
/// directory — no account, no cloud, no network permission required.
class NotesStore extends ChangeNotifier {
  final List<Note> notes = [];
  final List<NoteFolder> folders = [];
  final List<NoteTag> tags = [];

  Directory? _dir;
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<Directory> _ensureDir() async {
    if (_dir != null) return _dir!;
    _dir = await resolveStorageDir();
    return _dir!;
  }

  File _file(Directory dir, String name) => File('${dir.path}/$name');

  Future<void> load() async {
    try {
      final dir = await _ensureDir();
      notes
        ..clear()
        ..addAll(await _readList(dir, 'notes.json', (m) => Note.fromMap(m)));
      folders
        ..clear()
        ..addAll(await _readList(dir, 'folders.json', (m) => NoteFolder.fromMap(m)));
      tags
        ..clear()
        ..addAll(await _readList(dir, 'tags.json', (m) => NoteTag.fromMap(m)));
    } catch (e) {
      debugPrint('NotesStore.load failed: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<List<T>> _readList<T>(
    Directory dir,
    String name,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    final f = _file(dir, name);
    if (!await f.exists()) return <T>[];
    final raw = await f.readAsString();
    if (raw.trim().isEmpty) return <T>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <T>[];
    return decoded
        .whereType<Map>()
        .map((e) => fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _save() async {
    try {
      final dir = await _ensureDir();
      await _file(dir, 'notes.json')
          .writeAsString(jsonEncode(notes.map((n) => n.toMap()).toList()));
      await _file(dir, 'folders.json')
          .writeAsString(jsonEncode(folders.map((f) => f.toMap()).toList()));
      await _file(dir, 'tags.json')
          .writeAsString(jsonEncode(tags.map((t) => t.toMap()).toList()));
    } catch (e) {
      debugPrint('NotesStore._save failed: $e');
    }
  }

  // ---------- Queries ----------

  List<Note> get active =>
      notes.where((n) => !n.isArchived && !n.isTrashed).toList();

  List<Note> get pinned =>
      active.where((n) => n.isPinned).toList()..sort(_byUpdated);

  List<Note> get unpinned =>
      active.where((n) => !n.isPinned).toList()..sort(_byUpdated);

  List<Note> get archived =>
      notes.where((n) => n.isArchived && !n.isTrashed).toList()..sort(_byUpdated);

  List<Note> get trashed => notes.where((n) => n.isTrashed).toList()
    ..sort(_byUpdated);

  static int _byUpdated(Note a, Note b) => b.updatedAt.compareTo(a.updatedAt);

  int notesInFolder(String folderId) =>
      active.where((n) => n.folderId == folderId).length;

  int notesWithTag(String tagId) =>
      active.where((n) => n.tagIds.contains(tagId)).length;

  Note? byId(String id) {
    for (final n in notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  List<Note> search(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return notes
        .where((n) =>
            !n.isTrashed &&
            (n.title.toLowerCase().contains(query) ||
                n.plainText.toLowerCase().contains(query)))
        .toList()
      ..sort(_byUpdated);
  }

  // ---------- Mutations ----------

  Future<Note> addNote({String? folderId, NoteKind kind = NoteKind.canvas}) async {
    final note = Note.create(kind: kind)..folderId = folderId;
    notes.add(note);
    await _save();
    notifyListeners();
    return note;
  }

  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    final i = notes.indexWhere((n) => n.id == note.id);
    if (i >= 0) {
      notes[i] = note;
    } else {
      notes.add(note);
    }
    await _save();
    notifyListeners();
  }

  Future<void> togglePin(Note note) async {
    note.isPinned = !note.isPinned;
    await updateNote(note);
  }

  Future<void> toggleArchive(Note note) async {
    note.isArchived = !note.isArchived;
    if (note.isArchived) note.isTrashed = false;
    await updateNote(note);
  }

  Future<void> trashNote(Note note) async {
    note.isTrashed = true;
    await updateNote(note);
  }

  Future<void> restoreNote(Note note) async {
    note.isTrashed = false;
    await updateNote(note);
  }

  Future<void> deleteForever(Note note) async {
    notes.removeWhere((n) => n.id == note.id);
    await _save();
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    notes.removeWhere((n) => n.isTrashed);
    await _save();
    notifyListeners();
  }

  Future<NoteFolder> addFolder(String name,
      {String iconKey = 'folder', int colorIndex = 0}) async {
    final f = NoteFolder.create(name, iconKey: iconKey, colorIndex: colorIndex);
    folders.add(f);
    await _save();
    notifyListeners();
    return f;
  }

  Future<NoteTag> addTag(String name, {int colorIndex = 0}) async {
    final t = NoteTag.create(name, colorIndex: colorIndex);
    tags.add(t);
    await _save();
    notifyListeners();
    return t;
  }

  Future<void> renameFolder(NoteFolder folder, String name) async {
    folder.name = name;
    await _save();
    notifyListeners();
  }

  Future<void> deleteFolder(NoteFolder folder) async {
    folders.removeWhere((f) => f.id == folder.id);
    for (final n in notes) {
      if (n.folderId == folder.id) n.folderId = null;
    }
    await _save();
    notifyListeners();
  }

  Future<void> deleteTag(NoteTag tag) async {
    tags.removeWhere((t) => t.id == tag.id);
    for (final n in notes) {
      n.tagIds.remove(tag.id);
    }
    await _save();
    notifyListeners();
  }
}
