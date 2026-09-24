/// Data models for deuterated solvents, impurities and literature references.
///
/// All models are immutable and built from the JSON files in `assets/data/`,
/// which tool/build_data.py generates from the transcribed articles.
library;

enum Nucleus {
  h1('1H', '¹H'),
  c13('13C', '¹³C');

  const Nucleus(this.code, this.label);

  /// Code used in the JSON data files.
  final String code;

  /// Display label with superscript mass number.
  final String label;

  static Nucleus fromCode(String code) => Nucleus.values.firstWhere(
    (n) => n.code == code,
    orElse: () => throw FormatException('Unknown nucleus: $code'),
  );
}

/// CHEM21 solvent selection guide rating, as reported by Babij 2016.
enum Chem21 {
  recommended('rec'),
  problematic('prob');

  const Chem21(this.code);

  final String code;

  static Chem21? fromCode(String? code) {
    for (final c in Chem21.values) {
      if (c.code == code) return c;
    }
    return null;
  }
}

/// A text available in several languages, keyed by language code.
class LocalizedText {
  const LocalizedText(this.values);

  factory LocalizedText.fromJson(Map<String, dynamic> json) =>
      LocalizedText(json.map((k, v) => MapEntry(k, v as String)));

  final Map<String, String> values;

  /// Returns the text for [languageCode], falling back to English.
  String of(String languageCode) =>
      values[languageCode] ?? values['en'] ?? values.values.first;

  Iterable<String> get all => values.values;
}

class Reference {
  const Reference({
    required this.id,
    required this.short,
    required this.authors,
    required this.title,
    required this.source,
    this.doi,
  });

  factory Reference.fromJson(Map<String, dynamic> json) => Reference(
    id: json['id'] as String,
    short: json['short'] as String,
    authors: json['authors'] as String,
    title: json['title'] as String,
    source: json['source'] as String,
    doi: json['doi'] as String?,
  );

  final String id;

  /// Short label such as "Fulmer 2010".
  final String short;
  final String authors;
  final String title;
  final String source;
  final String? doi;

  String get citation => '$authors. $source.';
  String? get doiUrl => doi == null ? null : 'https://doi.org/$doi';
}

/// A chemical shift that may be a single value or a range (multiplets).
mixin ShiftValue {
  double get shift;

  /// Upper end of the range, or null for a single value.
  double? get shiftMax;

  /// Distance in ppm from [ppm] to this shift; 0 inside a range.
  double distanceTo(double ppm) {
    final max = shiftMax;
    if (max == null) return (shift - ppm).abs();
    if (ppm < shift) return shift - ppm;
    if (ppm > max) return ppm - max;
    return 0;
  }

  /// Midpoint, used for sorting.
  double get center => shiftMax == null ? shift : (shift + shiftMax!) / 2;
}

/// A residual (non-deuterated) peak of a deuterated NMR solvent.
class ResidualPeak with ShiftValue {
  const ResidualPeak({
    required this.nucleus,
    required this.shift,
    required this.refId,
    this.mult,
    this.coupling,
  });

  factory ResidualPeak.fromJson(Map<String, dynamic> json) => ResidualPeak(
    nucleus: Nucleus.fromCode(json['nucleus'] as String),
    shift: (json['shift'] as num).toDouble(),
    refId: json['ref'] as String,
    mult: json['mult'] as String?,
    coupling: ((json['JHD'] ?? json['JCD']) as num?)?.toDouble(),
  );

  final Nucleus nucleus;
  @override
  final double shift;
  @override
  double? get shiftMax => null;
  final String refId;
  final String? mult;

  /// J(H,D) or J(C,D) in Hz, when reported.
  final double? coupling;
}

class Solvent {
  const Solvent({
    required this.id,
    required this.name,
    required this.formula,
    required this.residual,
    this.waterShift,
    this.waterRefId,
    this.hodCil,
    this.density,
    this.meltingPoint,
    this.boilingPoint,
    this.dielectric,
    this.molecularWeight,
    this.note,
    this.storage,
  });

  factory Solvent.fromJson(Map<String, dynamic> json) {
    final water = json['water'] as Map<String, dynamic>?;
    return Solvent(
      id: json['id'] as String,
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
      formula: json['formula'] as String,
      residual: (json['residual'] as List)
          .map((e) => ResidualPeak.fromJson(e as Map<String, dynamic>))
          .toList(),
      waterShift: (water?['shift'] as num?)?.toDouble(),
      waterRefId: water?['ref'] as String?,
      hodCil: json['hodCil'] as String?,
      density: (json['density'] as num?)?.toDouble(),
      meltingPoint: json['meltingPoint']?.toString(),
      boilingPoint: json['boilingPoint']?.toString(),
      dielectric: (json['dielectric'] as num?)?.toDouble(),
      molecularWeight: (json['molecularWeight'] as num?)?.toDouble(),
      note: json['note'] as String?,
      storage: json['storage'] as String?,
    );
  }

  final String id;
  final LocalizedText name;
  final String formula;
  final List<ResidualPeak> residual;

  /// ¹H shift of residual water (H₂O/HOD) in this solvent.
  final double? waterShift;
  final String? waterRefId;

  /// HOD shift as printed on the CIL chart (may be a range like "2.4-2.5").
  final String? hodCil;

  /// g/mL at 20 °C.
  final double? density;

  /// °C, of the unlabeled compound (except D₂O); may be a range.
  final String? meltingPoint;
  final String? boilingPoint;
  final double? dielectric;
  final double? molecularWeight;
  final String? note;

  /// Storage code from the CIL chart: rt, rt_1y or fridge_6m.
  final String? storage;

  /// Reference ids of the residual peak sets, most authoritative first.
  List<String> get residualRefs {
    final refs = <String>[];
    for (final p in residual) {
      if (!refs.contains(p.refId)) refs.add(p.refId);
    }
    return refs;
  }

  /// Residual peaks used for display and searching: from the first source
  /// (Fulmer 2010 where available, otherwise the CIL chart).
  List<ResidualPeak> residualFor(Nucleus nucleus) {
    for (final ref in residualRefs) {
      final peaks = residual
          .where((p) => p.refId == ref && p.nucleus == nucleus)
          .toList();
      if (peaks.isNotEmpty) return peaks;
    }
    return const [];
  }
}

/// One NMR signal of an impurity measured in a given deuterated solvent.
class Signal with ShiftValue {
  const Signal({
    required this.solventId,
    required this.nucleus,
    required this.shift,
    required this.refId,
    this.shiftMax,
    this.mult,
    this.coupling,
    this.assignment,
    this.note,
  });

  factory Signal.fromJson(Map<String, dynamic> json) => Signal(
    solventId: json['solvent'] as String,
    nucleus: Nucleus.fromCode(json['nucleus'] as String),
    shift: (json['shift'] as num).toDouble(),
    shiftMax: (json['shiftMax'] as num?)?.toDouble(),
    refId: json['ref'] as String,
    mult: json['mult'] as String?,
    coupling: json['J'] as String?,
    assignment: json['assignment'] as String?,
    note: json['note'] as String?,
  );

  final String solventId;
  final Nucleus nucleus;
  @override
  final double shift;
  @override
  final double? shiftMax;
  final String refId;
  final String? mult;

  /// Coupling constant(s) in Hz as printed, e.g. "7" or "6.4, 1.5".
  final String? coupling;
  final String? assignment;
  final String? note;

  /// "t (7)" style multiplicity with coupling.
  String? get multWithJ {
    if (mult == null) return null;
    return coupling == null ? mult : '$mult ($coupling)';
  }
}

class Impurity {
  const Impurity({
    required this.id,
    required this.name,
    required this.formula,
    required this.aliases,
    required this.signals,
    this.chem21,
    this.note,
  });

  factory Impurity.fromJson(Map<String, dynamic> json) => Impurity(
    id: json['id'] as String,
    name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    formula: json['formula'] as String? ?? '',
    aliases: (json['aliases'] as List? ?? const []).cast<String>(),
    signals: (json['signals'] as List)
        .map((e) => Signal.fromJson(e as Map<String, dynamic>))
        .toList(),
    chem21: Chem21.fromCode(json['chem21'] as String?),
    note: json['note'] as String?,
  );

  final String id;
  final LocalizedText name;
  final String formula;
  final List<String> aliases;
  final List<Signal> signals;
  final Chem21? chem21;
  final String? note;

  /// Signals in [solventId], highest shift first.
  List<Signal> signalsIn(String solventId, [Nucleus? nucleus]) =>
      signals
          .where(
            (s) =>
                s.solventId == solventId &&
                (nucleus == null || s.nucleus == nucleus),
          )
          .toList()
        ..sort((a, b) => b.center.compareTo(a.center));

  Set<String> get solventIds => signals.map((s) => s.solventId).toSet();

  /// Reference ids used for [solventId], in order of appearance.
  List<String> refsIn(String solventId) {
    final refs = <String>[];
    for (final s in signals) {
      if (s.solventId == solventId && !refs.contains(s.refId)) {
        refs.add(s.refId);
      }
    }
    return refs;
  }
}
