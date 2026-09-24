import 'package:flutter/material.dart';

import '../models/models.dart';
import '../widgets/chem21_widgets.dart';
import '../widgets/common.dart';

class ImpurityDetailScreen extends StatefulWidget {
  const ImpurityDetailScreen({
    super.key,
    required this.impurity,
    this.initialSolventId,
  });

  final Impurity impurity;
  final String? initialSolventId;

  @override
  State<ImpurityDetailScreen> createState() => _ImpurityDetailScreenState();
}

class _ImpurityDetailScreenState extends State<ImpurityDetailScreen> {
  String? _solventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_solventId != null) return;
    final solvents = _solvents();
    final initial = widget.initialSolventId;
    _solventId = solvents.any((s) => s.id == initial)
        ? initial
        : (solvents.isEmpty ? null : solvents.first.id);
  }

  /// Solvents with data for this impurity, in the app's solvent order.
  List<Solvent> _solvents() => context.repo.solvents
      .where((s) => widget.impurity.solventIds.contains(s.id))
      .toList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repo;
    final theme = Theme.of(context);
    final impurity = widget.impurity;
    final solvents = _solvents();
    final solvent = _solventId == null ? null : repo.solventById(_solventId!);
    final allRefs = {for (final s in impurity.signals) s.refId};

    return Scaffold(
      appBar: AppBar(title: Text(impurity.name.of(context.lang))),
      body: ListView(
        padding: pageBottomPadding(context, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  impurity.name.of(context.lang),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (impurity.formula.isNotEmpty)
                  Text(
                    '${l10n.formula}: ${prettyFormula(impurity.formula)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                if (impurity.aliases.isNotEmpty)
                  Text(
                    '${l10n.aliases}: ${impurity.aliases.join(', ')}',
                    style: theme.textTheme.bodyMedium,
                  ),
                if (repo.chem21ById(impurity.chem21Id) case final c?) ...[
                  const SizedBox(height: 8),
                  Chem21RankBadge(c.rank),
                ],
              ],
            ),
          ),
          SectionHeader(l10n.solvent),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final s in solvents)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(prettyFormula(s.formula)),
                      selected: s.id == _solventId,
                      onSelected: (_) => setState(() => _solventId = s.id),
                    ),
                  ),
              ],
            ),
          ),
          if (solvent != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('${l10n.reference}:', style: theme.textTheme.bodySmall),
                  for (final ref in impurity.refsIn(solvent.id)) SourceTag(ref),
                ],
              ),
            ),
            for (final nucleus in Nucleus.values)
              _SignalTable(
                impurity: impurity,
                solvent: solvent,
                nucleus: nucleus,
              ),
          ],
          if (impurity.note != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                '${l10n.note}: ${impurity.note}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          if (repo.chem21ById(impurity.chem21Id) case final chem21?) ...[
            SectionHeader(l10n.greenChemistry),
            Chem21Card(chem21),
          ],
          SectionHeader(l10n.sources),
          for (final id in {
            ...allRefs,
            if (impurity.chem21Id != null) 'prat2016',
          })
            if (repo.referenceById(id) case final ref?) ReferenceCard(ref),
        ],
      ),
    );
  }
}

class _SignalTable extends StatelessWidget {
  const _SignalTable({
    required this.impurity,
    required this.solvent,
    required this.nucleus,
  });

  final Impurity impurity;
  final Solvent solvent;
  final Nucleus nucleus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signals = impurity.signalsIn(solvent.id, nucleus);
    final color = nucleusColor(context, nucleus);
    final small = Theme.of(context).textTheme.bodySmall;
    Widget cell(Widget child) =>
        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: child);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NucleusBadge(nucleus),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.signalsIn(prettyFormula(solvent.formula)),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (signals.isEmpty)
                Text(l10n.noDataForSolvent, style: small)
              else
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.4),
                    1: FlexColumnWidth(1.3),
                    2: FlexColumnWidth(1.3),
                  },
                  children: [
                    TableRow(
                      children: [l10n.shift, l10n.multiplicity, l10n.assignment]
                          .map(
                            (h) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                h,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    for (final s in signals)
                      TableRow(
                        children: [
                          cell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatShiftValue(s),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (s.note != null) Text(s.note!, style: small),
                              ],
                            ),
                          ),
                          cell(
                            Text(
                              s.multWithJ ?? '–',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          cell(Text(prettyFormula(s.assignment ?? '–'))),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
