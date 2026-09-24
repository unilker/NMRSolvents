import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';

/// Holds all reference data, loaded once from `assets/data/` at startup.
class NmrRepository {
  NmrRepository({
    required this.solvents,
    required this.impurities,
    required this.references,
    this.chem21 = const [],
  });

  final List<Solvent> solvents;
  final List<Impurity> impurities;
  final Map<String, Reference> references;

  /// CHEM21 solvent guide, in the order of the paper's tables.
  final List<Chem21Entry> chem21;

  late final Map<String, Chem21Entry> _chem21ById = {
    for (final e in chem21) e.id: e,
  };

  Chem21Entry? chem21ById(String? id) => id == null ? null : _chem21ById[id];

  static Future<NmrRepository> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    Future<List<Map<String, dynamic>>> read(String name) async =>
        (jsonDecode(await b.loadString('assets/data/$name.json')) as List)
            .cast<Map<String, dynamic>>();

    final (solvents, impurities, references, chem21) = await (
      read('solvents'),
      read('impurities'),
      read('references'),
      read('chem21'),
    ).wait;
    return NmrRepository.fromJson(
      solvents: solvents,
      impurities: impurities,
      references: references,
      chem21: chem21,
    );
  }

  factory NmrRepository.fromJson({
    required List<Map<String, dynamic>> solvents,
    required List<Map<String, dynamic>> impurities,
    required List<Map<String, dynamic>> references,
    List<Map<String, dynamic>> chem21 = const [],
  }) => NmrRepository(
    solvents: solvents.map(Solvent.fromJson).toList(),
    impurities: impurities.map(Impurity.fromJson).toList(),
    references: {for (final r in references.map(Reference.fromJson)) r.id: r},
    chem21: chem21.map(Chem21Entry.fromJson).toList(),
  );

  Solvent? solventById(String id) {
    for (final s in solvents) {
      if (s.id == id) return s;
    }
    return null;
  }

  Reference? referenceById(String? id) => id == null ? null : references[id];

  /// Solvents in which at least one impurity was measured, in list order.
  late final List<Solvent> solventsWithImpurityData = () {
    final ids = {for (final i in impurities) ...i.solventIds};
    return solvents.where((s) => ids.contains(s.id)).toList();
  }();

  /// Impurities that have at least one signal recorded in [solventId].
  List<Impurity> impuritiesIn(String solventId) => impurities
      .where((i) => i.signals.any((s) => s.solventId == solventId))
      .toList();
}
