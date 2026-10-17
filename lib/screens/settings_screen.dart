import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _fontFamilies = <String>[
    'System',
    'serif',
    'monospace',
    'cursive',
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _SectionTitle('Appearance'),
          Row(
            children: [
              for (final a in Appearance.values)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _Choice(
                    label: _appearanceLabel(a),
                    selected: settings.appearance == a,
                    onTap: () => settings.setAppearance(a),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          const _SectionTitle('Font size'),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: settings.fontScale,
                  min: 0.85,
                  max: 1.4,
                  divisions: 11,
                  activeColor: AppColors.green,
                  label: '${(settings.fontScale * 100).round()}%',
                  onChanged: settings.setFontScale,
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 12),

          const _SectionTitle('Font type'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final f in _fontFamilies)
                _Choice(
                  label: f == 'System' ? 'System' : f,
                  selected: settings.fontFamily == f,
                  onTap: () => settings.setFontFamily(f),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'System fonts for now — bundled editorial fonts are coming in a '
            'later update.',
            style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 20),

          const _SectionTitle('View'),
          Row(
            children: [
              _Choice(
                label: 'Grid',
                selected: settings.viewMode == ViewMode.grid,
                onTap: () => settings.setViewMode(ViewMode.grid),
              ),
              const SizedBox(width: 10),
              _Choice(
                label: 'List',
                selected: settings.viewMode == ViewMode.list,
                onTap: () => settings.setViewMode(ViewMode.list),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _SectionTitle('Default export format'),
          Row(
            children: [
              _Choice(
                label: 'PDF',
                selected: settings.exportFormat == ExportFormat.pdf,
                onTap: () => settings.setExportFormat(ExportFormat.pdf),
              ),
              const SizedBox(width: 10),
              _Choice(
                label: '.txt',
                selected: settings.exportFormat == ExportFormat.txt,
                onTap: () => settings.setExportFormat(ExportFormat.txt),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _SectionTitle('Export & backup'),
          const _ExportAllTile(),
          const SizedBox(height: 20),

          const _SectionTitle('Privacy'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.greenDeep),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Local-only storage',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text(
                        'Your notes are stored on this device only. Notoo does '
                        'not collect or send anything anywhere.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.inkSoft, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _appearanceLabel(Appearance a) {
    switch (a) {
      case Appearance.light:
        return 'Light';
      case Appearance.dark:
        return 'Dark';
      case Appearance.amoled:
        return 'AMOLED';
    }
  }
}

class _ExportAllTile extends StatelessWidget {
  const _ExportAllTile();

  @override
  Widget build(BuildContext context) {
    final notes = context.read<NotesStore>();

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.picture_as_pdf_outlined),
          title: const Text('Export all notes as PDF'),
          onTap: () => _run(context, notes, ExportFormat.pdf),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description_outlined),
          title: const Text('Export all notes as .txt'),
          onTap: () => _run(context, notes, ExportFormat.txt),
        ),
      ],
    );
  }

  Future<void> _run(
      BuildContext context, NotesStore notes, ExportFormat format) async {
    final messenger = ScaffoldMessenger.of(context);
    final all = notes.notes.where((n) => !n.isTrashed).toList();
    if (all.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No notes to export yet.')),
      );
      return;
    }
    try {
      final path = await ExportService.exportAll(all, format);
      await ExportService.shareFile(path, text: 'Notoo export');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.inkSoft,
            letterSpacing: 0.3),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.green.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
              color: selected ? AppColors.green : AppColors.hairline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.greenDeep : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}
