/// A saved peak-search result: which sample, when, what was entered and
/// what was found. Stored on the device only (see [RecordsStore]).
library;

import '../data/search.dart';
import '../models/models.dart';

enum SearchMode { single, multiple }

/// One signal line of a saved result: the peak the user entered (if any)
/// next to the known signal it matched.
class RecordLine {
  const RecordLine({
    required this.shift,
    this.shiftMax,
    this.mult,
    this.assignment,
    this.refId,
    this.observed,
    this.observedMult,
    this.match,
  });

  factory RecordLine.fromJson(Map<String, dynamic> j) => RecordLine(
    shift: (j['shift'] as num).toDouble(),
    shiftMax: (j['shiftMax'] as num?)?.toDouble(),
    mult: j['mult'] as String?,
    assignment: j['assignment'] as String?,
    refId: j['ref'] as String?,
    observed: (j['observed'] as num?)?.toDouble(),
    observedMult: j['observedMult'] as String?,
    match: switch (j['match'] as String?) {
      final String name => MultMatch.values.byName(name),
      null => null,
    },
  );

  final double shift;
  final double? shiftMax;

  /// Multiplicity with coupling as shown, e.g. "t (7)".
  final String? mult;
  final String? assignment;
  final String? refId;
  final double? observed;
  final String? observedMult;
  final MultMatch? match;

  Map<String, dynamic> toJson() => {
    'shift': shift,
    'shiftMax': ?shiftMax,
    'mult': ?mult,
    'assignment': ?assignment,
    'ref': ?refId,
    'observed': ?observed,
    'observedMult': ?observedMult,
    'match': ?match?.name,
  };
}

/// A candidate found by the search, as it was at the time of saving.
class RecordHit {
  RecordHit({
    required this.residual,
    required this.name,
    required this.lines,
    this.impurityId,
    this.delta,
    this.score,
    this.totalSignals,
    this.identified = false,
  });

  factory RecordHit.fromJson(Map<String, dynamic> j) => RecordHit(
    residual: j['residual'] as bool? ?? false,
    impurityId: j['impurity'] as String?,
    name: LocalizedText.fromJson(j['name'] as Map<String, dynamic>),
    lines: (j['lines'] as List)
        .map((e) => RecordLine.fromJson(e as Map<String, dynamic>))
        .toList(),
    delta: (j['delta'] as num?)?.toDouble(),
    score: (j['score'] as num?)?.toDouble(),
    totalSignals: j['total'] as int?,
    identified: j['identified'] as bool? ?? false,
  );

  /// True for the solvent's own residual peak.
  final bool residual;
  final String? impurityId;

  /// Name snapshot, so old records read the same after data updates.
  final LocalizedText name;
  final List<RecordLine> lines;

  /// Single-peak mode: distance from the entered shift (ppm).
  final double? delta;

  /// Multiple-peak mode: match score (0..1) and the impurity's signal count.
  final double? score;
  final int? totalSignals;

  /// Marked by the user as present in the spectrum.
  bool identified;

  Map<String, dynamic> toJson() => {
    'residual': residual,
    'impurity': ?impurityId,
    'name': name.values,
    'lines': lines.map((l) => l.toJson()).toList(),
    'delta': ?delta,
    'score': ?score,
    'total': ?totalSignals,
    'identified': identified,
  };
}

class AnalysisRecord {
  AnalysisRecord({
    required this.id,
    required this.sampleName,
    required this.analysisDate,
    required this.createdAt,
    required this.solventId,
    required this.nucleus,
    required this.mode,
    required this.peaks,
    required this.tolerance,
    required this.hits,
    this.note,
  });

  factory AnalysisRecord.fromJson(Map<String, dynamic> j) => AnalysisRecord(
    id: j['id'] as String,
    sampleName: j['sample'] as String,
    analysisDate: DateTime.parse(j['date'] as String),
    createdAt: DateTime.parse(j['created'] as String),
    solventId: j['solvent'] as String,
    nucleus: Nucleus.fromCode(j['nucleus'] as String),
    mode: SearchMode.values.byName(j['mode'] as String),
    peaks: [
      for (final p in j['peaks'] as List)
        (
          ppm: ((p as Map<String, dynamic>)['ppm'] as num).toDouble(),
          mult: p['mult'] as String?,
        ),
    ],
    tolerance: (j['tolerance'] as num).toDouble(),
    hits: (j['hits'] as List)
        .map((e) => RecordHit.fromJson(e as Map<String, dynamic>))
        .toList(),
    note: j['note'] as String?,
  );

  final String id;
  String sampleName;

  /// Date the spectrum was measured (day precision).
  DateTime analysisDate;
  final DateTime createdAt;
  final String solventId;
  final Nucleus nucleus;
  final SearchMode mode;

  /// What the user entered.
  final List<ObservedPeak> peaks;
  final double tolerance;
  final List<RecordHit> hits;
  String? note;

  List<RecordHit> get identified => hits.where((h) => h.identified).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'sample': sampleName,
    'date': _day(analysisDate),
    'created': createdAt.toIso8601String(),
    'solvent': solventId,
    'nucleus': nucleus.code,
    'mode': mode.name,
    'peaks': [
      for (final p in peaks) {'ppm': p.ppm, 'mult': ?p.mult},
    ],
    'tolerance': tolerance,
    'hits': hits.map((h) => h.toJson()).toList(),
    'note': ?note,
  };

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Snapshot of single-peak search hits for saving.
List<RecordHit> hitsFromPeakSearch(
  List<PeakHit> hits,
  double ppm,
  String? observedMult,
) => [
  for (final h in hits)
    RecordHit(
      residual: h.source == HitSource.residualSolvent,
      impurityId: h.impurity?.id,
      name:
          h.impurity?.name ??
          h.solvent?.name ??
          const LocalizedText({'en': '?'}),
      delta: h.delta,
      lines: [
        RecordLine(
          shift: h.value.shift,
          shiftMax: h.value.shiftMax,
          mult: h.signal?.multWithJ ?? h.mult,
          assignment: h.signal?.assignment,
          refId: switch (h.value) {
            final Signal s => s.refId,
            final ResidualPeak p => p.refId,
            _ => null,
          },
          observed: ppm,
          observedMult: observedMult,
          match: h.multMatch,
        ),
      ],
    ),
];

/// Snapshot of multiple-peak matches for saving.
List<RecordHit> hitsFromMultiMatch(List<MultiPeakMatch> matches) => [
  for (final m in matches)
    RecordHit(
      residual: false,
      impurityId: m.impurity.id,
      name: m.impurity.name,
      score: m.score,
      totalSignals: m.totalSignals,
      lines: [
        for (final p in m.matched)
          RecordLine(
            shift: p.signal.shift,
            shiftMax: p.signal.shiftMax,
            mult: p.signal.multWithJ,
            assignment: p.signal.assignment,
            refId: p.signal.refId,
            observed: p.observed.ppm,
            observedMult: p.observed.mult,
            match: p.multMatch,
          ),
      ],
    ),
];
