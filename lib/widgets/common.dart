import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/repository.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../settings/settings_controller.dart';
import '../theme/app_themes.dart';

/// Makes the repository and settings available to every screen.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.repository,
    required this.settings,
    required super.child,
  });

  final NmrRepository repository;
  final SettingsController settings;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      repository != oldWidget.repository || settings != oldWidget.settings;
}

extension ContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  NmrRepository get repo => AppScope.of(this).repository;
  String get lang => Localizations.localeOf(this).languageCode;
}

String formatShift(double shift) => shift.toStringAsFixed(2);

/// Renders the digits of a molecular formula as subscripts: CDCl3 → CDCl₃.
String prettyFormula(String formula) => formula.replaceAllMapped(
  RegExp(r'\d'),
  (m) => '₀₁₂₃₄₅₆₇₈₉'[int.parse(m[0]!)],
);

Color nucleusColor(BuildContext context, Nucleus nucleus) {
  final c = NmrColors.of(context);
  return nucleus == Nucleus.h1 ? c.proton : c.carbon;
}

/// Small colored label such as "¹H" or "¹³C".
class NucleusBadge extends StatelessWidget {
  const NucleusBadge(this.nucleus, {super.key});

  final Nucleus nucleus;

  @override
  Widget build(BuildContext context) {
    final color = nucleusColor(context, nucleus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        nucleus.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// A chemical shift value, colored by nucleus.
class ShiftChip extends StatelessWidget {
  const ShiftChip({
    super.key,
    required this.nucleus,
    required this.shift,
    this.mult,
  });

  final Nucleus nucleus;
  final double shift;
  final String? mult;

  @override
  Widget build(BuildContext context) {
    final color = nucleusColor(context, nucleus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: formatShift(shift),
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            if (mult != null)
              TextSpan(
                text: ' $mult',
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        style: const TextStyle(
          fontSize: 13,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Flags data that has not yet been checked against its source article.
class UnverifiedBadge extends StatelessWidget {
  const UnverifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Tooltip(
      message: context.l10n.notVerifiedHint,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            context.l10n.notVerified,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => controller.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    ),
  );
}

/// Dropdown to pick a deuterated solvent. [allowAll] adds an "all" entry
/// represented by a null value.
class SolventDropdown extends StatelessWidget {
  const SolventDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowAll = false,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool allowAll;

  @override
  Widget build(BuildContext context) {
    final solvents = context.repo.solvents;
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: context.l10n.solvent),
      items: [
        if (allowAll)
          DropdownMenuItem(value: null, child: Text(context.l10n.allSolvents)),
        for (final s in solvents)
          DropdownMenuItem(
            value: s.id,
            child: Text(
              '${prettyFormula(s.formula)}  ·  ${s.name.of(context.lang)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class ReferenceCard extends StatelessWidget {
  const ReferenceCard(this.reference, {super.key});

  final Reference reference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reference.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(reference.citation, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    'DOI: ${reference.doi}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'DOI',
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: reference.doiUrl));
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(context.l10n.copied)));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
