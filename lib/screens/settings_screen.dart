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
import '../widgets/ui.dart';
import 'trash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          // Profile
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline,
                    color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(settings.userName,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600)),
                    Text('A little space for every thought.',
                        style: TextStyle(
                            fontSize: 10.5,
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _Set(title: 'Your name', children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                initialValue: settings.userName,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'friend',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onFieldSubmitted: settings.setUserName,
              ),
            ),
          ]),

          _Set(title: 'Appearance', children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Wrap(
                spacing: 6,
                children: [
                  for (final a in Appearance.values)
                    _Seg(
                      label: _appearanceLabel(a),
                      on: settings.appearance == a,
                      onTap: () => settings.setAppearance(a),
                    ),
                ],
              ),
            ),
            _Row(
              label: 'Accent colour',
              value: settings.accent.name,
            ),
            _AccentGrid(settings: settings),
            _Row(label: 'Font size', value: '${(settings.fontScale * 100).round()}%'),
            Slider(
              value: settings.fontScale,
              min: 0.85,
              max: 1.4,
              divisions: 11,
              onChanged: settings.setFontScale,
            ),
            _Row(label: 'Font type', value: settings.fontFamily),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: kFontFamilies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = kFontFamilies[i];
                  final on = settings.fontFamily == f;
                  return GestureDetector(
                    onTap: () => settings.setFontFamily(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 104,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: on
                            ? AppColors.greenLight
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: on ? theme.colorScheme.primary : theme.dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: f == 'System' ? null : f,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('Aa Bb',
                              style: TextStyle(
                                  fontFamily: f == 'System' ? null : f,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),

          _Set(title: 'View', children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Wrap(
                spacing: 6,
                children: [
                  _Seg(
                    label: 'Grid',
                    on: settings.viewMode == ViewMode.grid,
                    onTap: () => settings.setViewMode(ViewMode.grid),
                  ),
                  _Seg(
                    label: 'List',
                    on: settings.viewMode == ViewMode.list,
                    onTap: () => settings.setViewMode(ViewMode.list),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Wrap(
                spacing: 6,
                children: [
                  _Seg(
                    label: 'Export PDF',
                    on: settings.exportFormat == ExportFormat.pdf,
                    onTap: () => settings.setExportFormat(ExportFormat.pdf),
                  ),
                  _Seg(
                    label: 'Export .txt',
                    on: settings.exportFormat == ExportFormat.txt,
                    onTap: () => settings.setExportFormat(ExportFormat.txt),
                  ),
                ],
              ),
            ),
          ]),

          _Set(title: 'Writing pad', children: [
            _Row(label: 'Background', value: AppColors.paperNames[settings.editorPaperIndex]),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < AppColors.papers.length; i++)
                  _PaperSwatch(
                    index: i,
                    selected: settings.editorPaperIndex == i,
                    onTap: () => settings.setEditorPaperIndex(i),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _Row(label: 'Pattern', value: kPaperPatternNames[settings.paperPatternIndex]),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < PaperPattern.values.length; i++)
                  _PatternSwatch(
                    index: i,
                    selected: settings.paperPatternIndex == i,
                    onTap: () => settings.setPaperPatternIndex(i),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ]),

          _Set(title: 'Storage & Backup', children: [
            _Row(
              label: 'Export all as PDF',
              value: '›',
              onTap: () => _exportAll(context, ExportFormat.pdf),
            ),
            _Row(
              label: 'Export all as .txt',
              value: '›',
              onTap: () => _exportAll(context, ExportFormat.txt),
            ),
            _Row(
              label: 'Trash',
              value: '›',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrashScreen()),
              ),
            ),
          ]),

          _Set(title: 'Privacy', children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No internet usage',
                            style: TextStyle(fontSize: 11.5)),
                        Text('Your data stays on your device.',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
                  _Toggle(value: true, onChanged: (_) {}),
                ],
              ),
            ),
          ]),

          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Sticker art: Open Doodles by Pablo Stanley (CC0); Twemoji '
              'graphics (CC BY 4.0). Fonts: Google Fonts (SIL OFL). '
              'Notoo is MIT licensed.',
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: theme.colorScheme.onSurfaceVariant,
              ),
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

  Future<void> _exportAll(BuildContext context, ExportFormat format) async {
    final notes = context.read<NotesStore>();
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

class _Set extends StatelessWidget {
  const _Set({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 11.5)),
            ),
            Text(value,
                style: TextStyle(
                    fontSize: 10.5,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: on ? AppColors.greenLight : AppColors.chip,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
            color: on ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 34,
        height: 20,
        decoration: BoxDecoration(
          color: value ? theme.colorScheme.primary : AppColors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _AccentGrid extends StatelessWidget {
  const _AccentGrid({required this.settings});
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = AppTheme.isLight(settings.appearance);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < kAccents.length; i++)
            Bouncy(
              onTap: () => settings.setAccentIndex(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
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
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
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
        : AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 3),
          Text(AppColors.paperNames[index],
              style: TextStyle(
                  fontSize: 9.5, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? theme.colorScheme.primary : theme.dividerColor,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: PaperBackground(
                pattern: PaperPattern.values[index],
                color: theme.colorScheme.surface,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(kPaperPatternNames[index],
              style: TextStyle(
                  fontSize: 9.5, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
