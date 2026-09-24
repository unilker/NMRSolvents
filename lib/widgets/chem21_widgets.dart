import 'package:flutter/material.dart';

import '../data/h_statements.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../screens/chem21_screen.dart';
import 'common.dart';

const _green = Color(0xFF2E9E44);
const _amber = Color(0xFFE0A800);
const _red = Color(0xFFD32F2F);
const _darkRed = Color(0xFF8E0000);

Color chem21Color(Chem21 rank) => switch (rank) {
  Chem21.recommended => _green,
  Chem21.problematic => _amber,
  Chem21.hazardous => _red,
  Chem21.highlyHazardous => _darkRed,
};

/// The paper's colour code: 1–3 green, 4–6 yellow, 7–10 red.
Color scoreColor(int score) => score <= 3
    ? _green
    : score <= 6
    ? _amber
    : _red;

String chem21Label(AppLocalizations l10n, Chem21 rank) => switch (rank) {
  Chem21.recommended => l10n.rankRecommended,
  Chem21.problematic => l10n.rankProblematic,
  Chem21.hazardous => l10n.rankHazardous,
  Chem21.highlyHazardous => l10n.rankHighlyHazardous,
};

String chem21Definition(AppLocalizations l10n, Chem21 rank) => switch (rank) {
  Chem21.recommended => l10n.rankRecommendedDef,
  Chem21.problematic => l10n.rankProblematicDef,
  Chem21.hazardous => l10n.rankHazardousDef,
  Chem21.highlyHazardous => l10n.rankHighlyHazardousDef,
};

IconData chem21Icon(Chem21 rank) => switch (rank) {
  Chem21.recommended => Icons.check_circle,
  Chem21.problematic => Icons.warning_amber_rounded,
  Chem21.hazardous => Icons.dangerous_outlined,
  Chem21.highlyHazardous => Icons.block,
};

/// Coloured pill with the CHEM21 ranking; [compact] shows the icon only.
class Chem21RankBadge extends StatelessWidget {
  const Chem21RankBadge(this.rank, {super.key, this.compact = false});

  final Chem21 rank;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = chem21Color(rank);
    final label = chem21Label(l10n, rank);
    if (compact) {
      return Tooltip(
        message: 'CHEM21: $label',
        child: Icon(chem21Icon(rank), size: 16, color: color),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chem21Icon(rank), size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small "S 4 · H 3 · E 3" score chips for list rows.
class Chem21MiniScores extends StatelessWidget {
  const Chem21MiniScores(this.entry, {super.key});

  final Chem21Entry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget chip(String label, int score) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: scoreColor(score).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label $score',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: scoreColor(score),
        ),
      ),
    );
    // Wraps instead of overflowing next to a wide ranking badge.
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        chip(l10n.safetyScore.substring(0, 1), entry.safety),
        chip(l10n.healthScore.substring(0, 1), entry.health),
        chip(l10n.envScore.substring(0, 1), entry.env),
      ],
    );
  }
}

/// Full CHEM21 assessment of one solvent: ranking, the three scores, and
/// the data behind them.
class Chem21Card extends StatelessWidget {
  const Chem21Card(this.entry, {super.key, this.subtitle});

  final Chem21Entry entry;

  /// E.g. "Unlabeled chloroform" on a deuterated solvent page.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = context.lang;

    String statement(String code) => switch (code) {
      'None' => l10n.hNone,
      'n.a.' => l10n.hNa,
      _ => [
        code,
        if (hStatements[code] case final h?) lang == 'tr' ? h.tr : h.en,
      ].join(' – '),
    };

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle ?? entry.name.of(lang),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Chem21RankBadge(entry.rank),
              ],
            ),
            if (entry.rank != entry.rankDefault) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.rankingDefault}: '
                '${chem21Label(l10n, entry.rankDefault)}. '
                '${l10n.rankChangedNote}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _ScoreTile(label: l10n.safetyScore, score: entry.safety),
                const SizedBox(width: 8),
                _ScoreTile(label: l10n.healthScore, score: entry.health),
                const SizedBox(width: 8),
                _ScoreTile(label: l10n.envScore, score: entry.env),
              ],
            ),
            const SizedBox(height: 12),
            row(l10n.boilingPoint, '${entry.bp} °C'),
            row(l10n.flashPoint, entry.fp == 'na' ? '–' : '${entry.fp} °C'),
            row(l10n.worstH3, statement(entry.h3)),
            row(l10n.worstH4, statement(entry.h4)),
            if (entry.cas != null) row(l10n.casNumber, entry.cas!),
            if (entry.note != null)
              row(
                l10n.note,
                entry.note == 'solid'
                    ? l10n.noteSolid
                    : l10n.noteWaterSensitive,
              ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SourceTag('prat2016'),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Chem21ScoringScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: Text(l10n.howScored),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = scoreColor(score);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$score',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
