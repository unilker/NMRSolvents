// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NMR Solvent Impurities';

  @override
  String get tabSolvents => 'Solvents';

  @override
  String get tabImpurities => 'Impurities';

  @override
  String get tabPeakSearch => 'Peak search';

  @override
  String get tabSettings => 'Settings';

  @override
  String get searchSolventsHint => 'Search solvents';

  @override
  String get searchImpuritiesHint => 'Name, abbreviation or formula';

  @override
  String get noResults => 'No results';

  @override
  String get residualPeaks => 'Residual solvent peaks';

  @override
  String get waterPeak => 'Water (H₂O/HOD)';

  @override
  String get meltingPoint => 'Melting point';

  @override
  String get boilingPoint => 'Boiling point';

  @override
  String get impuritiesInSolvent => 'Impurities in this solvent';

  @override
  String get reference => 'Reference';

  @override
  String get solvent => 'Solvent';

  @override
  String get allSolvents => 'All solvents';

  @override
  String get formula => 'Formula';

  @override
  String get aliases => 'Also known as';

  @override
  String get noDataForSolvent => 'No data for this solvent';

  @override
  String get shift => 'δ (ppm)';

  @override
  String get multiplicity => 'Multiplicity';

  @override
  String get assignment => 'Assignment';

  @override
  String get nucleus => 'Nucleus';

  @override
  String get singlePeak => 'Single peak';

  @override
  String get multiplePeaks => 'Multiple peaks';

  @override
  String get shiftInputLabel => 'Chemical shift (ppm)';

  @override
  String get anyMultiplicity => 'Any';

  @override
  String get residualSolventPeak => 'Residual solvent peak';

  @override
  String get enterValueToSearch => 'Enter a chemical shift to search';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'Device language';

  @override
  String get theme => 'Theme';

  @override
  String get appearance => 'Appearance';

  @override
  String get modeSystem => 'System';

  @override
  String get modeLight => 'Light';

  @override
  String get modeDark => 'Dark';

  @override
  String get darkOnlyTheme => 'This theme is always dark';

  @override
  String get aboutText =>
      'NMR Solvent Impurities is a quick reference for identifying the residual signals of deuterated solvents and common trace impurities in NMR spectra. The data were compiled from the peer-reviewed literature and a manufacturer\'s solvent chart, and the app works fully offline.';

  @override
  String get themeClassic => 'Classic (red · blue · black)';

  @override
  String get themeMidnight => 'Midnight';

  @override
  String get themeCrimson => 'Crimson';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeEmerald => 'Emerald';

  @override
  String get themeGraphite => 'Graphite';

  @override
  String get copied => 'Copied';

  @override
  String toleranceLabel(String value) {
    return 'Tolerance: ±$value ppm';
  }

  @override
  String matchedSignals(int matched, int total) {
    return '$matched of $total signals matched';
  }

  @override
  String signalsIn(String solvent) {
    return 'Signals in $solvent';
  }

  @override
  String deltaPpm(String value) {
    return 'Δ $value ppm';
  }

  @override
  String impurityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count impurities',
      one: '1 impurity',
    );
    return '$_temp0';
  }

  @override
  String get properties => 'Physical properties';

  @override
  String get density => 'Density (20 °C)';

  @override
  String get dielectric => 'Dielectric constant';

  @override
  String get molecularWeight => 'Molecular weight';

  @override
  String get mpBpNote =>
      'Melting and boiling points are those of the unlabeled compound (except D₂O).';

  @override
  String get storage => 'Storage';

  @override
  String get storageRt => 'Room temperature, away from light and moisture.';

  @override
  String get storageRt1y =>
      'Room temperature, away from light and moisture. Stable for one year (unopened); re-analyze after that.';

  @override
  String get storageFridge6m =>
      'Refrigerated (−5 to 5 °C), away from light and moisture. Stable for six months (unopened); re-analyze after that.';

  @override
  String get hodTemperature => 'HDO shift vs temperature';

  @override
  String get hodTemperatureNote =>
      'Gottlieb 1997, eq 1. Referenced to sodium 3-(trimethylsilyl)propanesulfonate.';

  @override
  String get note => 'Note';

  @override
  String get hodOnChart => 'HOD (CIL chart)';

  @override
  String get sources => 'Sources';

  @override
  String residualFrom(String source) {
    return 'From $source';
  }

  @override
  String hodAt(String temp, String shift) {
    return 'δ(HDO) at $temp °C: $shift ppm';
  }

  @override
  String get stepSolvent => 'Solvent';

  @override
  String get stepShift => 'Chemical shift';

  @override
  String get stepShifts => 'Observed peaks';

  @override
  String get stepMultiplicity => 'Splitting (multiplicity)';

  @override
  String get multiplicityHint => 'Pick the pattern you see in your spectrum.';

  @override
  String get multS => 'singlet';

  @override
  String get multD => 'doublet';

  @override
  String get multT => 'triplet';

  @override
  String get multQ => 'quartet';

  @override
  String get multQuint => 'quintet';

  @override
  String get multSept => 'septet';

  @override
  String get multM => 'multiplet';

  @override
  String get multDd => 'doublet of doublets';

  @override
  String get multBrS => 'broad singlet';

  @override
  String get matchExact => 'Exact match';

  @override
  String get matchCompatible => 'Compatible splitting';

  @override
  String get matchCompatibleHint =>
      'Reported as a multiplet or a more complex pattern that can look like the one you saw.';

  @override
  String get matchUnknown => 'Splitting not reported';

  @override
  String nearestHeader(String tol) {
    return 'Nothing within ±$tol ppm. Closest signals:';
  }

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get closeExactHeader =>
      'Nearby exact matches (outside the tolerance):';

  @override
  String get addPeak => 'Add peak';

  @override
  String get removePeak => 'Remove peak';

  @override
  String get stepMultiplicityShort => 'Splitting';

  @override
  String get peakRowsHint =>
      'Enter each peak and, if you can see it, its splitting. You can also paste a list such as \"2.05 s, 4.12 q, 1.26 t\".';

  @override
  String peakLabel(int n) {
    return 'Peak $n';
  }

  @override
  String get tabInfo => 'Info';

  @override
  String get developer => 'Developer';

  @override
  String get aboutApp => 'About the app';

  @override
  String get features => 'Features';

  @override
  String get feature1 =>
      'Solvent guide: residual ¹H/¹³C peaks with coupling constants, water/HOD peak, physical properties and storage.';

  @override
  String get feature2 =>
      'Impurity tables: search by name, abbreviation or formula, with the source of every value.';

  @override
  String get feature3 =>
      'Peak search: enter the solvent, chemical shift and splitting of a peak in your spectrum to find what it may be.';

  @override
  String get feature4 =>
      'Multiple peaks: enter several peaks, with their splittings, to rank the most likely impurities.';

  @override
  String get feature5 => 'Temperature-dependent HDO shift calculator for D₂O.';

  @override
  String get feature6 =>
      'Turkish and English interface, six colour themes, light and dark mode.';

  @override
  String get dataContent => 'Data';

  @override
  String get dataMethodText =>
      'Values were transcribed from the tables of the references below and checked against the printed tables. When a compound appears in the same solvent in more than one source, the order of precedence is Fulmer 2010 > Gottlieb 1997 > Babij 2016; later sources only fill in missing data. The app shows the source of every value. Green-chemistry scores and rankings come from the original CHEM21 guide.';

  @override
  String get disclaimerTitle => 'Important note';

  @override
  String get disclaimerText =>
      'Chemical shifts vary with concentration, temperature, pH and instrument. This app is a reference aid; for a definitive assignment consult the original sources and your own measurements. The tabulated data belong to their publishers and to Cambridge Isotope Laboratories; this app is not affiliated with them.';

  @override
  String get referenceList => 'References';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String dataStats(int solvents, int impurities, int signals) {
    return '$solvents deuterated solvents · $impurities impurities · $signals signals';
  }

  @override
  String get rankRecommended => 'Recommended';

  @override
  String get rankProblematic => 'Problematic';

  @override
  String get rankHazardous => 'Hazardous';

  @override
  String get rankHighlyHazardous => 'Highly hazardous';

  @override
  String get rankRecommendedDef =>
      'To be tested first in a screening exercise, if there is no chemical incompatibility with the process.';

  @override
  String get rankProblematicDef =>
      'Can be used in the lab or kilo lab, but scale-up to pilot plant or production needs specific measures or significant energy.';

  @override
  String get rankHazardousDef =>
      'Very strong constraints on scale-up; substituting them during process development is a priority.';

  @override
  String get rankHighlyHazardousDef => 'To be avoided, even in the laboratory.';

  @override
  String get greenChemistry => 'Green chemistry (CHEM21)';

  @override
  String get safetyScore => 'Safety';

  @override
  String get healthScore => 'Health';

  @override
  String get envScore => 'Environment';

  @override
  String get flashPoint => 'Flash point';

  @override
  String get worstH3 => 'Worst health statement';

  @override
  String get worstH4 => 'Environment statement';

  @override
  String get hNone => 'None (full REACh registration)';

  @override
  String get hNa => 'Not available (no full REACh registration)';

  @override
  String get rankingDefault => 'Ranking from the scores';

  @override
  String get rankingFinal => 'CHEM21 ranking';

  @override
  String get rankChangedNote =>
      'The CHEM21 team changed the ranking from the scores after discussion.';

  @override
  String get casNumber => 'CAS No.';

  @override
  String get noteSolid => 'Solid at 20 °C';

  @override
  String get noteWaterSensitive => 'Water sensitive';

  @override
  String get nmrSolventsView => 'NMR solvents';

  @override
  String get chem21GuideView => 'CHEM21 guide';

  @override
  String get chem21Intro =>
      'Solvent selection guide of the CHEM21 consortium for the pharmaceutical industry. Each solvent is scored 1–10 for safety, health and environment (1 is best) and ranked in four classes.';

  @override
  String get chem21BabijNote =>
      'The CHEM21 marks in the Babij 2016 table differ from this original guide for some solvents; the app uses the original guide (Prat 2016).';

  @override
  String get searchChem21Hint => 'Search solvents';

  @override
  String get howScored => 'How are solvents scored?';

  @override
  String get rankClasses => 'Ranking classes';

  @override
  String get scoreColors => 'Scores 1–3 are green, 4–6 yellow and 7–10 red.';

  @override
  String get safetyRule =>
      'Based on the flash point: >60 °C → 1; 24–60 °C → 3; 0–23 °C → 4; −1 to −20 °C → 5; below −20 °C → 7. One point is added for each of: auto-ignition temperature below 200 °C, resistivity above 10⁸ Ω·m (static charge build-up) and ability to form peroxides (EUH019). Solvents with a decomposition energy above 500 J/g, such as nitromethane, score 10.';

  @override
  String get healthRule =>
      'Based on the most severe GHS/CLP hazard statement: carcinogen, mutagen or reprotoxic cat. 1 (H340, H350, H360) → 9, cat. 2 (H341, H351, H361) → 6; acute toxicity H300/H310/H330 → 9, H301/H311/H331 → 6, H302/H312/H332/H336 → 2; organ toxicity H370/H372 → 6, H334 → 4, H304/H371/H373 → 2; irritation H314 → 7, H318 → 4, H315/H317/H319/H335 → 2. One point is added if the boiling point is below 85 °C. A fully registered solvent without H3xx statements scores 1; without full data, 5.';

  @override
  String get envRule =>
      'The higher of two scores: boiling point (70–139 °C → 3; 50–69 or 140–200 °C → 5; below 50 or above 200 °C → 7) and aquatic hazard statements (none → 3; H412/H413 → 5; H400/H410/H411 → 7). Without full REACh registration → 5; water → 1; ozone-depleting (H420) → 10.';

  @override
  String get rankRule =>
      'Ranking from the scores (the most stringent rule applies): any score ≥ 8, or two red scores (7–10) → hazardous; one score of 7, or two yellow scores (4–6) → problematic; otherwise recommended. For the classical solvents the CHEM21 team set the final ranking after discussion; highly hazardous is only assigned then.';

  @override
  String get showNmrData => 'NMR data';

  @override
  String get deuteratedForms => 'Deuterated NMR solvents';

  @override
  String get family => 'Family';

  @override
  String get hStatementNote =>
      'Hazard statement wording from the GHS/CLP regulation.';

  @override
  String chem21For(String name) {
    return 'Unlabeled $name';
  }

  @override
  String chem21Count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solvents',
      one: '1 solvent',
    );
    return '$_temp0';
  }

  @override
  String get feature7 =>
      'CHEM21 green-chemistry guide: safety, health and environment scores and ranking of 75 solvents, and how they are scored.';

  @override
  String get tabRecords => 'Records';

  @override
  String get saveResults => 'Save results';

  @override
  String get sampleName => 'Sample name';

  @override
  String get sampleNameRequired => 'Enter a sample name';

  @override
  String get analysisDate => 'Analysis date';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get markIdentified =>
      'Mark the impurities you identified in the spectrum.';

  @override
  String get identifiedSection => 'Identified';

  @override
  String get otherCandidates => 'Other candidates';

  @override
  String get save => 'Save';

  @override
  String get recordSaved => 'Record saved';

  @override
  String get view => 'View';

  @override
  String get newRecord => 'New record';

  @override
  String get editRecord => 'Edit record';

  @override
  String get recordsEmpty =>
      'No saved records yet. Run a search in Peak search and tap \"Save results\".';

  @override
  String get searchRecordsHint => 'Sample name or note';

  @override
  String get deleteRecord => 'Delete record';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get copyAsText => 'Copy as text';

  @override
  String get enteredPeaks => 'Entered peaks';

  @override
  String get searchType => 'Search';

  @override
  String get noneIdentified => 'No impurity marked as identified.';

  @override
  String get recordHeader => 'NMR Solvent Impurities – analysis record';

  @override
  String get localOnlyNote =>
      'Records are stored only on this device. Uninstalling the app deletes them; use \"Copy as text\" to keep a copy.';

  @override
  String get tolerance => 'Tolerance';

  @override
  String get edit => 'Edit';

  @override
  String deleteConfirm(String name) {
    return 'Delete the record \"$name\"?';
  }

  @override
  String peakCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peaks',
      one: '1 peak',
    );
    return '$_temp0';
  }

  @override
  String identifiedCount(int count) {
    return '$count identified';
  }

  @override
  String savedOn(String date) {
    return 'Saved on $date';
  }
}
