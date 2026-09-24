import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_info.dart';
import '../widgets/common.dart';

/// About the app: developer, features, data provenance, references and
/// license.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repo;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final references = repo.references.values.toList();
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
      (Icons.eco_outlined, l10n.feature7),
      (Icons.palette_outlined, l10n.feature6),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabInfo)),
      body: ListView(
        padding: pageBottomPadding(context, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icon/app_icon_256.png',
                    key: const Key('appIcon'),
                    width: 64,
                    height: 64,
                  ),
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
          SectionHeader(l10n.license),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GNU GPL v3.0',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.licenseText, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    '© $kCopyrightYear $kDeveloper',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Divider(height: 20),
                  Text(l10n.sourceCode, style: theme.textTheme.bodySmall),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          kSourceUrl,
                          style: TextStyle(color: scheme.primary),
                        ),
                      ),
                      IconButton(
                        key: const Key('copySourceUrl'),
                        tooltip: l10n.sourceCode,
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: kSourceUrl),
                          );
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(l10n.copied)));
                        },
                      ),
                    ],
                  ),
                  TextButton.icon(
                    key: const Key('packageLicenses'),
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: l10n.appTitle,
                      applicationVersion: kAppVersion,
                      applicationLegalese:
                          '© $kCopyrightYear $kDeveloper · GPL-3.0',
                    ),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: Text(l10n.packageLicenses),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
