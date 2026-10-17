import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Resolves a writable directory for Notoo's data.
///
/// Prefers the app's documents directory; if the platform channel is
/// unavailable for any reason it falls back to the temporary directory.
/// This function never throws — storage trouble must never stop the app.
Future<Directory> resolveStorageDir() async {
  try {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/notoo');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  } catch (e) {
    debugPrint('resolveStorageDir: documents dir unavailable ($e)');
  }
  try {
    final dir = Directory('${Directory.systemTemp.path}/notoo');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  } catch (e) {
    debugPrint('resolveStorageDir: temp dir unavailable ($e)');
    return Directory.systemTemp;
  }
}
