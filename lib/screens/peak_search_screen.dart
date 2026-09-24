import 'package:flutter/material.dart';

import '../data/search.dart';
import '../models/models.dart';
import '../theme/app_themes.dart';
import '../widgets/common.dart';
import 'impurity_detail_screen.dart';

enum _Mode { single, multiple }

/// Reverse lookup: "what is the peak at δ X in solvent Y?"
class PeakSearchScreen extends StatefulWidget {
  const PeakSearchScreen({super.key});

  @override
  State<PeakSearchScreen> createState() => _PeakSearchScreenState();
}

class _PeakSearchScreenState extends State<PeakSearchScreen> {
  static const _multiplicities = [
    's', 'd', 't', 'q', 'quint', 'sept', 'm', 'br s', //
  ];

  final _input = TextEditingController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repo;
    final solvent = repo.solventById(_solventId) ?? repo.solvents.first;
    final tolerance = _tolerance[_nucleus]!;
    final shifts = parseShifts(_input.text);

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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SolventDropdown(
                        value: _solventId,
                        onChanged: (id) => setState(() => _solventId = id!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SegmentedButton<Nucleus>(
                      showSelectedIcon: false,
                      segments: [
                        for (final n in Nucleus.values)
                          ButtonSegment(value: n, label: Text(n.label)),
                      ],
                      selected: {_nucleus},
                      onSelectionChanged: (s) =>
                          setState(() => _nucleus = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('peakInput'),
                  controller: _input,
                  keyboardType: _mode == _Mode.single
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: _mode == _Mode.single
                        ? l10n.shiftInputLabel
                        : l10n.peaksInputLabel,
                    hintText: _mode == _Mode.single
                        ? '2.05'
                        : l10n.peaksInputHint,
                    prefixIcon: const Icon(Icons.show_chart),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      l10n.toleranceLabel(
                        tolerance.toStringAsFixed(
                          _nucleus == Nucleus.h1 ? 2 : 1,
                        ),
                      ),
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
                if (_mode == _Mode.single)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.anyMultiplicity),
                        selected: _multiplicity == null,
                        onSelected: (_) => setState(() => _multiplicity = null),
                      ),
                      for (final m in _multiplicities)
                        ChoiceChip(
                          label: Text(m),
                          selected: _multiplicity == m,
                          onSelected: (_) => setState(() => _multiplicity = m),
                        ),
                    ],
                  ),
                const Divider(height: 24),
              ],
            ),
          ),
          if (shifts.isEmpty)
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
            _multiResults(context, solvent, shifts, tolerance),
        ],
      ),
    );
  }

  Widget _singleResults(
    BuildContext context,
    Solvent solvent,
    double ppm,
    double tolerance,
  ) {
    final hits = findPeaksNear(
      impurities: context.repo.impurities,
      solvent: solvent,
      nucleus: _nucleus,
      ppm: ppm,
      tolerance: tolerance,
      multiplicity: _multiplicity,
    );
    if (hits.isEmpty) return _noResults(context);
    return SliverList.builder(
      itemCount: hits.length,
      itemBuilder: (context, i) {
        final hit = hits[i];
        final isResidual = hit.source == HitSource.residualSolvent;
        return ListTile(
          leading: isResidual
              ? Icon(Icons.opacity, color: NmrColors.of(context).residual)
              : null,
          title: Text(
            isResidual
                ? '${context.l10n.residualSolventPeak} (${prettyFormula(solvent.formula)})'
                : hit.impurity!.name.of(context.lang),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            [
              if (hit.assignment != null) hit.assignment!,
              context.l10n.deltaPpm(
                hit.delta.toStringAsFixed(_nucleus == Nucleus.h1 ? 2 : 1),
              ),
            ].join(' · '),
          ),
          trailing: ShiftChip(
            nucleus: _nucleus,
            shift: hit.shift,
            mult: hit.mult,
          ),
          onTap: isResidual
              ? null
              : () => _openImpurity(context, hit.impurity!, solvent),
        );
      },
    );
  }

  Widget _multiResults(
    BuildContext context,
    Solvent solvent,
    List<double> shifts,
    double tolerance,
  ) {
    final matches = matchMultiplePeaks(
      impurities: context.repo.impurities,
      solventId: solvent.id,
      nucleus: _nucleus,
      observed: shifts,
      tolerance: tolerance,
    );
    if (matches.isEmpty) return _noResults(context);
    return SliverList.builder(
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final m = matches[i];
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
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final pair in m.matched)
                        ShiftChip(
                          nucleus: _nucleus,
                          shift: pair.signal.shift,
                          mult: pair.signal.mult,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
