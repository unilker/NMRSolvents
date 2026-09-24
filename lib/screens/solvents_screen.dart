import 'package:flutter/material.dart';

import '../data/search.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'impurity_detail_screen.dart';

class SolventsScreen extends StatefulWidget {
  const SolventsScreen({super.key});

  @override
  State<SolventsScreen> createState() => _SolventsScreenState();
}

class _SolventsScreenState extends State<SolventsScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solvents = searchSolventsByName(
      context.repo.solvents,
      _query.text,
      context.lang,
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tabSolvents)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SearchField(
              controller: _query,
              hint: context.l10n.searchSolventsHint,
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: solvents.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    text: context.l10n.noResults,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: solvents.length,
                    itemBuilder: (context, i) => _SolventCard(solvents[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SolventCard extends StatelessWidget {
  const _SolventCard(this.solvent);

  final Solvent solvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SolventDetailScreen(solvent: solvent),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    prettyFormula(solvent.formula),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      solvent.name.of(context.lang),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              for (final nucleus in Nucleus.values)
                if (solvent.residualFor(nucleus).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(width: 42, child: NucleusBadge(nucleus)),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final p in solvent.residualFor(nucleus))
                                ShiftChip(
                                  nucleus: nucleus,
                                  shift: p.shift,
                                  mult: p.mult,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              if (solvent.waterShift != null)
                Text(
                  '${context.l10n.waterPeak}: '
                  '${formatShift(solvent.waterShift!)} ppm',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SolventDetailScreen extends StatelessWidget {
  const SolventDetailScreen({super.key, required this.solvent});

  final Solvent solvent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repo;
    final theme = Theme.of(context);
    final impurities = searchImpuritiesByName(
      repo.impuritiesIn(solvent.id),
      '',
      context.lang,
    );
    final reference = repo.referenceById(solvent.refId);

    return Scaffold(
      appBar: AppBar(title: Text(prettyFormula(solvent.formula))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  solvent.name.of(context.lang),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!solvent.verified) ...[
                  const SizedBox(height: 6),
                  const UnverifiedBadge(),
                ],
              ],
            ),
          ),
          SectionHeader(l10n.residualPeaks),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final p in solvent.residual)
                  ListTile(
                    dense: true,
                    leading: NucleusBadge(p.nucleus),
                    title: Text(
                      '${formatShift(p.shift)} ppm',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: nucleusColor(context, p.nucleus),
                      ),
                    ),
                    trailing: Text(
                      p.mult,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                if (solvent.waterShift != null)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.water_drop_outlined),
                    title: Text(l10n.waterPeak),
                    trailing: Text(
                      '${formatShift(solvent.waterShift!)} ppm',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                if (solvent.meltingPoint != null)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.ac_unit),
                    title: Text(l10n.meltingPoint),
                    trailing: Text('${_fmt(solvent.meltingPoint!)} °C'),
                  ),
                if (solvent.boilingPoint != null)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.local_fire_department_outlined),
                    title: Text(l10n.boilingPoint),
                    trailing: Text('${_fmt(solvent.boilingPoint!)} °C'),
                  ),
              ],
            ),
          ),
          if (impurities.isNotEmpty) ...[
            SectionHeader('${l10n.impuritiesInSolvent} (${impurities.length})'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final imp in impurities)
                    _ImpurityInSolventTile(impurity: imp, solvent: solvent),
                ],
              ),
            ),
          ],
          if (reference != null) ...[
            SectionHeader(l10n.reference),
            ReferenceCard(reference),
          ],
        ],
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class _ImpurityInSolventTile extends StatelessWidget {
  const _ImpurityInSolventTile({required this.impurity, required this.solvent});

  final Impurity impurity;
  final Solvent solvent;

  @override
  Widget build(BuildContext context) {
    final h1 = impurity.signalsIn(solvent.id, Nucleus.h1);
    return ListTile(
      title: Text(impurity.name.of(context.lang)),
      subtitle: h1.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final s in h1)
                    ShiftChip(
                      nucleus: Nucleus.h1,
                      shift: s.shift,
                      mult: s.mult,
                    ),
                ],
              ),
            ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImpurityDetailScreen(
            impurity: impurity,
            initialSolventId: solvent.id,
          ),
        ),
      ),
    );
  }
}
