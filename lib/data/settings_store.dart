import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../theme/app_theme.dart';
import 'storage_dir.dart';

/// How the home list is laid out.
enum ViewMode { grid, list }

/// Preferred export format.
enum ExportFormat { pdf, txt }

/// User preferences — appearance, font, colour accent, view, export defaults.
///
/// Persisted as a small JSON file (no platform plugin), and fully fail-safe:
/// if storage is unavailable the app still runs with in-memory settings.
class SettingsStore extends ChangeNotifier {
  File? _file;

  Appearance appearance = Appearance.light;
  double fontScale = 1.0;
  String fontFamily = 'System';
  ViewMode viewMode = ViewMode.grid;
  ExportFormat exportFormat = ExportFormat.pdf;
  int accentIndex = 0;

  Future<void> load() async {
    try {
      final dir = await resolveStorageDir();
      _file = File('${dir.path}/settings.json');
      if (await _file!.exists()) {
        final raw = await _file!.readAsString();
        if (raw.trim().isNotEmpty) {
          final m = jsonDecode(raw);
          if (m is Map) {
            appearance = Appearance.values[
                ((m['appearance'] as int?) ?? 0).clamp(0, Appearance.values.length - 1)];
            fontScale = ((m['fontScale'] as num?) ?? 1.0).toDouble();
            fontFamily = (m['fontFamily'] as String?) ?? 'System';
            viewMode =
                ViewMode.values[((m['viewMode'] as int?) ?? 0).clamp(0, 1)];
            exportFormat =
                ExportFormat.values[((m['exportFormat'] as int?) ?? 0).clamp(0, 1)];
            accentIndex = (m['accentIndex'] as int?) ?? 0;
          }
        }
      }
    } catch (e) {
      debugPrint('SettingsStore.load failed (using defaults): $e');
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final f = _file;
      if (f == null) return;
      await f.writeAsString(jsonEncode({
        'appearance': appearance.index,
        'fontScale': fontScale,
        'fontFamily': fontFamily,
        'viewMode': viewMode.index,
        'exportFormat': exportFormat.index,
        'accentIndex': accentIndex,
      }));
    } catch (e) {
      debugPrint('SettingsStore._save failed: $e');
    }
  }

  Future<void> setAppearance(Appearance a) async {
    appearance = a;
    await _save();
    notifyListeners();
  }

  Future<void> setFontScale(double s) async {
    fontScale = s;
    await _save();
    notifyListeners();
  }

  Future<void> setFontFamily(String f) async {
    fontFamily = f;
    await _save();
    notifyListeners();
  }

  Future<void> setViewMode(ViewMode v) async {
    viewMode = v;
    await _save();
    notifyListeners();
  }

  Future<void> setExportFormat(ExportFormat f) async {
    exportFormat = f;
    await _save();
    notifyListeners();
  }

  Future<void> setAccentIndex(int i) async {
    accentIndex = i;
    await _save();
    notifyListeners();
  }

  bool get isDark => appearance != Appearance.light;
}
