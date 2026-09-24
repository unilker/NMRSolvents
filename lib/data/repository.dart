import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';

/// Holds all reference data, loaded once from `assets/data/` at startup.
class NmrRepository {
  NmrRepository({
    required this.solvents,
    required this.impurities,
    required this.references,
  });

  final List<Solvent> solvents;
  final List<Impurity> impurities;
  final Map<String, Reference> references;

  static Future<NmrRepository> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    Future<List<Map<String, dynamic>>> read(String name) async =>
        (jsonDecode(await b.loadString('assets/data/$name.json')) as List)
            .cast<Map<String, dynamic>>();

    final (solvents, impurities, references) = await (
      read('solvents'),
      read('impurities'),
      read('references'),
    ).wait;
    return NmrRepository.fromJson(
      solvents: solvents,
      impurities: impurities,
      references: references,
    );
  }

  factory NmrRepository.fromJson({
    required List<Map<String, dynamic>> solvents,
    required List<Map<String, dynamic>> impurities,
    required List<Map<String, dynamic>> references,
  }) => NmrRepository(
    solvents: solvents.map(Solvent.fromJson).toList(),
    impurities: impurities.map(Impurity.fromJson).toList(),
    references: {for (final r in references.map(Reference.fromJson)) r.id: r},
  );

  Solvent? solventById(String id) {
    for (final s in solvents) {
      if (s.id == id) return s;
    }
    return null;
  }

  Reference? referenceById(String? id) => id == null ? null : references[id];

  /// Impurities that have at least one signal recorded in [solventId].
  List<Impurity> impuritiesIn(String solventId) => impurities
      .where((i) => i.signals.any((s) => s.solventId == solventId))
      .toList();
}
