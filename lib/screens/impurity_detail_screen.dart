import 'package:flutter/material.dart';

import '../models/models.dart';
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
  late String? _solventId;

  @override
  void initState() {
    super.initState();
    final available = widget.impurity.solventIds;
    _solventId = available.contains(widget.initialSolventId)
        ? widget.initialSolventId
        : (available.isEmpty ? null : available.first);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repo;
    final theme = Theme.of(context);
    final impurity = widget.impurity;
    final solvents = repo.solvents
        .where((s) => impurity.solventIds.contains(s.id))
        .toList();
    final solvent = _solventId == null ? null : repo.solventById(_solventId!);
    final reference = repo.referenceById(impurity.refId);

    return Scaffold(
      appBar: AppBar(title: Text(impurity.name.of(context.lang))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
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
                if (!impurity.verified) ...[
                  const SizedBox(height: 6),
                  const UnverifiedBadge(),
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
          if (solvent != null)
            for (final nucleus in Nucleus.values)
              _SignalTable(
                impurity: impurity,
                solvent: solvent,
                nucleus: nucleus,
              ),
          if (reference != null) ...[
            SectionHeader(l10n.reference),
            ReferenceCard(reference),
          ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                Text(
                  l10n.noDataForSolvent,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.4),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              formatShift(s.shift),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              s.mult,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(s.assignment ?? '–'),
                          ),
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
