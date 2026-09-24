import 'package:flutter/material.dart';

import '../data/search.dart';
import '../models/models.dart';
import '../widgets/chem21_widgets.dart';
import '../widgets/common.dart';
import 'impurity_detail_screen.dart';
import 'solvents_screen.dart';

/// The CHEM21 guide as a searchable list grouped by solvent family, with a
/// filter per ranking. Shown inside the Solvents tab.
class Chem21GuideView extends StatefulWidget {
  const Chem21GuideView({super.key});

  @override
  State<Chem21GuideView> createState() => _Chem21GuideViewState();
}

class _Chem21GuideViewState extends State<Chem21GuideView> {
  final _query = TextEditingController();
  Chem21? _rank;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = context.lang;
    final q = normalizeForSearch(_query.text);
    final entries = context.repo.chem21.where((e) {
      if (_rank != null && e.rank != _rank) return false;
      if (q.isEmpty) return true;
      return [
        ...e.name.all,
        e.printed,
        ?e.cas,
      ].any((t) => normalizeForSearch(t).contains(q));
    }).toList();

    // Group by family in order of first appearance (Table 7, then Table 8).
    final families = <String, List<Chem21Entry>>{};
    for (final e in entries) {
      families.putIfAbsent(e.family.of(lang), () => []).add(e);
    }

    return ListView(
      padding: pageBottomPadding(context, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            l10n.chem21Intro,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const Chem21ScoringScreen()),
              ),
              icon: const Icon(Icons.help_outline, size: 18),
              label: Text(l10n.howScored),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchField(
            controller: _query,
            hint: l10n.searchChem21Hint,
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: Text(l10n.anyMultiplicity),
                selected: _rank == null,
                onSelected: (_) => setState(() => _rank = null),
              ),
              for (final r in Chem21.values)
                ChoiceChip(
                  key: Key('rank-${r.code}'),
                  avatar: Icon(chem21Icon(r), size: 16, color: chem21Color(r)),
                  label: Text(chem21Label(l10n, r)),
                  selected: _rank == r,
                  onSelected: (_) => setState(() => _rank = r),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(
            l10n.chem21Count(entries.length),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (entries.isEmpty)
          EmptyState(icon: Icons.search_off, text: l10n.noResults),
        for (final MapEntry(key: family, value: list) in families.entries) ...[
          SectionHeader(family),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final e in list)
                  ListTile(
                    title: Text(
                      e.name.of(lang),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chem21MiniScores(e),
                      ),
                    ),
                    trailing: Chem21RankBadge(e.rank),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Chem21DetailScreen(entry: e),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            l10n.chem21BabijNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class Chem21DetailScreen extends StatelessWidget {
  const Chem21DetailScreen({super.key, required this.entry});

  final Chem21Entry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repo;
    final theme = Theme.of(context);
    final impurities = [
      for (final id in entry.impurityIds)
        ...repo.impurities.where((i) => i.id == id),
    ];
    final deuterated = repo.solvents
        .where((s) => s.chem21Id == entry.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(entry.name.of(context.lang))),
      body: ListView(
        padding: pageBottomPadding(context, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name.of(context.lang),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${l10n.family}: ${entry.family.of(context.lang)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Chem21Card(entry, subtitle: l10n.greenChemistry),
          if (impurities.isNotEmpty) ...[
            SectionHeader(l10n.showNmrData),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final imp in impurities)
                    ListTile(
                      leading: const Icon(Icons.list_alt_outlined),
                      title: Text(imp.name.of(context.lang)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ImpurityDetailScreen(impurity: imp),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (deuterated.isNotEmpty) ...[
            SectionHeader(l10n.deuteratedForms),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final s in deuterated)
                    ListTile(
                      leading: const Icon(Icons.science_outlined),
                      title: Text(prettyFormula(s.formula)),
                      subtitle: Text(s.name.of(context.lang)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SolventDetailScreen(solvent: s),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// How the CHEM21 scores and rankings are obtained (Prat 2016, Tables 2,
/// 4, 5 and 6, and the class definitions of the introduction).
class Chem21ScoringScreen extends StatelessWidget {
  const Chem21ScoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget paragraph(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: theme.textTheme.bodyMedium),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.howScored)),
      body: ListView(
        padding: pageBottomPadding(context, 24),
        children: [
          SectionHeader(l10n.rankClasses),
          for (final r in Chem21.values)
            ListTile(
              leading: Icon(chem21Icon(r), color: chem21Color(r)),
              title: Text(
                chem21Label(l10n, r),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: chem21Color(r),
                ),
              ),
              subtitle: Text(chem21Definition(l10n, r)),
            ),
          SectionHeader(l10n.safetyScore),
          paragraph(l10n.safetyRule),
          SectionHeader(l10n.healthScore),
          paragraph(l10n.healthRule),
          SectionHeader(l10n.envScore),
          paragraph(l10n.envRule),
          SectionHeader(l10n.rankingDefault),
          paragraph(l10n.rankRule),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final s in [2, 5, 8])
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scoreColor(s).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$s',
                      style: TextStyle(
                        color: scoreColor(s),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                Text(l10n.scoreColors, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          SectionHeader(l10n.reference),
          if (context.repo.referenceById('prat2016') case final ref?)
            ReferenceCard(ref),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(l10n.hStatementNote, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
