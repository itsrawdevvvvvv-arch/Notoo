import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';
import '../data/settings_store.dart';

/// Builds export files for notes: a single note, or every note at once,
/// as either PDF or plain text.
class ExportService {
  static String _safe(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    final base = cleaned.isEmpty ? 'note' : cleaned;
    return base.length > 40 ? base.substring(0, 40) : base;
  }

  static Future<Directory> _exportDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/notoo/exports');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ---------- Plain text ----------

  static String noteAsText(Note n) {
    final buf = StringBuffer();
    buf.writeln(n.displayTitle);
    buf.writeln('=' * n.displayTitle.length);
    buf.writeln();
    buf.write(n.plainText);
    buf.writeln();
    return buf.toString();
  }

  static String allAsText(List<Note> notes) {
    final buf = StringBuffer('NOTOO EXPORT\n');
    buf.writeln('Exported: ${DateTime.now()}\n');
    for (final n in notes) {
      buf.writeln('-' * 48);
      buf.write(noteAsText(n));
      buf.writeln();
    }
    return buf.toString();
  }

  // ---------- PDF ----------

  static Future<Uint8List> _pdfFor(
    List<Note> notes, {
    required String title,
  }) async {
    final doc = pw.Document(title: title);
    final heading = pw.TextStyle(
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('#2E2A24'),
    );
    final meta = pw.TextStyle(
      fontSize: 9,
      color: PdfColor.fromHex('#6B6459'),
    );
    final body = const pw.TextStyle(fontSize: 12, lineSpacing: 3);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(44),
        build: (ctx) {
          final widgets = <pw.Widget>[
            pw.Text(title, style: heading),
            pw.SizedBox(height: 4),
            pw.Text('Notoo export · ${DateTime.now()}', style: meta),
            pw.SizedBox(height: 16),
          ];
          for (var i = 0; i < notes.length; i++) {
            final n = notes[i];
            widgets.add(pw.Text(n.displayTitle,
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#3A5142'))));
            widgets.add(pw.SizedBox(height: 2));
            widgets.add(pw.Text(
                'Updated ${n.updatedAt.toLocal()}', style: meta));
            widgets.add(pw.SizedBox(height: 6));
            final text = n.plainText.trim();
            widgets.add(pw.Text(
                text.isEmpty ? '(empty note)' : text, style: body));
            if (i != notes.length - 1) {
              widgets.add(pw.SizedBox(height: 18));
              widgets.add(pw.Divider(color: PdfColor.fromHex('#E7DFD0')));
              widgets.add(pw.SizedBox(height: 8));
            }
          }
          return widgets;
        },
      ),
    );
    return doc.save();
  }

  // ---------- Public API ----------

  /// Writes the export file and returns its path.
  static Future<String> exportNote(Note n, ExportFormat format) async {
    final dir = await _exportDir();
    final name = _safe(n.displayTitle);
    if (format == ExportFormat.txt) {
      final f = File('${dir.path}/$name.txt');
      await f.writeAsString(noteAsText(n));
      return f.path;
    }
    final bytes = await _pdfFor([n], title: n.displayTitle);
    final f = File('${dir.path}/$name.pdf');
    await f.writeAsBytes(bytes);
    return f.path;
  }

  static Future<String> exportAll(
      List<Note> notes, ExportFormat format) async {
    final dir = await _exportDir();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    if (format == ExportFormat.txt) {
      final f = File('${dir.path}/notoo_all_$stamp.txt');
      await f.writeAsString(allAsText(notes));
      return f.path;
    }
    final bytes = await _pdfFor(notes, title: 'Notoo — All notes');
    final f = File('${dir.path}/notoo_all_$stamp.pdf');
    await f.writeAsBytes(bytes);
    return f.path;
  }

  /// Opens the platform share sheet for the produced file.
  static Future<void> shareFile(String path, {String? text}) async {
    final file = XFile(path);
    await Share.shareXFiles([file], text: text);
  }
}
