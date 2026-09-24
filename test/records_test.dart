import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nmr_solvents/data/repository.dart';
import 'package:nmr_solvents/data/search.dart';
import 'package:nmr_solvents/models/models.dart';
import 'package:nmr_solvents/records/analysis_record.dart';
import 'package:nmr_solvents/records/records_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

NmrRepository loadRepo() {
  List<Map<String, dynamic>> read(String name) =>
      (jsonDecode(File('assets/data/$name.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
  return NmrRepository.fromJson(
    solvents: read('solvents'),
    impurities: read('impurities'),
    references: read('references'),
    chem21: read('chem21'),
  );
}

void main() {
  final repo = loadRepo();

  AnalysisRecord etoacRecord({String id = 'r1', DateTime? date}) {
    final peaks = parsePeakList('2.05 s, 4.12 q, 1.26 t');
    final matches = matchMultiplePeaks(
      impurities: repo.impurities,
      solventId: 'cdcl3',
      nucleus: Nucleus.h1,
      observed: peaks,
      tolerance: 0.02,
    );
    return AnalysisRecord(
      id: id,
      sampleName: 'Numune $id',
      analysisDate: date ?? DateTime(2026, 9, 20),
      createdAt: DateTime(2026, 9, 24, 10),
      solventId: 'cdcl3',
      nucleus: Nucleus.h1,
      mode: SearchMode.multiple,
      peaks: peaks,
      tolerance: 0.02,
      hits: hitsFromMultiMatch(matches),
      note: 'test',
    )..hits.first.identified = true;
  }

  test('a record survives a JSON round trip', () {
    final r = etoacRecord();
    final back = AnalysisRecord.fromJson(
      jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
    );
    expect(jsonEncode(back.toJson()), jsonEncode(r.toJson()));
    expect(back.peaks, r.peaks);
    expect(back.identified.single.impurityId, 'ethyl_acetate');
    final line = back.identified.single.lines.first;
    expect(line.match, MultMatch.exact);
    expect(line.refId, 'fulmer2010');
  });

  test('single-peak hits keep the residual solvent peak and its source', () {
    final hits = findPeaksNear(
      impurities: repo.impurities,
      solvent: repo.solventById('cdcl3')!,
      nucleus: Nucleus.h1,
      ppm: 7.26,
      tolerance: 0.01,
    );
    final saved = hitsFromPeakSearch(hits, 7.26, null);
    final residual = saved.firstWhere((h) => h.residual);
    expect(residual.lines.single.refId, 'fulmer2010');
    expect(residual.lines.single.observed, 7.26);
  });

  group('RecordsStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('persists, orders by analysis date and deletes', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = RecordsStore(prefs);
      await store.add(etoacRecord(id: 'old', date: DateTime(2026, 1, 5)));
      await store.add(etoacRecord(id: 'new', date: DateTime(2026, 9, 1)));

      final reloaded = RecordsStore(prefs);
      expect(reloaded.records.map((r) => r.id), ['new', 'old']);

      final r = reloaded.byId('old')!..sampleName = 'renamed';
      await reloaded.update(r);
      expect(RecordsStore(prefs).byId('old')!.sampleName, 'renamed');

      await reloaded.delete('new');
      expect(RecordsStore(prefs).records.map((r) => r.id), ['old']);
    });

    test('unreadable data is set aside and new records still save', () async {
      SharedPreferences.setMockInitialValues({'records.v1': '{not json'});
      final prefs = await SharedPreferences.getInstance();
      final store = RecordsStore(prefs);
      expect(store.records, isEmpty);
      expect(prefs.getString(RecordsStore.unreadableKey), '{not json');
      await store.add(etoacRecord());
      expect(RecordsStore(prefs).records.single.id, 'r1');
      expect(prefs.getString(RecordsStore.unreadableKey), '{not json');
    });
  });
}
