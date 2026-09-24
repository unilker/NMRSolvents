import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nmr_solvents/data/repository.dart';
import 'package:nmr_solvents/data/search.dart';
import 'package:nmr_solvents/models/models.dart';

NmrRepository loadRepo() {
  List<Map<String, dynamic>> read(String name) =>
      (jsonDecode(File('assets/data/$name.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
  return NmrRepository.fromJson(
    solvents: read('solvents'),
    impurities: read('impurities'),
    references: read('references'),
  );
}

void main() {
  final repo = loadRepo();

  group('data files', () {
    test('every signal refers to a known solvent', () {
      final ids = repo.solvents.map((s) => s.id).toSet();
      for (final i in repo.impurities) {
        for (final s in i.signals) {
          expect(ids, contains(s.solventId), reason: i.id);
        }
      }
    });

    test('every ref id resolves', () {
      for (final id in [
        ...repo.solvents.map((s) => s.refId),
        ...repo.impurities.map((i) => i.refId),
      ]) {
        expect(repo.referenceById(id), isNotNull, reason: '$id');
      }
    });

    test('ids are unique', () {
      final ids = repo.impurities.map((i) => i.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('names exist in Turkish and English', () {
      for (final i in [
        ...repo.impurities.map((i) => i.name),
        ...repo.solvents.map((s) => s.name),
      ]) {
        expect(i.values.keys, containsAll(['tr', 'en']));
      }
    });
  });

  group('normalizeForSearch', () {
    test('ignores case and Turkish characters', () {
      expect(normalizeForSearch('DİKLOROMETAN'), 'diklorometan');
      expect(normalizeForSearch('Dimetil sülfoksit'), 'dimetilsulfoksit');
      expect(normalizeForSearch('Etil Asetat'), 'etilasetat');
    });
  });

  group('searchImpuritiesByName', () {
    test('finds by Turkish name, English name, alias and formula', () {
      String first(String q) =>
          searchImpuritiesByName(repo.impurities, q, 'tr').first.id;
      expect(first('etil asetat'), 'ethyl_acetate');
      expect(first('ethyl acetate'), 'ethyl_acetate');
      expect(first('EtOAc'), 'ethyl_acetate');
      expect(first('DCM'), 'dichloromethane');
      expect(first('CH2Cl2'), 'dichloromethane');
      expect(first('sulfoksit'), 'dmso');
    });

    test('empty query returns everything', () {
      expect(
        searchImpuritiesByName(repo.impurities, '', 'en').length,
        repo.impurities.length,
      );
    });
  });

  group('parseShifts', () {
    test('accepts dot and Turkish comma decimals', () {
      expect(parseShifts('2.05, 4.12, 1.26'), [2.05, 4.12, 1.26]);
      expect(parseShifts('2,05 4,12 1,26'), [2.05, 4.12, 1.26]);
      expect(parseShifts('2.05;4.12'), [2.05, 4.12]);
      expect(parseShifts('2.05,4.12'), [2.05, 4.12]);
      expect(parseShifts('7,26'), [7.26]);
      expect(parseShifts('abc'), isEmpty);
    });
  });

  group('findPeaksNear', () {
    test('7.26 in CDCl3 is the residual solvent peak', () {
      final hits = findPeaksNear(
        impurities: repo.impurities,
        solvent: repo.solventById('cdcl3')!,
        nucleus: Nucleus.h1,
        ppm: 7.26,
        tolerance: 0.02,
      );
      expect(hits.first.source, HitSource.residualSolvent);
    });

    test('5.30 in CDCl3 is dichloromethane', () {
      final hits = findPeaksNear(
        impurities: repo.impurities,
        solvent: repo.solventById('cdcl3')!,
        nucleus: Nucleus.h1,
        ppm: 5.30,
        tolerance: 0.03,
      );
      expect(hits.first.impurity!.id, 'dichloromethane');
      expect(hits.first.delta, closeTo(0, 1e-9));
    });

    test('multiplicity filter narrows results', () {
      final all = findPeaksNear(
        impurities: repo.impurities,
        solvent: repo.solventById('cdcl3')!,
        nucleus: Nucleus.h1,
        ppm: 1.25,
        tolerance: 0.05,
      );
      final triplets = findPeaksNear(
        impurities: repo.impurities,
        solvent: repo.solventById('cdcl3')!,
        nucleus: Nucleus.h1,
        ppm: 1.25,
        tolerance: 0.05,
        multiplicity: 't',
      );
      expect(triplets.length, lessThan(all.length));
      expect(triplets.every((h) => h.mult == 't'), isTrue);
    });
  });

  group('matchMultiplePeaks', () {
    test('ethyl acetate peaks rank ethyl acetate first', () {
      final matches = matchMultiplePeaks(
        impurities: repo.impurities,
        solventId: 'cdcl3',
        nucleus: Nucleus.h1,
        observed: [2.05, 4.12, 1.26],
        tolerance: 0.03,
      );
      expect(matches.first.impurity.id, 'ethyl_acetate');
      expect(matches.first.matched.length, 3);
      expect(matches.first.score, closeTo(1, 1e-9));
    });

    test('one observed peak explains at most one signal', () {
      final matches = matchMultiplePeaks(
        impurities: repo.impurities,
        solventId: 'cdcl3',
        nucleus: Nucleus.h1,
        observed: [1.26],
        tolerance: 0.5,
      );
      for (final m in matches) {
        expect(m.matched.length, 1);
      }
    });
  });
}
