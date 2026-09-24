import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nmr_solvents/data/repository.dart';
import 'package:nmr_solvents/data/search.dart';
import 'package:nmr_solvents/models/models.dart';
import 'package:nmr_solvents/widgets/common.dart';

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

  Impurity imp(String id) => repo.impurities.firstWhere((i) => i.id == id);

  /// Signals of [id] in [solvent] for [nucleus] with the given assignment.
  List<Signal> sig(String id, String solvent, Nucleus nucleus, [String? a]) =>
      imp(id)
          .signalsIn(solvent, nucleus)
          .where((s) => a == null || s.assignment == a)
          .toList();

  group('data files', () {
    test('every signal refers to a known solvent and reference', () {
      final ids = repo.solvents.map((s) => s.id).toSet();
      for (final i in repo.impurities) {
        for (final s in i.signals) {
          expect(ids, contains(s.solventId), reason: i.id);
          expect(repo.referenceById(s.refId), isNotNull, reason: i.id);
        }
      }
      for (final s in repo.solvents) {
        for (final p in s.residual) {
          expect(repo.referenceById(p.refId), isNotNull, reason: s.id);
        }
      }
    });

    test('ids are unique and names exist in Turkish and English', () {
      final ids = repo.impurities.map((i) => i.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final n in [
        ...repo.impurities.map((i) => i.name),
        ...repo.solvents.map((s) => s.name),
      ]) {
        expect(n.values.keys, containsAll(['tr', 'en']));
      }
    });

    test('ranges are ordered low to high', () {
      for (final i in repo.impurities) {
        for (final s in i.signals) {
          if (s.shiftMax != null) {
            expect(s.shiftMax, greaterThan(s.shift), reason: i.id);
          }
        }
      }
    });
  });

  // Values checked against the printed tables.
  group('transcribed values', () {
    test('Fulmer 2010', () {
      expect(sig('water', 'thf_d8', Nucleus.h1, 'OH').single.shift, 2.46);
      expect(sig('pyrrole', 'dmso_d6', Nucleus.h1, 'NH').single.shift, 10.75);
      expect(sig('methane', 'tfe_d3', Nucleus.c13).single.shift, -5.88);
      // Printed transposed in Table 2; stored with CO/CH3 swapped back.
      expect(sig('acetone', 'tfe_d3', Nucleus.c13, 'CO').single.shift, 214.98);
      final grease = sig('grease', 'cdcl3', Nucleus.h1, 'CH3').single;
      expect([grease.shift, grease.shiftMax], [0.84, 0.87]);
    });

    test('Gottlieb 1997 fills compounds missing from Fulmer', () {
      final mtbe = sig('mtbe', 'cdcl3', Nucleus.h1, 'OCH3').single;
      expect(mtbe.shift, 3.22);
      expect(mtbe.refId, 'gottlieb1997');
      expect(sig('bht', 'cdcl3', Nucleus.h1, 'ArH').single.shift, 6.98);
      expect(
        sig('sodium_acetate', 'd2o', Nucleus.c13, 'CO').single.shift,
        182.02,
      );
    });

    test('Babij 2016', () {
      expect(sig('cpme', 'cdcl3', Nucleus.h1, 'OCH3').single.shift, 3.28);
      expect(sig('tame', 'd2o', Nucleus.c13, 'C').single.shift, 77.73);
      expect(imp('cpme').chem21, Chem21.problematic);
      expect(imp('ethanol').chem21, Chem21.recommended);
      // "3.56 [3.55, t]": the bracket is the -OD isotopomer (footnote c).
      final ch2oh = sig('isoamyl_alcohol', 'acetone_d6', Nucleus.h1, 'CH2OH');
      expect(ch2oh.single.shift, 3.56);
      expect(ch2oh.single.note, contains('3.55'));
    });

    test('CIL chart', () {
      final cdcl3 = repo.solventById('cdcl3')!;
      final cil = cdcl3.residual.where((p) => p.refId == 'cil').toList();
      expect(cil.map((p) => p.shift), [7.24, 77.23]);
      expect(cil.last.coupling, 32.0);
      expect(cdcl3.storage, 'fridge_6m');
      expect(repo.solventById('dmso_d6')!.density, 1.19);
    });

    test('precedence: Fulmer > Gottlieb > Babij per solvent', () {
      // Fulmer has ethanol in CDCl3; Babij's re-measured values are unused.
      expect(sig('ethanol', 'cdcl3', Nucleus.h1).map((s) => s.refId).toSet(), {
        'fulmer2010',
      });
      // Fulmer has no toluene in D2O, so Babij fills it.
      expect(sig('toluene', 'd2o', Nucleus.h1).map((s) => s.refId).toSet(), {
        'babij2016',
      });
    });

    test('residual peaks prefer Fulmer over the CIL chart', () {
      final cdcl3 = repo.solventById('cdcl3')!;
      expect(cdcl3.residualFor(Nucleus.h1).single.shift, 7.26);
      // No Fulmer data for DMF-d7: CIL values are used.
      final dmf = repo.solventById('dmf_d7')!;
      expect(dmf.residualFor(Nucleus.h1).map((p) => p.shift), [
        8.03,
        2.92,
        2.75,
      ]);
    });
  });

  group('normalizeForSearch', () {
    test('ignores case and Turkish characters', () {
      expect(normalizeForSearch('DİKLOROMETAN'), 'diklorometan');
      expect(normalizeForSearch('Dimetil sülfoksit'), 'dimetilsulfoksit');
    });
  });

  group('searchImpuritiesByName', () {
    String first(String q) =>
        searchImpuritiesByName(repo.impurities, q, 'tr').first.id;

    test('finds by Turkish name, English name, alias and formula', () {
      expect(first('etil asetat'), 'ethyl_acetate');
      expect(first('ethyl acetate'), 'ethyl_acetate');
      expect(first('EtOAc'), 'ethyl_acetate');
      expect(first('DCM'), 'dichloromethane');
      expect(first('CH2Cl2'), 'dichloromethane');
      expect(first('2-MeTHF'), 'me_thf');
      expect(first('ksilen'), anyOf('o_xylene', 'm_xylene', 'p_xylene'));
    });
  });

  group('parseShifts', () {
    test('accepts dot and Turkish comma decimals', () {
      expect(parseShifts('2.05, 4.12, 1.26'), [2.05, 4.12, 1.26]);
      expect(parseShifts('2,05 4,12 1,26'), [2.05, 4.12, 1.26]);
      expect(parseShifts('2.05;4.12'), [2.05, 4.12]);
      expect(parseShifts('2.05,4.12'), [2.05, 4.12]);
      expect(parseShifts('abc'), isEmpty);
    });
  });

  group('findPeaksNear', () {
    List<PeakHit> near(String solvent, double ppm, double tol, [String? m]) =>
        findPeaksNear(
          impurities: repo.impurities,
          solvent: repo.solventById(solvent)!,
          nucleus: Nucleus.h1,
          ppm: ppm,
          tolerance: tol,
          multiplicity: m,
        );

    test('7.26 in CDCl3 is the residual solvent peak', () {
      expect(
        near('cdcl3', 7.26, 0.005).first.source,
        HitSource.residualSolvent,
      );
    });

    test('5.30 in CDCl3 is dichloromethane', () {
      final hit = near('cdcl3', 5.30, 0.005).single;
      expect(hit.impurity!.id, 'dichloromethane');
    });

    test('a shift inside a reported range matches with delta 0', () {
      final hit = near(
        'd2o',
        7.35,
        0.01,
      ).firstWhere((h) => h.impurity?.id == 'toluene');
      expect(hit.delta, 0);
    });

    test('multiplicity filter narrows results', () {
      final all = near('cdcl3', 1.25, 0.05);
      final triplets = near('cdcl3', 1.25, 0.05, 't');
      expect(triplets.length, lessThan(all.length));
      // Only triplets, patterns containing a triplet, multiplets, or
      // signals without a reported multiplicity remain.
      for (final h in triplets) {
        expect(matchMultiplicity('t', h.mult), isNotNull, reason: h.mult);
      }
    });
  });

  group('matchMultiplicity', () {
    test('exact, compatible, unknown and impossible patterns', () {
      expect(matchMultiplicity('t', 't'), MultMatch.exact);
      expect(matchMultiplicity('t', 'br t'), MultMatch.exact);
      expect(matchMultiplicity('br s', 's'), MultMatch.exact);
      expect(matchMultiplicity('quint', 'p'), MultMatch.exact);
      expect(matchMultiplicity('t', 'td'), MultMatch.compatible);
      expect(matchMultiplicity('d', 'dp'), MultMatch.compatible);
      expect(matchMultiplicity('t', 'm'), MultMatch.compatible);
      expect(matchMultiplicity('m', 'q'), MultMatch.compatible);
      expect(matchMultiplicity('t', null), MultMatch.unknown);
      expect(matchMultiplicity('s', 'm'), isNull);
      expect(matchMultiplicity('t', 'q'), isNull);
      expect(matchMultiplicity('dd', 'd'), isNull);
    });
  });

  group('solvent + shift + splitting search', () {
    List<PeakHit> search(
      String solvent,
      double ppm,
      String? mult, [
      double tol = 0.05,
    ]) => findPeaksNear(
      impurities: repo.impurities,
      solvent: repo.solventById(solvent)!,
      nucleus: Nucleus.h1,
      ppm: ppm,
      tolerance: tol,
      multiplicity: mult,
    );

    test('4.3 ppm triplet in DMSO-d6: alcohol OH triplets first', () {
      final hits = search('dmso_d6', 4.30, 't');
      expect(hits.take(2).map((h) => h.impurity!.id).toSet(), {
        'isoamyl_alcohol',
        'n_butanol',
      });
      expect(hits.first.multMatch, MultMatch.exact);
    });

    test('4.3 ppm triplet in CDCl3: singlets are excluded, multiplet kept', () {
      final hits = search('cdcl3', 4.30, 't');
      final ids = hits.map((h) => h.impurity?.id).toSet();
      expect(ids, contains('ethyl_lactate'));
      expect(ids, isNot(contains('nitromethane'))); // 4.33 s
      expect(ids, isNot(contains('glycol_diacetate'))); // 4.27 s
      expect(
        hits.firstWhere((h) => h.impurity?.id == 'ethyl_lactate').multMatch,
        MultMatch.compatible,
      );
    });

    test('exact matches are listed before compatible ones', () {
      final hits = search('cdcl3', 1.25, 't', 0.1);
      final ranks = hits.map((h) => h.multMatch!.index).toList();
      expect(ranks, orderedEquals([...ranks]..sort()));
    });

    test('residual solvent peaks carry the CIL multiplicity', () {
      final hit = search('dmso_d6', 2.50, 'quint', 0.01).first;
      expect(hit.source, HitSource.residualSolvent);
      expect(hit.multMatch, MultMatch.exact);
    });

    test('nearest peaks are offered when nothing is within tolerance', () {
      expect(search('cdcl3', 4.45, 't', 0.005), isEmpty);
      final nearest = nearestPeaks(
        impurities: repo.impurities,
        solvent: repo.solventById('cdcl3')!,
        nucleus: Nucleus.h1,
        ppm: 4.45,
        maxDistance: 0.9,
        multiplicity: 't',
      );
      expect(nearest, isNotEmpty);
      expect(nearest.length, lessThanOrEqualTo(5));
    });
  });

  group('matchMultiplePeaks', () {
    test('ethyl acetate peaks rank ethyl acetate first', () {
      final matches = matchMultiplePeaks(
        impurities: repo.impurities,
        solventId: 'cdcl3',
        nucleus: Nucleus.h1,
        observed: [2.05, 4.12, 1.26],
        tolerance: 0.02,
      );
      expect(matches.first.impurity.id, 'ethyl_acetate');
      expect(matches.first.score, closeTo(1, 1e-9));
    });
  });

  test('HDO shift in D2O follows Gottlieb eq 1', () {
    expect(hdoShiftInD2O(0), 5.060);
    expect(hdoShiftInD2O(25), closeTo(4.768, 0.001));
  });

  test('prettyFormula subscripts counts but not positions', () {
    expect(prettyFormula('CDCl3'), 'CDCl₃');
    expect(prettyFormula('(CH3)2CO'), '(CH₃)₂CO');
    expect(prettyFormula('C6H12'), 'C₆H₁₂');
    expect(prettyFormula('CH(2,4,6)'), 'CH(2,4,6)');
    expect(prettyFormula('CH2(3,5)'), 'CH₂(3,5)');
  });
}
