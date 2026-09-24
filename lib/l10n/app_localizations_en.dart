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
  String get references => 'References';

  @override
  String get about => 'About';

  @override
  String get aboutText =>
      'Quick reference for deuterated NMR solvents and the chemical shifts of common trace impurities. Works fully offline.';

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
}
