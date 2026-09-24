import 'package:flutter/material.dart';

import '../data/search.dart';
import '../models/models.dart';
import '../widgets/chem21_widgets.dart';
import '../widgets/common.dart';
import 'chem21_screen.dart';
import 'impurity_detail_screen.dart';

class SolventsScreen extends StatefulWidget {
  const SolventsScreen({super.key});

  @override
  State<SolventsScreen> createState() => _SolventsScreenState();
}

class _SolventsScreenState extends State<SolventsScreen> {
  final _query = TextEditingController();
  bool _guide = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final toggle = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SegmentedButton<bool>(
        segments: [
          ButtonSegment(
            value: false,
            icon: const Icon(Icons.science_outlined),
            label: Text(l10n.nmrSolventsView),
          ),
          ButtonSegment(
            value: true,
            icon: const Icon(Icons.eco_outlined),
            label: Text(l10n.chem21GuideView),
          ),
        ],
        selected: {_guide},
        onSelectionChanged: (v) => setState(() => _guide = v.first),
      ),
    );
    if (_guide) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tabSolvents)),
        body: Column(
          children: [
            toggle,
            const Expanded(child: Chem21GuideView()),
          ],
        ),
      );
    }
    final solvents = searchSolventsByName(
      context.repo.solvents,
      _query.text,
      context.lang,
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tabSolvents)),
      body: Column(
        children: [
          toggle,
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
                    padding: pageBottomPadding(context, 16),
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
                                  value: p,
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
    final refIds = {
      ...solvent.residualRefs,
      ?solvent.waterRefId,
      if (solvent.density != null || solvent.storage != null) 'cil',
      if (solvent.chem21Id != null) 'prat2016',
    };

    return Scaffold(
      appBar: AppBar(title: Text(prettyFormula(solvent.formula))),
      body: ListView(
        padding: pageBottomPadding(context, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              solvent.name.of(context.lang),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SectionHeader(l10n.residualPeaks),
          for (final ref in solvent.residualRefs)
            _ResidualCard(solvent: solvent, refId: ref),
          if (solvent.waterShift != null || solvent.hodCil != null)
            Card(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  if (solvent.waterShift != null)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.water_drop_outlined),
                      title: Text(l10n.waterPeak),
                      subtitle: solvent.waterRefId == null
                          ? null
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: SourceTag(solvent.waterRefId!),
                            ),
                      trailing: Text(
                        '${formatShift(solvent.waterShift!)} ppm',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (solvent.hodCil != null && solvent.waterRefId != 'cil')
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.water_drop_outlined),
                      title: Text(l10n.hodOnChart),
                      trailing: Text('${solvent.hodCil} ppm'),
                    ),
                ],
              ),
            ),
          if (solvent.id == 'd2o') const _HdoTemperatureCard(),
          if (solvent.note != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                '${l10n.note}: ${solvent.note}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          if (solvent.density != null || solvent.meltingPoint != null) ...[
            SectionHeader(l10n.properties),
            _PropertiesCard(solvent),
          ],
          if (solvent.storage != null) ...[
            SectionHeader(l10n.storage),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: Icon(
                  solvent.storage == 'fridge_6m'
                      ? Icons.kitchen_outlined
                      : Icons.inventory_2_outlined,
                ),
                title: Text(switch (solvent.storage) {
                  'fridge_6m' => l10n.storageFridge6m,
                  'rt_1y' => l10n.storageRt1y,
                  _ => l10n.storageRt,
                }),
              ),
            ),
          ],
          if (repo.chem21ById(solvent.chem21Id) case final chem21?) ...[
            SectionHeader(l10n.greenChemistry),
            Chem21Card(
              chem21,
              subtitle: l10n.chem21For(chem21.name.of(context.lang)),
            ),
          ],
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
          SectionHeader(l10n.sources),
          for (final id in refIds)
            if (repo.referenceById(id) case final ref?) ReferenceCard(ref),
        ],
      ),
    );
  }
}

/// Residual peaks of one source (e.g. Fulmer 2010 or the CIL chart).
class _ResidualCard extends StatelessWidget {
  const _ResidualCard({required this.solvent, required this.refId});

  final Solvent solvent;
  final String refId;

  @override
  Widget build(BuildContext context) {
    final peaks = solvent.residual.where((p) => p.refId == refId).toList();
    final ref = context.repo.referenceById(refId);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                context.l10n.residualFrom(ref?.short ?? refId),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            for (final p in peaks)
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
                  [
                    ?p.mult,
                    if (p.coupling != null) 'J = ${_trim(p.coupling!)} Hz',
                  ].join('  ·  '),
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _trim(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

class _PropertiesCard extends StatelessWidget {
  const _PropertiesCard(this.solvent);

  final Solvent solvent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget row(IconData icon, String label, String value) => ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value),
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (solvent.density != null)
            row(
              Icons.scale_outlined,
              l10n.density,
              '${solvent.density!.toStringAsFixed(2)} g/mL',
            ),
          if (solvent.meltingPoint != null)
            row(Icons.ac_unit, l10n.meltingPoint, '${solvent.meltingPoint} °C'),
          if (solvent.boilingPoint != null)
            row(
              Icons.local_fire_department_outlined,
              l10n.boilingPoint,
              '${solvent.boilingPoint} °C',
            ),
          if (solvent.dielectric != null)
            row(
              Icons.bolt_outlined,
              l10n.dielectric,
              _trim(solvent.dielectric!),
            ),
          if (solvent.molecularWeight != null)
            row(
              Icons.science_outlined,
              l10n.molecularWeight,
              '${solvent.molecularWeight!.toStringAsFixed(2)} g/mol',
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              l10n.mpBpNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Temperature slider for the HDO shift in D₂O (Gottlieb 1997, eq 1).
class _HdoTemperatureCard extends StatefulWidget {
  const _HdoTemperatureCard();

  @override
  State<_HdoTemperatureCard> createState() => _HdoTemperatureCardState();
}

class _HdoTemperatureCardState extends State<_HdoTemperatureCard> {
  // The paper states the simpler linear fit holds for 0-50 °C; the slider
  // stays inside that range.
  double _celsius = 25;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shift = hdoShiftInD2O(_celsius);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.hodTemperature,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.hodAt(_celsius.round().toString(), shift.toStringAsFixed(2)),
              key: const Key('hodResult'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: nucleusColor(context, Nucleus.h1),
              ),
            ),
            Slider(
              value: _celsius,
              min: 0,
              max: 50,
              divisions: 50,
              label: '${_celsius.round()} °C',
              onChanged: (v) => setState(() => _celsius = v),
            ),
            Text(
              l10n.hodTemperatureNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
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
                    ShiftChip(nucleus: Nucleus.h1, value: s, mult: s.mult),
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
