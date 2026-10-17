import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/notes_store.dart';
import '../data/settings_store.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/patterns.dart';
import '../widgets/motion.dart';
import 'trash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ---------- Appearance ----------
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
          const SizedBox(height: 22),

          // ---------- Accent colour ----------
          _SectionTitle('Accent colour · ${settings.accent.name}'),
          _AccentGrid(settings: settings),
          const SizedBox(height: 22),

          // ---------- Font ----------
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
                  label: '${(settings.fontScale * 100).round()}%',
                  onChanged: settings.setFontScale,
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          _SectionTitle('Font · ${settings.fontFamily}'),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kFontFamilies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final f = kFontFamilies[i];
                final selected = settings.fontFamily == f;
                return GestureDetector(
                  onTap: () => settings.setFontFamily(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 128,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary.withValues(alpha: 0.14)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: f == 'System' ? null : f,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Aa Bb 123',
                          style: TextStyle(
                            fontFamily: f == 'System' ? null : f,
                            fontSize: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),

          // ---------- Writing pad ----------
          const _SectionTitle('Writing pad background'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < AppColors.papers.length; i++)
                _PaperSwatch(
                  index: i,
                  selected: settings.editorPaperIndex == i,
                  onTap: () => settings.setEditorPaperIndex(i),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const _SectionTitle('Writing pad pattern'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < PaperPattern.values.length; i++)
                _PatternSwatch(
                  index: i,
                  selected: settings.paperPatternIndex == i,
                  onTap: () => settings.setPaperPatternIndex(i),
                ),
            ],
          ),
          const SizedBox(height: 22),

          // ---------- View ----------
          const _SectionTitle('Home layout'),
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
          const SizedBox(height: 22),

          // ---------- Export ----------
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
          const SizedBox(height: 12),
          const _ExportAllTile(),
          const SizedBox(height: 22),

          // ---------- Trash ----------
          const _SectionTitle('Trash'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Open trash'),
              subtitle: const Text('Restore or permanently delete notes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrashScreen()),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ---------- Privacy ----------
          const _SectionTitle('Privacy'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Local-only storage',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text(
                        'Your notes live on this device only. Notoo does not '
                        'collect or send anything anywhere.',
                        style: TextStyle(fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ---------- Credits ----------
          const _SectionTitle('Credits & licences'),
          Text(
            'Sticker art: Open Doodles by Pablo Stanley (CC0, public domain); '
            'Twemoji graphics (CC BY 4.0). Fonts: Google Fonts (SIL Open Font '
            'License). Notoo itself is MIT licensed.',
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
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

class _AccentGrid extends StatelessWidget {
  const _AccentGrid({required this.settings});
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = AppTheme.isLight(settings.appearance);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var i = 0; i < kAccents.length; i++)
          Bouncy(
            onTap: () => settings.setAccentIndex(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: light ? kAccents[i].light : kAccents[i].dark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: settings.accentIndex == i
                      ? theme.colorScheme.onSurface
                      : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: settings.accentIndex == i
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
      ],
    );
  }
}

class _PatternSwatch extends StatelessWidget {
  const _PatternSwatch({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PaperBackground(
                pattern: PaperPattern.values[index],
                color: theme.colorScheme.surface,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(kPaperPatternNames[index],
              style: TextStyle(
                  fontSize: 10.5,
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _PaperSwatch extends StatelessWidget {
  const _PaperSwatch({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.papers[index];
    final onColor = ThemeData.estimateBrightnessForColor(color) ==
            Brightness.dark
        ? Colors.white
        : const Color(0xFF2E2A24);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? theme.colorScheme.primary : theme.dividerColor,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Center(
              child: Text('Aa',
                  style: TextStyle(
                      color: onColor, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 4),
          Text(AppColors.paperNames[index],
              style: TextStyle(
                  fontSize: 10.5, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ExportAllTile extends StatelessWidget {
  const _ExportAllTile();

  @override
  Widget build(BuildContext context) {
    final notes = context.read<NotesStore>();
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Export all notes as PDF'),
            onTap: () => _run(context, notes, ExportFormat.pdf),
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Export all notes as .txt'),
            onTap: () => _run(context, notes, ExportFormat.txt),
          ),
        ],
      ),
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
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
