import 'package:flutter/material.dart';

import '../data/search.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'impurity_detail_screen.dart';

class ImpuritiesScreen extends StatefulWidget {
  const ImpuritiesScreen({super.key});

  @override
  State<ImpuritiesScreen> createState() => _ImpuritiesScreenState();
}

class _ImpuritiesScreenState extends State<ImpuritiesScreen> {
  final _query = TextEditingController();
  String? _solventId;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.repo;
    final pool = _solventId == null
        ? repo.impurities
        : repo.impuritiesIn(_solventId!);
    final results = searchImpuritiesByName(pool, _query.text, context.lang);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tabImpurities)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchField(
              controller: _query,
              hint: context.l10n.searchImpuritiesHint,
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SolventDropdown(
              value: _solventId,
              allowAll: true,
              onChanged: (id) => setState(() => _solventId = id),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.impurityCount(results.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    text: context.l10n.noResults,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) =>
                        _ImpurityTile(results[i], solventId: _solventId),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ImpurityTile extends StatelessWidget {
  const _ImpurityTile(this.impurity, {this.solventId});

  final Impurity impurity;
  final String? solventId;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (impurity.formula.isNotEmpty) prettyFormula(impurity.formula),
      ...impurity.aliases,
    ].join(' · ');
    final h1 = solventId == null
        ? const <Signal>[]
        : impurity.signalsIn(solventId!, Nucleus.h1);

    return ListTile(
      title: Text(
        impurity.name.of(context.lang),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle.isNotEmpty) Text(subtitle),
          if (h1.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final s in h1)
                  ShiftChip(nucleus: Nucleus.h1, shift: s.shift, mult: s.mult),
              ],
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImpurityDetailScreen(
            impurity: impurity,
            initialSolventId: solventId,
          ),
        ),
      ),
    );
  }
}
