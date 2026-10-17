import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// How the home list is laid out.
enum ViewMode { grid, list }

/// Preferred export format.
enum ExportFormat { pdf, txt }

/// User preferences — appearance, font, colour accent, view, export defaults.
class SettingsStore extends ChangeNotifier {
  static const _kAppearance = 'appearance';
  static const _kFontScale = 'font_scale';
  static const _kFontFamily = 'font_family';
  static const _kView = 'view_mode';
  static const _kExport = 'export_format';
  static const _kAccent = 'accent_index';

  SharedPreferences? _prefs;

  Appearance appearance = Appearance.light;
  double fontScale = 1.0;
  String fontFamily = 'System';
  ViewMode viewMode = ViewMode.grid;
  ExportFormat exportFormat = ExportFormat.pdf;
  int accentIndex = 0;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    appearance = Appearance.values[
        (p.getInt(_kAppearance) ?? Appearance.light.index)
            .clamp(0, Appearance.values.length - 1)];
    fontScale = p.getDouble(_kFontScale) ?? 1.0;
    fontFamily = p.getString(_kFontFamily) ?? 'System';
    viewMode = ViewMode.values[
        (p.getInt(_kView) ?? ViewMode.grid.index).clamp(0, 1)];
    exportFormat = ExportFormat.values[
        (p.getInt(_kExport) ?? ExportFormat.pdf.index).clamp(0, 1)];
    accentIndex = p.getInt(_kAccent) ?? 0;
    notifyListeners();
  }

  Future<void> setAppearance(Appearance a) async {
    appearance = a;
    await _prefs?.setInt(_kAppearance, a.index);
    notifyListeners();
  }

  Future<void> setFontScale(double s) async {
    fontScale = s;
    await _prefs?.setDouble(_kFontScale, s);
    notifyListeners();
  }

  Future<void> setFontFamily(String f) async {
    fontFamily = f;
    await _prefs?.setString(_kFontFamily, f);
    notifyListeners();
  }

  Future<void> setViewMode(ViewMode v) async {
    viewMode = v;
    await _prefs?.setInt(_kView, v.index);
    notifyListeners();
  }

  Future<void> setExportFormat(ExportFormat f) async {
    exportFormat = f;
    await _prefs?.setInt(_kExport, f.index);
    notifyListeners();
  }

  Future<void> setAccentIndex(int i) async {
    accentIndex = i;
    await _prefs?.setInt(_kAccent, i);
    notifyListeners();
  }

  bool get isDark => appearance != Appearance.light;
}
