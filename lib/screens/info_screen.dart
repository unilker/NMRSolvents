import 'package:flutter/material.dart';

import '../app_info.dart';
import '../widgets/common.dart';

/// About the app: developer, features, data provenance and references.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repo;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final references = repo.references.values.toList();
    final babijNumber = references.indexWhere((r) => r.id == 'babij2016') + 1;
    final signalCount = repo.impurities.fold<int>(
      0,
      (n, i) => n + i.signals.length,
    );
    final features = [
      (Icons.science_outlined, l10n.feature1),
      (Icons.list_alt_outlined, l10n.feature2),
      (Icons.manage_search, l10n.feature3),
      (Icons.scatter_plot_outlined, l10n.feature4),
      (Icons.thermostat_outlined, l10n.feature5),
      (Icons.palette_outlined, l10n.feature6),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabInfo)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: scheme.primary,
                  child: Icon(Icons.science, size: 32, color: scheme.onPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        l10n.versionLabel(kAppVersion),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(l10n.developer),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: Icon(Icons.person_outline, color: scheme.primary),
              title: const Text(
                kDeveloper,
                key: Key('developer'),
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ),
          ),
          SectionHeader(l10n.aboutApp),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.aboutText, style: theme.textTheme.bodyMedium),
          ),
          SectionHeader(l10n.features),
          for (final (icon, text) in features)
            ListTile(
              dense: true,
              leading: Icon(icon, color: scheme.primary),
              title: Text(text, style: theme.textTheme.bodyMedium),
            ),
          SectionHeader(l10n.dataContent),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dataStats(
                    repo.solvents.length,
                    repo.impurities.length,
                    signalCount,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(l10n.dataMethodText, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          SectionHeader(l10n.disclaimerTitle),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: scheme.secondary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: scheme.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.disclaimerText,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(l10n.referenceList),
          for (var i = 0; i < references.length; i++)
            ReferenceCard(references[i], number: i + 1),
          if (babijNumber > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                l10n.chem21Source(babijNumber),
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
