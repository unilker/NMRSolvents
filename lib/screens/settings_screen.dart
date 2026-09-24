import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_themes.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static String paletteName(AppLocalizations l10n, String id) => switch (id) {
    'midnight' => l10n.themeMidnight,
    'crimson' => l10n.themeCrimson,
    'ocean' => l10n.themeOcean,
    'emerald' => l10n.themeEmerald,
    'graphite' => l10n.themeGraphite,
    _ => l10n.themeClassic,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = AppScope.of(context).settings;
    final languageCode = settings.locale?.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionHeader(l10n.language),
          RadioGroup<String?>(
            groupValue: languageCode,
            onChanged: (code) =>
                settings.setLocale(code == null ? null : Locale(code)),
            child: Column(
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(l10n.systemLanguage),
                ),
                const RadioListTile<String?>(
                  value: 'tr',
                  title: Text('Türkçe'),
                ),
                const RadioListTile<String?>(
                  value: 'en',
                  title: Text('English'),
                ),
              ],
            ),
          ),
          SectionHeader(l10n.theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Two tiles per row on phones, more on wider screens.
                final columns = (constraints.maxWidth / 170).floor().clamp(
                  2,
                  6,
                );
                final width =
                    (constraints.maxWidth - 10 * (columns - 1)) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final p in appPalettes)
                      _PaletteTile(
                        palette: p,
                        width: width,
                        label: paletteName(l10n, p.id),
                        selected: settings.palette.id == p.id,
                        onTap: () => settings.setPalette(p.id),
                      ),
                  ],
                );
              },
            ),
          ),
          SectionHeader(l10n.appearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto),
                      label: Text(l10n.modeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode),
                      label: Text(l10n.modeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode),
                      label: Text(l10n.modeDark),
                    ),
                  ],
                  selected: {settings.preferredThemeMode},
                  onSelectionChanged: settings.palette.darkOnly
                      ? null
                      : (s) => settings.setThemeMode(s.first),
                ),
                if (settings.palette.darkOnly)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.darkOnlyTheme,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.width,
  });

  final AppPalette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = palette.darkOnly ? palette.surfaceDark : const Color(0xFF111111);
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (final c in [
                    bg,
                    palette.primaryLight,
                    palette.secondaryLight,
                  ])
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                    ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle, color: scheme.primary, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
