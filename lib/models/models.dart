/// Data models for deuterated solvents, impurities and literature references.
///
/// All models are immutable and built from the JSON files in `assets/data/`.
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
    required this.authors,
    required this.title,
    required this.journal,
    required this.year,
    required this.volume,
    required this.pages,
    required this.doi,
  });

  factory Reference.fromJson(Map<String, dynamic> json) => Reference(
    id: json['id'] as String,
    authors: json['authors'] as String,
    title: json['title'] as String,
    journal: json['journal'] as String,
    year: json['year'] as int,
    volume: json['volume'] as String,
    pages: json['pages'] as String,
    doi: json['doi'] as String,
  );

  final String id;
  final String authors;
  final String title;
  final String journal;
  final int year;
  final String volume;
  final String pages;
  final String doi;

  String get citation => '$authors. $journal $year, $volume, $pages.';
  String get doiUrl => 'https://doi.org/$doi';
}

/// A residual (non-deuterated) peak of a deuterated NMR solvent.
class ResidualPeak {
  const ResidualPeak({
    required this.nucleus,
    required this.shift,
    required this.mult,
  });

  factory ResidualPeak.fromJson(Map<String, dynamic> json) => ResidualPeak(
    nucleus: Nucleus.fromCode(json['nucleus'] as String),
    shift: (json['shift'] as num).toDouble(),
    mult: json['mult'] as String,
  );

  final Nucleus nucleus;
  final double shift;
  final String mult;
}

class Solvent {
  const Solvent({
    required this.id,
    required this.name,
    required this.formula,
    required this.residual,
    required this.waterShift,
    required this.meltingPoint,
    required this.boilingPoint,
    required this.refId,
    required this.verified,
  });

  factory Solvent.fromJson(Map<String, dynamic> json) => Solvent(
    id: json['id'] as String,
    name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    formula: json['formula'] as String,
    residual: (json['residual'] as List)
        .map((e) => ResidualPeak.fromJson(e as Map<String, dynamic>))
        .toList(),
    waterShift: (json['waterShift'] as num?)?.toDouble(),
    meltingPoint: (json['meltingPoint'] as num?)?.toDouble(),
    boilingPoint: (json['boilingPoint'] as num?)?.toDouble(),
    refId: json['ref'] as String?,
    verified: json['verified'] as bool? ?? false,
  );

  final String id;
  final LocalizedText name;
  final String formula;
  final List<ResidualPeak> residual;

  /// ¹H shift of residual water (H₂O/HOD) in this solvent.
  final double? waterShift;
  final double? meltingPoint;
  final double? boilingPoint;
  final String? refId;

  /// Whether the values were checked against the cited article.
  final bool verified;

  List<ResidualPeak> residualFor(Nucleus nucleus) =>
      residual.where((p) => p.nucleus == nucleus).toList();
}

/// One NMR signal of an impurity measured in a given deuterated solvent.
class Signal {
  const Signal({
    required this.solventId,
    required this.nucleus,
    required this.shift,
    required this.mult,
    this.assignment,
  });

  factory Signal.fromJson(Map<String, dynamic> json) => Signal(
    solventId: json['solvent'] as String,
    nucleus: Nucleus.fromCode(json['nucleus'] as String),
    shift: (json['shift'] as num).toDouble(),
    mult: json['mult'] as String,
    assignment: json['assignment'] as String?,
  );

  final String solventId;
  final Nucleus nucleus;
  final double shift;
  final String mult;
  final String? assignment;
}

class Impurity {
  const Impurity({
    required this.id,
    required this.name,
    required this.formula,
    required this.aliases,
    required this.signals,
    required this.refId,
    required this.verified,
  });

  factory Impurity.fromJson(Map<String, dynamic> json) => Impurity(
    id: json['id'] as String,
    name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    formula: json['formula'] as String? ?? '',
    aliases: (json['aliases'] as List? ?? const []).cast<String>(),
    signals: (json['signals'] as List)
        .map((e) => Signal.fromJson(e as Map<String, dynamic>))
        .toList(),
    refId: json['ref'] as String?,
    verified: json['verified'] as bool? ?? false,
  );

  final String id;
  final LocalizedText name;
  final String formula;
  final List<String> aliases;
  final List<Signal> signals;
  final String? refId;
  final bool verified;

  List<Signal> signalsIn(String solventId, [Nucleus? nucleus]) =>
      signals
          .where(
            (s) =>
                s.solventId == solventId &&
                (nucleus == null || s.nucleus == nucleus),
          )
          .toList()
        ..sort((a, b) => b.shift.compareTo(a.shift));

  Set<String> get solventIds => signals.map((s) => s.solventId).toSet();
}
