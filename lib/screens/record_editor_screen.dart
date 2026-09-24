import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../records/analysis_record.dart';
import '../widgets/common.dart';
import 'records_screen.dart';

/// Create or edit a record: sample name, analysis date, note, and which of
/// the found candidates were identified in the spectrum.
///
/// Pops with true when saved.
class RecordEditorScreen extends StatefulWidget {
  const RecordEditorScreen({
    super.key,
    required this.record,
    required this.isNew,
  });

  final AnalysisRecord record;
  final bool isNew;

  @override
  State<RecordEditorScreen> createState() => _RecordEditorScreenState();
}

class _RecordEditorScreenState extends State<RecordEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.record.sampleName);
  late final _note = TextEditingController(text: widget.record.note ?? '');
  late DateTime _date = widget.record.analysisDate;
  late final Set<int> _identified = {
    for (var i = 0; i < widget.record.hits.length; i++)
      if (widget.record.hits[i].identified) i,
  };

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final r = widget.record
      ..sampleName = _name.text.trim()
      ..analysisDate = DateTime(_date.year, _date.month, _date.day)
      ..note = _note.text.trim().isEmpty ? null : _note.text.trim();
    for (var i = 0; i < r.hits.length; i++) {
      r.hits[i].identified = _identified.contains(i);
    }
    final store = context.records;
    if (widget.isNew) {
      await store.add(r);
    } else {
      await store.update(r);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final record = widget.record;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? l10n.newRecord : l10n.editRecord),
        actions: [
          TextButton(
            key: const Key('saveRecord'),
            onPressed: _save,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: pageBottomPadding(context, 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextFormField(
                key: const Key('sampleName'),
                controller: _name,
                autofocus: widget.isNew,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.sampleName,
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.sampleNameRequired
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: InkWell(
                key: const Key('analysisDate'),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.analysisDate,
                    prefixIcon: const Icon(Icons.event_outlined),
                  ),
                  child: Text(DateFormat.yMMMMd(locale).format(_date)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                key: const Key('recordNote'),
                controller: _note,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.noteOptional,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
            ),
            SectionHeader(l10n.searchType),
            RecordSearchSummary(record),
            SectionHeader(l10n.identifiedSection),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.markIdentified,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (record.hits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l10n.noResults),
              ),
            for (var i = 0; i < record.hits.length; i++)
              CheckboxListTile(
                key: Key('identify-$i'),
                value: _identified.contains(i),
                onChanged: (v) => setState(
                  () => v == true ? _identified.add(i) : _identified.remove(i),
                ),
                title: Text(recordHitTitle(context, record, record.hits[i])),
                subtitle: Text(recordHitLines(context, record.hits[i])),
                controlAffinity: ListTileControlAffinity.leading,
              ),
          ],
        ),
      ),
    );
  }
}
