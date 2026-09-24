import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/search.dart';
import '../models/models.dart';
import '../records/analysis_record.dart';
import '../widgets/common.dart';
import 'impurity_detail_screen.dart';
import 'record_editor_screen.dart';

String _date(BuildContext context, DateTime d) =>
    DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(d);

String _solventLabel(BuildContext context, String id) {
  final s = context.repo.solventById(id);
  return s == null ? id : prettyFormula(s.formula);
}

/// "2.05 s; 4.12 q; 1.26 t".
String peaksText(List<ObservedPeak> peaks) =>
    peaks.map((p) => [formatShift(p.ppm), ?p.mult].join(' ')).join('; ');

String recordHitTitle(
  BuildContext context,
  AnalysisRecord record,
  RecordHit hit,
) => hit.residual
    ? '${context.l10n.residualSolventPeak} '
          '(${_solventLabel(context, record.solventId)})'
    : hit.name.of(context.lang);

/// "4.12 q → 4.12 q (7) CH₂CH₃ · Fulmer 2010", one line per signal.
String recordHitLines(BuildContext context, RecordHit hit) {
  final repo = context.repo;
  return hit.lines
      .map((l) {
        final observed = l.observed == null
            ? null
            : [formatShift(l.observed!), ?l.observedMult].join(' ');
        final known = [
          l.shiftMax == null
              ? formatShift(l.shift)
              : '${formatShift(l.shift)}–${formatShift(l.shiftMax!)}',
          ?l.mult,
        ].join(' ');
        return [
          observed == null ? known : '$observed → $known',
          if (l.assignment != null) prettyFormula(l.assignment!),
          if (l.refId != null) repo.referenceById(l.refId)?.short ?? l.refId!,
        ].join(' · ');
      })
      .join('\n');
}

/// Plain-text version of a record, for the clipboard.
String recordToText(BuildContext context, AnalysisRecord r) {
  final l10n = context.l10n;
  final solvent = context.repo.solventById(r.solventId);
  final digits = r.nucleus == Nucleus.h1 ? 2 : 1;
  String hitText(RecordHit h) =>
      '• ${recordHitTitle(context, r, h)}\n'
      '${recordHitLines(context, h).split('\n').map((l) => '  $l').join('\n')}';
  return [
    l10n.recordHeader,
    '${l10n.sampleName}: ${r.sampleName}',
    '${l10n.analysisDate}: ${_date(context, r.analysisDate)}',
    '${l10n.solvent}: ${prettyFormula(solvent?.formula ?? r.solventId)}'
        '${solvent == null ? '' : ' (${solvent.name.of(context.lang)})'} · '
        '${r.nucleus.label}',
    '${l10n.searchType}: '
        '${r.mode == SearchMode.single ? l10n.singlePeak : l10n.multiplePeaks}',
    '${l10n.enteredPeaks}: ${peaksText(r.peaks)} '
        '(${l10n.tolerance} ±${r.tolerance.toStringAsFixed(digits)} ppm)',
    if (r.note != null) '${l10n.note}: ${r.note}',
    '',
    '${l10n.identifiedSection}:',
    if (r.identified.isEmpty) l10n.noneIdentified,
    ...r.identified.map(hitText),
    if (r.hits.any((h) => !h.identified)) ...[
      '',
      '${l10n.otherCandidates}:',
      ...r.hits.where((h) => !h.identified).map(hitText),
    ],
  ].join('\n');
}

/// Solvent, nucleus, mode, entered peaks and tolerance of a record.
class RecordSearchSummary extends StatelessWidget {
  const RecordSearchSummary(this.record, {super.key});

  final AnalysisRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final solvent = context.repo.solventById(record.solventId);
    final digits = record.nucleus == Nucleus.h1 ? 2 : 1;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            row(
              l10n.solvent,
              [
                prettyFormula(solvent?.formula ?? record.solventId),
                if (solvent != null) solvent.name.of(context.lang),
              ].join(' · '),
            ),
            row(l10n.nucleus, record.nucleus.label),
            row(
              l10n.searchType,
              record.mode == SearchMode.single
                  ? l10n.singlePeak
                  : l10n.multiplePeaks,
            ),
            row(l10n.enteredPeaks, peaksText(record.peaks)),
            row(
              l10n.tolerance,
              '±${record.tolerance.toStringAsFixed(digits)} ppm',
            ),
          ],
        ),
      ),
    );
  }
}

/// The Records tab: saved analyses, newest first, searchable.
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = context.records;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabRecords)),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final q = normalizeForSearch(_query.text);
          final records = store.records
              .where(
                (r) =>
                    q.isEmpty ||
                    normalizeForSearch(r.sampleName).contains(q) ||
                    normalizeForSearch(r.note ?? '').contains(q),
              )
              .toList();
          return ListView(
            padding: pageBottomPadding(context, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SearchField(
                  controller: _query,
                  hint: l10n.searchRecordsHint,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (store.records.isEmpty)
                EmptyState(icon: Icons.bookmark_border, text: l10n.recordsEmpty)
              else if (records.isEmpty)
                EmptyState(icon: Icons.search_off, text: l10n.noResults),
              for (final r in records) _RecordTile(r),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  l10n.localOnlyNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile(this.record);

  final AnalysisRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final identified = record.identified;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          record.sampleName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                _date(context, record.analysisDate),
                _solventLabel(context, record.solventId),
                record.nucleus.label,
                l10n.peakCount(record.peaks.length),
              ].join(' · '),
            ),
            if (identified.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  identified
                      .map((h) => recordHitTitle(context, record, h))
                      .join(', '),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecordDetailScreen(recordId: record.id),
          ),
        ),
      ),
    );
  }
}

class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({super.key, required this.recordId});

  final String recordId;

  Future<void> _delete(BuildContext context, AnalysisRecord record) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.deleteConfirm(record.sampleName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirmDelete'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final store = context.records;
    Navigator.of(context).pop();
    await store.delete(record.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = context.records;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final record = store.byId(recordId);
        if (record == null) return const Scaffold();
        final theme = Theme.of(context);
        final others = record.hits.where((h) => !h.identified).toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(record.sampleName),
            actions: [
              IconButton(
                key: const Key('copyRecord'),
                tooltip: l10n.copyAsText,
                icon: const Icon(Icons.copy_all_outlined),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: recordToText(context, record)),
                  );
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(l10n.copied)));
                },
              ),
              IconButton(
                key: const Key('editRecord'),
                tooltip: l10n.edit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RecordEditorScreen(record: record, isNew: false),
                  ),
                ),
              ),
              IconButton(
                key: const Key('deleteRecord'),
                tooltip: l10n.deleteRecord,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, record),
              ),
            ],
          ),
          body: ListView(
            padding: pageBottomPadding(context, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.sampleName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${l10n.analysisDate}: '
                      '${_date(context, record.analysisDate)}',
                    ),
                    Text(
                      l10n.savedOn(_date(context, record.createdAt)),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (record.note != null) ...[
                      const SizedBox(height: 8),
                      Text(record.note!),
                    ],
                  ],
                ),
              ),
              SectionHeader(l10n.searchType),
              RecordSearchSummary(record),
              SectionHeader(
                '${l10n.identifiedSection} (${record.identified.length})',
              ),
              if (record.identified.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.noneIdentified,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              for (final h in record.identified)
                _HitCard(record: record, hit: h),
              if (others.isNotEmpty) ...[
                SectionHeader('${l10n.otherCandidates} (${others.length})'),
                for (final h in others) _HitCard(record: record, hit: h),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HitCard extends StatelessWidget {
  const _HitCard({required this.record, required this.hit});

  final AnalysisRecord record;
  final RecordHit hit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final impurity = hit.impurityId == null
        ? null
        : context.repo.impurities
              .where((i) => i.id == hit.impurityId)
              .firstOrNull;
    final extra = [
      if (hit.delta != null) l10n.deltaPpm(hit.delta!.toStringAsFixed(2)),
      if (hit.score != null && hit.totalSignals != null)
        l10n.matchedSignals(hit.lines.length, hit.totalSignals!),
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(
          hit.identified ? Icons.check_circle : Icons.radio_button_unchecked,
          color: hit.identified
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
        title: Text(
          recordHitTitle(context, record, hit),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            recordHitLines(context, hit),
            if (extra.isNotEmpty) extra,
          ].join('\n'),
        ),
        trailing: impurity == null ? null : const Icon(Icons.chevron_right),
        onTap: impurity == null
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ImpurityDetailScreen(
                    impurity: impurity,
                    initialSolventId: record.solventId,
                  ),
                ),
              ),
      ),
    );
  }
}

/// Opens the editor for a new record built from the current search and,
/// once saved, offers to show it.
Future<void> saveSearchAsRecord(
  BuildContext context,
  AnalysisRecord draft,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final saved = await navigator.push<bool>(
    MaterialPageRoute(
      builder: (_) => RecordEditorScreen(record: draft, isNew: true),
    ),
  );
  if (saved != true) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.recordSaved),
      action: SnackBarAction(
        label: l10n.view,
        onPressed: () => navigator.push(
          MaterialPageRoute(
            builder: (_) => RecordDetailScreen(recordId: draft.id),
          ),
        ),
      ),
    ),
  );
}
