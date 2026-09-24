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

/// "7.26", or "7.22–7.28" for a range.
String formatShiftValue(ShiftValue v) => v.shiftMax == null
    ? formatShift(v.shift)
    : '${formatShift(v.shift)}–${formatShift(v.shiftMax!)}';

/// Uppercases with Turkish dotted/dotless i rules when [lang] is "tr".
String localeUpper(String text, String lang) => lang == 'tr'
    ? text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase()
    : text.toUpperCase();

/// Renders atom counts as subscripts: CDCl3 → CDCl₃, (CH3)2 → (CH₃)₂.
///
/// Only digits following a letter, a closing bracket or another count are
/// counts; position numbers such as the ones in "CH(2,4,6)" are kept.
String prettyFormula(String formula) {
  const sub = '₀₁₂₃₄₅₆₇₈₉';
  final out = StringBuffer();
  var inCount = false;
  for (final ch in formula.split('')) {
    final digit = int.tryParse(ch);
    final prev = out.isEmpty ? '' : out.toString()[out.length - 1];
    final afterAtom = RegExp(r'[A-Za-z\)\]]').hasMatch(prev);
    if (digit != null && (afterAtom || inCount)) {
      out.write(sub[digit]);
      inCount = true;
    } else {
      out.write(ch);
      inCount = false;
    }
  }
  return out.toString();
}

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
    required this.value,
    this.mult,
  });

  final Nucleus nucleus;
  final ShiftValue value;
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
              text: formatShiftValue(value),
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

/// Small label naming the article a value comes from, e.g. "Fulmer 2010".
class SourceTag extends StatelessWidget {
  const SourceTag(this.refId, {super.key});

  final String refId;

  @override
  Widget build(BuildContext context) {
    final ref = context.repo.referenceById(refId);
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: ref?.citation ?? refId,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          ref?.short ?? refId,
          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// Green "recommended" / amber "problematic" CHEM21 rating.
class Chem21Badge extends StatelessWidget {
  const Chem21Badge(this.rating, {super.key, this.compact = false});

  final Chem21 rating;

  /// Icon only, for list rows.
  final bool compact;

  static const _green = Color(0xFF2E9E44);
  static const _amber = Color(0xFFE0A800);

  @override
  Widget build(BuildContext context) {
    final rec = rating == Chem21.recommended;
    final color = rec ? _green : _amber;
    final icon = Icon(
      rec ? Icons.change_history : Icons.details,
      size: compact ? 14 : 16,
      color: color,
    );
    final label = rec
        ? context.l10n.chem21Recommended
        : context.l10n.chem21Problematic;
    return Tooltip(
      message: '$label\n${context.l10n.chem21Hint}',
      child: compact
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 4),
                Text(label, style: TextStyle(fontSize: 12, color: color)),
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
      localeUpper(text, context.lang),
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
/// represented by a null value. Only solvents with impurity data are listed.
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
    final solvents = context.repo.solventsWithImpurityData;
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
                  if (reference.doi != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'DOI: ${reference.doi}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (reference.doiUrl != null)
              IconButton(
                tooltip: 'DOI',
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: reference.doiUrl!));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(context.l10n.copied)));
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
