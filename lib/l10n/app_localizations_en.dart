// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NMR Solvents';

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
      'NMR Solvents is a quick reference for identifying the residual signals of deuterated solvents and common trace impurities in NMR spectra. The data were compiled from the peer-reviewed literature and a manufacturer\'s solvent chart, and the app works fully offline.';

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
  String get chem21Recommended => 'CHEM21: recommended';

  @override
  String get chem21Problematic => 'CHEM21: problematic';

  @override
  String get chem21Hint =>
      'Rating in the CHEM21 solvent selection guide, as listed by Babij 2016.';

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
      'Impurity tables: search by name, abbreviation or formula; the source of every value and the CHEM21 green-chemistry rating.';

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
      'Values were transcribed from the tables of the references below and checked against the printed tables. When a compound appears in the same solvent in more than one source, the order of precedence is Fulmer 2010 > Gottlieb 1997 > Babij 2016; later sources only fill in missing data. The app shows the source of every value.';

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
  String chem21Source(int n) {
    return 'CHEM21 ratings are used as listed in [$n]; original guide: D. Prat et al., Green Chem. 2016, 18, 288.';
  }
}
