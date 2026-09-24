import 'package:flutter/material.dart';

import '../data/search.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/app_themes.dart';
import '../widgets/common.dart';
import '../records/analysis_record.dart';
import '../records/records_store.dart';
import 'impurity_detail_screen.dart';
import 'records_screen.dart';

enum _Mode { single, multiple }

/// Reverse lookup: "what is the peak at δ X in solvent Y?"
class PeakSearchScreen extends StatefulWidget {
  const PeakSearchScreen({super.key});

  @override
  State<PeakSearchScreen> createState() => _PeakSearchScreenState();
}

class _PeakSearchScreenState extends State<PeakSearchScreen> {
  /// Splitting patterns offered in step 3, with their display names.
  static List<(String, String)> _multiplicities(AppLocalizations l10n) => [
    ('s', l10n.multS),
    ('d', l10n.multD),
    ('t', l10n.multT),
    ('q', l10n.multQ),
    ('quint', l10n.multQuint),
    ('sept', l10n.multSept),
    ('dd', l10n.multDd),
    ('m', l10n.multM),
    ('br s', l10n.multBrS),
  ];

  final _input = TextEditingController();

  /// Peak rows of the multiple-peak mode: a shift field and a splitting each.
  final List<_PeakRow> _rows = [_PeakRow(), _PeakRow(), _PeakRow()];
  _Mode _mode = _Mode.single;
  String _solventId = 'cdcl3';
  Nucleus _nucleus = Nucleus.h1;
  String? _multiplicity;
  final Map<Nucleus, double> _tolerance = {Nucleus.h1: 0.05, Nucleus.c13: 0.5};

  /// The slider runs from max/30 to max in 30 steps: 0.01–0.30 ppm for ¹H,
  /// 0.1–3.0 ppm for ¹³C.
  static double _maxTolerance(Nucleus n) => n == Nucleus.h1 ? 0.3 : 3.0;
  static const _toleranceSteps = 30;

  @override
  void dispose() {
    _input.dispose();
    for (final r in _rows) {
      r.controller.dispose();
    }
    super.dispose();
  }

  /// Peaks entered in the multiple-peak rows. A splitting typed after the
  /// number ("4.12 q") counts when none is selected in the row.
  List<ObservedPeak> _observedPeaks() => [
    for (final r in _rows)
      if (parsePeakList(r.controller.text).firstOrNull case final p?)
        (ppm: p.ppm, mult: _nucleus == Nucleus.h1 ? (r.mult ?? p.mult) : null),
  ];

  /// A whole peak list pasted into one row ("2.05 s, 4.12 q, 1.26 t") is
  /// spread over as many rows as it has peaks.
  void _onRowChanged(int index, String text) {
    final peaks = parsePeakList(text);
    if (peaks.length < 2) {
      setState(() {});
      return;
    }
    setState(() {
      // The pasted peaks replace this row; empty rows left over are dropped.
      final pasted = _rows[index];
      final removed = [
        pasted,
        ..._rows.where((r) => r.controller.text.trim().isEmpty),
      ];
      final rebuilt = [
        for (final r in _rows)
          if (r == pasted)
            for (final p in peaks)
              _PeakRow(text: _formatPpm(p.ppm))..mult = p.mult
          else if (!removed.contains(r))
            r,
      ];
      _rows
        ..clear()
        ..addAll(rebuilt);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final r in removed) {
          r.controller.dispose();
        }
      });
    });
  }

  static String _formatPpm(double v) {
    final s = v.toString();
    return s.contains('.') && s.split('.').last.length < 2
        ? v.toStringAsFixed(2)
        : s;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repo;
    final solvent = repo.solventById(_solventId) ?? repo.solvents.first;
    final tolerance = _tolerance[_nucleus]!;
    final shifts = parseShifts(_input.text);
    final observed = _mode == _Mode.multiple
        ? _observedPeaks()
        : const <ObservedPeak>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabPeakSearch)),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverList.list(
              children: [
                SegmentedButton<_Mode>(
                  segments: [
                    ButtonSegment(
                      value: _Mode.single,
                      icon: const Icon(Icons.adjust),
                      label: Text(l10n.singlePeak),
                    ),
                    ButtonSegment(
                      value: _Mode.multiple,
                      icon: const Icon(Icons.scatter_plot_outlined),
                      label: Text(l10n.multiplePeaks),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: 16),
                _StepHeader(number: 1, title: l10n.stepSolvent),
                SolventDropdown(
                  value: _solventId,
                  onChanged: (id) => setState(() => _solventId = id!),
                ),
                const SizedBox(height: 16),
                _StepHeader(
                  number: 2,
                  title: _mode == _Mode.single
                      ? l10n.stepShift
                      : l10n.stepShifts,
                ),
                if (_mode == _Mode.single)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('peakInput'),
                          controller: _input,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.shiftInputLabel,
                            hintText: '4.30',
                            prefixIcon: const Icon(Icons.show_chart),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _nucleusToggle(),
                    ],
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.peakRowsHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _nucleusToggle(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < _rows.length; i++)
                    _PeakRowEditor(
                      key: ObjectKey(_rows[i]),
                      index: i,
                      row: _rows[i],
                      showMultiplicity: _nucleus == Nucleus.h1,
                      multiplicities: _multiplicities(l10n),
                      onChanged: (text) => _onRowChanged(i, text),
                      onMultChanged: (m) => setState(() => _rows[i].mult = m),
                      onRemove: _rows.length > 1
                          ? () => setState(() {
                              final r = _rows.removeAt(i);
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => r.controller.dispose(),
                              );
                            })
                          : null,
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('addPeak'),
                      onPressed: () => setState(() => _rows.add(_PeakRow())),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addPeak),
                    ),
                  ),
                ],
                Row(
                  children: [
                    Text(
                      l10n.toleranceLabel(
                        tolerance.toStringAsFixed(
                          _nucleus == Nucleus.h1 ? 2 : 1,
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: Slider(
                        value: tolerance,
                        min: _maxTolerance(_nucleus) / _toleranceSteps,
                        max: _maxTolerance(_nucleus),
                        divisions: _toleranceSteps - 1,
                        onChanged: (v) =>
                            setState(() => _tolerance[_nucleus] = v),
                      ),
                    ),
                  ],
                ),
                // Multiplicities are only reported for ¹H.
                if (_mode == _Mode.single && _nucleus == Nucleus.h1) ...[
                  _StepHeader(number: 3, title: l10n.stepMultiplicity),
                  Text(
                    l10n.multiplicityHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.anyMultiplicity),
                        selected: _multiplicity == null,
                        onSelected: (_) => setState(() => _multiplicity = null),
                      ),
                      for (final (code, name) in _multiplicities(l10n))
                        ChoiceChip(
                          key: Key('mult-$code'),
                          label: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                TextSpan(text: '  $name'),
                              ],
                            ),
                          ),
                          selected: _multiplicity == code,
                          onSelected: (_) =>
                              setState(() => _multiplicity = code),
                        ),
                    ],
                  ),
                ],
                const Divider(height: 24),
              ],
            ),
          ),
          if (_mode == _Mode.single ? shifts.isEmpty : observed.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.manage_search,
                text: l10n.enterValueToSearch,
              ),
            )
          else if (_mode == _Mode.single)
            _singleResults(context, solvent, shifts.first, tolerance)
          else
            _multiResults(context, solvent, observed, tolerance),
        ],
      ),
    );
  }

  Widget _nucleusToggle() => SegmentedButton<Nucleus>(
    showSelectedIcon: false,
    segments: [
      for (final n in Nucleus.values)
        ButtonSegment(value: n, label: Text(n.label)),
    ],
    selected: {_nucleus},
    onSelectionChanged: (s) => setState(() => _nucleus = s.first),
  );

  Widget _singleResults(
    BuildContext context,
    Solvent solvent,
    double ppm,
    double tolerance,
  ) {
    final l10n = context.l10n;
    final multiplicity = _nucleus == Nucleus.h1 ? _multiplicity : null;
    final hits = findPeaksNear(
      impurities: context.repo.impurities,
      solvent: solvent,
      nucleus: _nucleus,
      ppm: ppm,
      tolerance: tolerance,
      multiplicity: multiplicity,
    );
    final digits = _nucleus == Nucleus.h1 ? 2 : 1;
    final summary = [
      prettyFormula(solvent.formula),
      '${ppm.toStringAsFixed(digits)} ppm',
      if (multiplicity != null)
        _multiplicities(l10n).firstWhere((m) => m.$1 == multiplicity).$2,
    ].join('  ·  ');

    // Nothing inside the tolerance: offer the closest candidates instead of
    // an empty page.
    final nearest = hits.isNotEmpty
        ? const <PeakHit>[]
        : nearestPeaks(
            impurities: context.repo.impurities,
            solvent: solvent,
            nucleus: _nucleus,
            ppm: ppm,
            maxDistance: _maxTolerance(_nucleus) * 3,
            multiplicity: multiplicity,
          );
    // Only "compatible" hits inside the tolerance: also offer the closest
    // exact matches a little further away (shifts vary with concentration
    // and temperature).
    final closeExact =
        multiplicity == null ||
            hits.isEmpty ||
            hits.any((h) => h.multMatch == MultMatch.exact)
        ? const <PeakHit>[]
        : nearestPeaks(
            impurities: context.repo.impurities,
            solvent: solvent,
            nucleus: _nucleus,
            ppm: ppm,
            maxDistance: _maxTolerance(_nucleus) * 3,
            multiplicity: multiplicity,
            limit: 20,
          ).where((h) => h.multMatch == MultMatch.exact).take(3).toList();
    if (hits.isEmpty && nearest.isEmpty) return _noResults(context);
    final shown = hits.isNotEmpty ? hits : nearest;

    return SliverList.builder(
      itemCount:
          shown.length + 1 + (closeExact.isEmpty ? 0 : closeExact.length + 1),
      itemBuilder: (context, i) {
        if (i > shown.length) {
          final k = i - shown.length - 1;
          if (k == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.closeExactHeader,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          return _HitTile(
            hit: closeExact[k - 1],
            solvent: solvent,
            nucleus: _nucleus,
            onOpen: (imp) => _openImpurity(context, imp, solvent),
          );
        }
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hits.isNotEmpty
                            ? l10n.resultCount(hits.length)
                            : l10n.nearestHeader(
                                tolerance.toStringAsFixed(digits),
                              ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _SaveButton(
                  onPressed: () => _save(
                    context,
                    solvent: solvent,
                    mode: SearchMode.single,
                    peaks: [(ppm: ppm, mult: multiplicity)],
                    tolerance: tolerance,
                    hits: hitsFromPeakSearch(
                      [...shown, ...closeExact].take(30).toList(),
                      ppm,
                      multiplicity,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return _HitTile(
          hit: shown[i - 1],
          solvent: solvent,
          nucleus: _nucleus,
          onOpen: (imp) => _openImpurity(context, imp, solvent),
        );
      },
    );
  }

  Widget _multiResults(
    BuildContext context,
    Solvent solvent,
    List<ObservedPeak> observed,
    double tolerance,
  ) {
    final matches = matchMultiplePeaks(
      impurities: context.repo.impurities,
      solventId: solvent.id,
      nucleus: _nucleus,
      observed: observed,
      tolerance: tolerance,
    );
    if (matches.isEmpty) return _noResults(context);
    return SliverList.builder(
      itemCount: matches.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.resultCount(matches.length),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                _SaveButton(
                  onPressed: () => _save(
                    context,
                    solvent: solvent,
                    mode: SearchMode.multiple,
                    peaks: observed,
                    tolerance: tolerance,
                    hits: hitsFromMultiMatch(matches.take(20).toList()),
                  ),
                ),
              ],
            ),
          );
        }
        final m = matches[index - 1];
        return Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openImpurity(context, m.impurity, solvent),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.impurity.name.of(context.lang),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _ScoreBadge(m.score),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.matchedSignals(
                      m.matched.length,
                      m.totalSignals,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  for (final pair in m.matched)
                    _PairRow(pair: pair, nucleus: _nucleus),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Opens the record editor with the search shown on screen.
  void _save(
    BuildContext context, {
    required Solvent solvent,
    required SearchMode mode,
    required List<ObservedPeak> peaks,
    required double tolerance,
    required List<RecordHit> hits,
  }) {
    final now = DateTime.now();
    saveSearchAsRecord(
      context,
      AnalysisRecord(
        id: RecordsStore.newId(),
        sampleName: '',
        analysisDate: DateTime(now.year, now.month, now.day),
        createdAt: now,
        solventId: solvent.id,
        nucleus: _nucleus,
        mode: mode,
        peaks: peaks,
        tolerance: tolerance,
        hits: hits,
      ),
    );
  }

  Widget _noResults(BuildContext context) => SliverFillRemaining(
    hasScrollBody: false,
    child: EmptyState(icon: Icons.search_off, text: context.l10n.noResults),
  );

  void _openImpurity(BuildContext context, Impurity impurity, Solvent solvent) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImpurityDetailScreen(
          impurity: impurity,
          initialSolventId: solvent.id,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge(this.score);

  final double score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = score >= 0.75 ? scheme.primary : scheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(score * 100).round()}%',
        style: TextStyle(
          color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Numbered step title: ① Çözücü, ② Kimyasal kayma, ③ Yarılma.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: scheme.primary,
            child: Text(
              '$number',
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _HitTile extends StatelessWidget {
  const _HitTile({
    required this.hit,
    required this.solvent,
    required this.nucleus,
    required this.onOpen,
  });

  final PeakHit hit;
  final Solvent solvent;
  final Nucleus nucleus;
  final ValueChanged<Impurity> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isResidual = hit.source == HitSource.residualSolvent;
    final (
      IconData? icon,
      Color? color,
      String? label,
      String? tip,
    ) = switch (hit.multMatch) {
      MultMatch.exact => (
        Icons.check_circle,
        scheme.primary,
        l10n.matchExact,
        null,
      ),
      MultMatch.compatible => (
        Icons.adjust,
        scheme.secondary,
        l10n.matchCompatible,
        l10n.matchCompatibleHint,
      ),
      MultMatch.unknown => (
        Icons.help_outline,
        scheme.onSurfaceVariant,
        l10n.matchUnknown,
        null,
      ),
      null => (null, null, null, null),
    };

    return ListTile(
      leading: isResidual
          ? Icon(Icons.opacity, color: NmrColors.of(context).residual)
          : (icon == null ? null : Icon(icon, color: color)),
      title: Text(
        isResidual
            ? '${l10n.residualSolventPeak} (${prettyFormula(solvent.formula)})'
            : hit.impurity!.name.of(context.lang),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (hit.signal?.assignment case final a?) prettyFormula(a),
              l10n.deltaPpm(
                hit.delta.toStringAsFixed(nucleus == Nucleus.h1 ? 2 : 1),
              ),
              if (hit.signal case final s?)
                context.repo.referenceById(s.refId)?.short ?? s.refId,
            ].join(' · '),
          ),
          if (label != null)
            Tooltip(
              message: tip ?? label,
              child: Text(label, style: TextStyle(fontSize: 12, color: color)),
            ),
        ],
      ),
      trailing: ShiftChip(
        nucleus: nucleus,
        value: hit.value,
        mult: hit.signal?.multWithJ ?? hit.mult,
      ),
      onTap: isResidual ? null : () => onOpen(hit.impurity!),
    );
  }
}

class _PeakRow {
  _PeakRow({String text = ''}) : controller = TextEditingController(text: text);

  final TextEditingController controller;
  String? mult;
}

/// One observed peak in the multiple-peak mode: shift, splitting, remove.
class _PeakRowEditor extends StatelessWidget {
  const _PeakRowEditor({
    super.key,
    required this.index,
    required this.row,
    required this.showMultiplicity,
    required this.multiplicities,
    required this.onChanged,
    required this.onMultChanged,
    required this.onRemove,
  });

  final int index;
  final _PeakRow row;
  final bool showMultiplicity;
  final List<(String, String)> multiplicities;
  final ValueChanged<String> onChanged;
  final ValueChanged<String?> onMultChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              key: Key('peak-$index'),
              controller: row.controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: l10n.peakLabel(index + 1),
                hintText: 'ppm',
              ),
              onChanged: onChanged,
            ),
          ),
          if (showMultiplicity) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: DropdownButtonFormField<String?>(
                key: Key('mult-row-$index'),
                initialValue: row.mult,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.stepMultiplicityShort,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  for (final (code, name) in multiplicities)
                    DropdownMenuItem(
                      value: code,
                      child: Text(
                        '$code · $name',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onMultChanged,
              ),
            ),
          ],
          IconButton(
            tooltip: l10n.removePeak,
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

/// "4.12 q → Ethyl acetate CH₂ 4.12 q (7)" line of a multiple-peak result.
class _PairRow extends StatelessWidget {
  const _PairRow({required this.pair, required this.nucleus});

  final PeakPair pair;
  final Nucleus nucleus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, Color color, String tip) = switch (pair.multMatch) {
      MultMatch.exact => (Icons.check_circle, scheme.primary, l10n.matchExact),
      MultMatch.compatible => (
        Icons.adjust,
        scheme.secondary,
        l10n.matchCompatibleHint,
      ),
      MultMatch.unknown => (
        Icons.help_outline,
        scheme.onSurfaceVariant,
        l10n.matchUnknown,
      ),
      null => (Icons.circle_outlined, scheme.outline, ''),
    };
    final observed = [
      formatShift(pair.observed.ppm),
      ?pair.observed.mult,
    ].join(' ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Tooltip(
            message: tip,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            child: Text(
              observed,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.arrow_right_alt, size: 18),
          const SizedBox(width: 4),
          ShiftChip(
            nucleus: nucleus,
            value: pair.signal,
            mult: pair.signal.multWithJ,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              prettyFormula(pair.signal.assignment ?? ''),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
    key: const Key('saveResults'),
    onPressed: onPressed,
    icon: const Icon(Icons.bookmark_add_outlined),
    label: Text(context.l10n.saveResults),
  );
}
