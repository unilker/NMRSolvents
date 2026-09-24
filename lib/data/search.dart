/// Pure-Dart search logic, kept free of Flutter so it can be unit tested.
library;

import 'dart:math' as math;

import '../models/models.dart';

/// Lowercases and strips Turkish diacritics and punctuation so that
/// "Diklorometan", "DİKLOROMETAN" and "diklorometan" compare equal.
String normalizeForSearch(String input) {
  const map = {
    'İ': 'i', 'I': 'i', 'ı': 'i', 'Ş': 's', 'ş': 's', 'Ğ': 'g', 'ğ': 'g', //
    'Ü': 'u', 'ü': 'u', 'Ö': 'o', 'ö': 'o', 'Ç': 'c', 'ç': 'c',
    'Â': 'a', 'â': 'a', 'Î': 'i', 'î': 'i', 'Û': 'u', 'û': 'u',
  };
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(map[ch] ?? ch.toLowerCase());
  }
  return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

/// Terms an impurity can be found by: names in every language, aliases and
/// formula.
Iterable<String> _searchTerms(Impurity i) => [
  ...i.name.all,
  ...i.aliases,
  i.formula,
];

/// Returns impurities whose name, alias or formula matches [query], best
/// matches (prefix hits) first. An empty query returns everything.
List<Impurity> searchImpuritiesByName(
  List<Impurity> impurities,
  String query,
  String languageCode,
) {
  final q = normalizeForSearch(query);
  int rank(Impurity i) {
    var best = 3;
    for (final term in _searchTerms(i)) {
      final t = normalizeForSearch(term);
      if (t.isEmpty) continue;
      if (t == q) return 0;
      if (t.startsWith(q)) best = math.min(best, 1);
      if (t.contains(q)) best = math.min(best, 2);
    }
    return best;
  }

  final ranked =
      [
        for (final i in impurities)
          if (q.isEmpty || rank(i) < 3)
            (impurity: i, rank: q.isEmpty ? 0 : rank(i)),
      ]..sort((a, b) {
        final r = a.rank.compareTo(b.rank);
        if (r != 0) return r;
        return a.impurity.name
            .of(languageCode)
            .toLowerCase()
            .compareTo(b.impurity.name.of(languageCode).toLowerCase());
      });
  return ranked.map((e) => e.impurity).toList();
}

List<Solvent> searchSolventsByName(
  List<Solvent> solvents,
  String query,
  String languageCode,
) {
  final q = normalizeForSearch(query);
  if (q.isEmpty) return solvents;
  return solvents
      .where(
        (s) => [
          ...s.name.all,
          s.formula,
        ].any((t) => normalizeForSearch(t).contains(q)),
      )
      .toList();
}

/// Parses a list of chemical shifts typed by the user.
///
/// Accepts spaces, semicolons or ", " as separators and both "." and the
/// Turkish decimal comma: "2.05, 4.12", "2,05 4,12" and "2.05;4.12" all work.
List<double> parseShifts(String input) {
  final tokens = input
      .split(RegExp(r'[;\s]+|,\s+'))
      .where((t) => t.isNotEmpty)
      .expand((t) {
        final commas = ','.allMatches(t).length;
        if (commas == 0) return [t];
        if (t.contains('.') || commas > 1) return t.split(',');
        return [t.replaceAll(',', '.')];
      });
  return tokens.map((t) => double.tryParse(t)).whereType<double>().toList();
}

enum HitSource { impurity, residualSolvent }

/// How a known signal's multiplicity relates to the one the user saw.
enum MultMatch {
  /// Same pattern, e.g. "t" for "t" or "br t".
  exact,

  /// Could look like it: a multiplet ("m"), or a pattern containing the
  /// observed one, e.g. "td" or "dt" for a triplet.
  compatible,

  /// The signal has no reported multiplicity (e.g. ¹³C, some solvent peaks).
  unknown,
}

const _multUnits = [
  'quint',
  'sext',
  'sept',
  'nonet',
  's',
  'd',
  't',
  'q',
  'p',
  'm',
];

/// Splits a multiplicity into its units: "td" → [t, d], "septd" → [sept, d],
/// "br t" → [t]. Returns null for text it does not understand.
List<String>? multiplicityParts(String mult) {
  var rest = mult.trim().toLowerCase().replaceFirst(RegExp(r'^br\s*'), '');
  final parts = <String>[];
  while (rest.isNotEmpty) {
    final unit = _multUnits.where(rest.startsWith).firstOrNull;
    if (unit == null) return null;
    // "p" (pentet) is another name for a quintet.
    parts.add(unit == 'p' ? 'quint' : unit);
    rest = rest.substring(unit.length);
  }
  return parts.isEmpty ? null : parts;
}

/// Compares the multiplicity the user observed with a signal's reported one.
/// Returns null when they cannot be the same peak.
MultMatch? matchMultiplicity(String observed, String? reported) {
  if (reported == null) return MultMatch.unknown;
  final o = multiplicityParts(observed);
  final r = multiplicityParts(reported);
  if (o == null || r == null) return MultMatch.unknown;
  if (_sameParts(o, r)) return MultMatch.exact;
  // A multiplet can hide any split pattern, and vice versa, but not a
  // singlet.
  final oSinglet = _sameParts(o, const ['s']);
  final rSinglet = _sameParts(r, const ['s']);
  if (r.contains('m') && !oSinglet) return MultMatch.compatible;
  if (o.contains('m') && !rSinglet) return MultMatch.compatible;
  // "t" observed, "td" reported: the smaller coupling may be unresolved.
  if (r.length > o.length && _containsAll(r, o)) return MultMatch.compatible;
  return null;
}

bool _sameParts(List<String> a, List<String> b) =>
    a.length == b.length && _containsAll(a, b);

bool _containsAll(List<String> big, List<String> small) {
  final left = [...big];
  for (final u in small) {
    if (!left.remove(u)) return false;
  }
  return true;
}

/// A known signal found near a user-entered shift.
class PeakHit {
  const PeakHit({
    required this.source,
    required this.value,
    required this.delta,
    this.mult,
    this.multMatch,
    this.impurity,
    this.signal,
    this.solvent,
  });

  final HitSource source;

  /// The matched shift (a [Signal] or a [ResidualPeak]).
  final ShiftValue value;
  final String? mult;

  /// Null when no multiplicity was given in the search.
  final MultMatch? multMatch;
  final Impurity? impurity;
  final Signal? signal;
  final Solvent? solvent;

  /// Distance from the queried shift in ppm (0 inside a reported range).
  final double delta;
}

/// Finds every known signal within [tolerance] ppm of [ppm] in the given
/// solvent, including the solvent's own residual peaks.
///
/// With a [multiplicity], signals that cannot have that pattern are left
/// out, and the rest are ordered exact → compatible → unknown, then by
/// distance. Without one, results are ordered by distance only.
List<PeakHit> findPeaksNear({
  required List<Impurity> impurities,
  required Solvent solvent,
  required Nucleus nucleus,
  required double ppm,
  required double tolerance,
  String? multiplicity,
}) {
  final hits = <PeakHit>[];
  void add(HitSource source, ShiftValue v, String? mult, [Impurity? i]) {
    final delta = v.distanceTo(ppm);
    if (delta > tolerance) return;
    MultMatch? match;
    if (multiplicity != null) {
      match = matchMultiplicity(multiplicity, mult);
      if (match == null) return;
    }
    hits.add(
      PeakHit(
        source: source,
        value: v,
        mult: mult,
        multMatch: match,
        impurity: i,
        signal: v is Signal ? v : null,
        solvent: source == HitSource.residualSolvent ? solvent : null,
        delta: delta,
      ),
    );
  }

  for (final p in solvent.residualFor(nucleus)) {
    add(HitSource.residualSolvent, p, p.mult);
  }
  for (final i in impurities) {
    for (final s in i.signalsIn(solvent.id, nucleus)) {
      add(HitSource.impurity, s, s.mult, i);
    }
  }
  hits.sort((a, b) {
    final byMatch = (a.multMatch?.index ?? 0).compareTo(
      b.multMatch?.index ?? 0,
    );
    return byMatch != 0 ? byMatch : a.delta.compareTo(b.delta);
  });
  return hits;
}

/// The [limit] closest signals within [maxDistance] ppm, for when nothing
/// falls inside the chosen tolerance. Ordered by distance.
List<PeakHit> nearestPeaks({
  required List<Impurity> impurities,
  required Solvent solvent,
  required Nucleus nucleus,
  required double ppm,
  required double maxDistance,
  String? multiplicity,
  int limit = 5,
}) {
  final hits = findPeaksNear(
    impurities: impurities,
    solvent: solvent,
    nucleus: nucleus,
    ppm: ppm,
    tolerance: maxDistance,
    multiplicity: multiplicity,
  )..sort((a, b) => a.delta.compareTo(b.delta));
  return hits.take(limit).toList();
}

/// How well one impurity explains a set of observed peaks.
class MultiPeakMatch {
  const MultiPeakMatch({
    required this.impurity,
    required this.matched,
    required this.totalSignals,
    required this.score,
  });

  final Impurity impurity;

  /// Pairs of (observed shift, impurity signal) that lie within tolerance.
  final List<({double observed, Signal signal})> matched;

  /// Number of signals the impurity has in this solvent/nucleus.
  final int totalSignals;

  /// 0..1, higher is better. Mostly the fraction of the impurity's signals
  /// that were observed, reduced slightly by how far off the matches are.
  final double score;
}

/// Ranks impurities by how many of their signals appear among [observed].
///
/// Each impurity signal can be matched by at most one observed peak (the
/// closest one), so a single peak cannot "explain" a triplet and quartet at
/// once.
List<MultiPeakMatch> matchMultiplePeaks({
  required List<Impurity> impurities,
  required String solventId,
  required Nucleus nucleus,
  required List<double> observed,
  required double tolerance,
}) {
  final results = <MultiPeakMatch>[];
  for (final impurity in impurities) {
    final signals = impurity.signalsIn(solventId, nucleus);
    if (signals.isEmpty) continue;
    final matched = <({double observed, Signal signal})>[];
    final used = <int>{};
    for (final signal in signals) {
      int? bestIndex;
      var bestDelta = double.infinity;
      for (var k = 0; k < observed.length; k++) {
        if (used.contains(k)) continue;
        final d = signal.distanceTo(observed[k]);
        if (d <= tolerance && d < bestDelta) {
          bestDelta = d;
          bestIndex = k;
        }
      }
      if (bestIndex != null) {
        used.add(bestIndex);
        matched.add((observed: observed[bestIndex], signal: signal));
      }
    }
    if (matched.isEmpty) continue;
    final coverage = matched.length / signals.length;
    final meanDelta =
        matched
            .map((m) => m.signal.distanceTo(m.observed))
            .reduce((a, b) => a + b) /
        matched.length;
    final closeness = tolerance == 0 ? 1.0 : 1 - 0.5 * (meanDelta / tolerance);
    results.add(
      MultiPeakMatch(
        impurity: impurity,
        matched: matched,
        totalSignals: signals.length,
        score: coverage * closeness,
      ),
    );
  }
  results.sort((a, b) {
    final byCount = b.matched.length.compareTo(a.matched.length);
    return byCount != 0 ? byCount : b.score.compareTo(a.score);
  });
  return results;
}

/// ¹H chemical shift of HDO in D₂O at [celsius], Gottlieb 1997 eq 1:
/// δ = 5.060 − 0.0122·T + 2.11×10⁻⁵·T².
double hdoShiftInD2O(double celsius) =>
    5.060 - 0.0122 * celsius + 2.11e-5 * celsius * celsius;
