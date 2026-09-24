import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NMR Solvent Impurities'**
  String get appTitle;

  /// No description provided for @tabSolvents.
  ///
  /// In en, this message translates to:
  /// **'Solvents'**
  String get tabSolvents;

  /// No description provided for @tabImpurities.
  ///
  /// In en, this message translates to:
  /// **'Impurities'**
  String get tabImpurities;

  /// No description provided for @tabPeakSearch.
  ///
  /// In en, this message translates to:
  /// **'Peak search'**
  String get tabPeakSearch;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @searchSolventsHint.
  ///
  /// In en, this message translates to:
  /// **'Search solvents'**
  String get searchSolventsHint;

  /// No description provided for @searchImpuritiesHint.
  ///
  /// In en, this message translates to:
  /// **'Name, abbreviation or formula'**
  String get searchImpuritiesHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @residualPeaks.
  ///
  /// In en, this message translates to:
  /// **'Residual solvent peaks'**
  String get residualPeaks;

  /// No description provided for @waterPeak.
  ///
  /// In en, this message translates to:
  /// **'Water (H₂O/HOD)'**
  String get waterPeak;

  /// No description provided for @meltingPoint.
  ///
  /// In en, this message translates to:
  /// **'Melting point'**
  String get meltingPoint;

  /// No description provided for @boilingPoint.
  ///
  /// In en, this message translates to:
  /// **'Boiling point'**
  String get boilingPoint;

  /// No description provided for @impuritiesInSolvent.
  ///
  /// In en, this message translates to:
  /// **'Impurities in this solvent'**
  String get impuritiesInSolvent;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @solvent.
  ///
  /// In en, this message translates to:
  /// **'Solvent'**
  String get solvent;

  /// No description provided for @allSolvents.
  ///
  /// In en, this message translates to:
  /// **'All solvents'**
  String get allSolvents;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// No description provided for @aliases.
  ///
  /// In en, this message translates to:
  /// **'Also known as'**
  String get aliases;

  /// No description provided for @noDataForSolvent.
  ///
  /// In en, this message translates to:
  /// **'No data for this solvent'**
  String get noDataForSolvent;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'δ (ppm)'**
  String get shift;

  /// No description provided for @multiplicity.
  ///
  /// In en, this message translates to:
  /// **'Multiplicity'**
  String get multiplicity;

  /// No description provided for @assignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get assignment;

  /// No description provided for @nucleus.
  ///
  /// In en, this message translates to:
  /// **'Nucleus'**
  String get nucleus;

  /// No description provided for @singlePeak.
  ///
  /// In en, this message translates to:
  /// **'Single peak'**
  String get singlePeak;

  /// No description provided for @multiplePeaks.
  ///
  /// In en, this message translates to:
  /// **'Multiple peaks'**
  String get multiplePeaks;

  /// No description provided for @shiftInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Chemical shift (ppm)'**
  String get shiftInputLabel;

  /// No description provided for @anyMultiplicity.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyMultiplicity;

  /// No description provided for @residualSolventPeak.
  ///
  /// In en, this message translates to:
  /// **'Residual solvent peak'**
  String get residualSolventPeak;

  /// No description provided for @enterValueToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter a chemical shift to search'**
  String get enterValueToSearch;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get systemLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @modeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get modeSystem;

  /// No description provided for @modeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get modeLight;

  /// No description provided for @modeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get modeDark;

  /// No description provided for @darkOnlyTheme.
  ///
  /// In en, this message translates to:
  /// **'This theme is always dark'**
  String get darkOnlyTheme;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'NMR Solvent Impurities is a quick reference for identifying the residual signals of deuterated solvents and common trace impurities in NMR spectra. The data were compiled from the peer-reviewed literature and a manufacturer\'s solvent chart, and the app works fully offline.'**
  String get aboutText;

  /// No description provided for @themeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic (red · blue · black)'**
  String get themeClassic;

  /// No description provided for @themeMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themeMidnight;

  /// No description provided for @themeCrimson.
  ///
  /// In en, this message translates to:
  /// **'Crimson'**
  String get themeCrimson;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get themeEmerald;

  /// No description provided for @themeGraphite.
  ///
  /// In en, this message translates to:
  /// **'Graphite'**
  String get themeGraphite;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @toleranceLabel.
  ///
  /// In en, this message translates to:
  /// **'Tolerance: ±{value} ppm'**
  String toleranceLabel(String value);

  /// No description provided for @matchedSignals.
  ///
  /// In en, this message translates to:
  /// **'{matched} of {total} signals matched'**
  String matchedSignals(int matched, int total);

  /// No description provided for @signalsIn.
  ///
  /// In en, this message translates to:
  /// **'Signals in {solvent}'**
  String signalsIn(String solvent);

  /// No description provided for @deltaPpm.
  ///
  /// In en, this message translates to:
  /// **'Δ {value} ppm'**
  String deltaPpm(String value);

  /// No description provided for @impurityCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 impurity} other{{count} impurities}}'**
  String impurityCount(int count);

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Physical properties'**
  String get properties;

  /// No description provided for @density.
  ///
  /// In en, this message translates to:
  /// **'Density (20 °C)'**
  String get density;

  /// No description provided for @dielectric.
  ///
  /// In en, this message translates to:
  /// **'Dielectric constant'**
  String get dielectric;

  /// No description provided for @molecularWeight.
  ///
  /// In en, this message translates to:
  /// **'Molecular weight'**
  String get molecularWeight;

  /// No description provided for @mpBpNote.
  ///
  /// In en, this message translates to:
  /// **'Melting and boiling points are those of the unlabeled compound (except D₂O).'**
  String get mpBpNote;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storageRt.
  ///
  /// In en, this message translates to:
  /// **'Room temperature, away from light and moisture.'**
  String get storageRt;

  /// No description provided for @storageRt1y.
  ///
  /// In en, this message translates to:
  /// **'Room temperature, away from light and moisture. Stable for one year (unopened); re-analyze after that.'**
  String get storageRt1y;

  /// No description provided for @storageFridge6m.
  ///
  /// In en, this message translates to:
  /// **'Refrigerated (−5 to 5 °C), away from light and moisture. Stable for six months (unopened); re-analyze after that.'**
  String get storageFridge6m;

  /// No description provided for @hodTemperature.
  ///
  /// In en, this message translates to:
  /// **'HDO shift vs temperature'**
  String get hodTemperature;

  /// No description provided for @hodTemperatureNote.
  ///
  /// In en, this message translates to:
  /// **'Gottlieb 1997, eq 1. Referenced to sodium 3-(trimethylsilyl)propanesulfonate.'**
  String get hodTemperatureNote;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @hodOnChart.
  ///
  /// In en, this message translates to:
  /// **'HOD (CIL chart)'**
  String get hodOnChart;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sources;

  /// No description provided for @residualFrom.
  ///
  /// In en, this message translates to:
  /// **'From {source}'**
  String residualFrom(String source);

  /// No description provided for @hodAt.
  ///
  /// In en, this message translates to:
  /// **'δ(HDO) at {temp} °C: {shift} ppm'**
  String hodAt(String temp, String shift);

  /// No description provided for @stepSolvent.
  ///
  /// In en, this message translates to:
  /// **'Solvent'**
  String get stepSolvent;

  /// No description provided for @stepShift.
  ///
  /// In en, this message translates to:
  /// **'Chemical shift'**
  String get stepShift;

  /// No description provided for @stepShifts.
  ///
  /// In en, this message translates to:
  /// **'Observed peaks'**
  String get stepShifts;

  /// No description provided for @stepMultiplicity.
  ///
  /// In en, this message translates to:
  /// **'Splitting (multiplicity)'**
  String get stepMultiplicity;

  /// No description provided for @multiplicityHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the pattern you see in your spectrum.'**
  String get multiplicityHint;

  /// No description provided for @multS.
  ///
  /// In en, this message translates to:
  /// **'singlet'**
  String get multS;

  /// No description provided for @multD.
  ///
  /// In en, this message translates to:
  /// **'doublet'**
  String get multD;

  /// No description provided for @multT.
  ///
  /// In en, this message translates to:
  /// **'triplet'**
  String get multT;

  /// No description provided for @multQ.
  ///
  /// In en, this message translates to:
  /// **'quartet'**
  String get multQ;

  /// No description provided for @multQuint.
  ///
  /// In en, this message translates to:
  /// **'quintet'**
  String get multQuint;

  /// No description provided for @multSept.
  ///
  /// In en, this message translates to:
  /// **'septet'**
  String get multSept;

  /// No description provided for @multM.
  ///
  /// In en, this message translates to:
  /// **'multiplet'**
  String get multM;

  /// No description provided for @multDd.
  ///
  /// In en, this message translates to:
  /// **'doublet of doublets'**
  String get multDd;

  /// No description provided for @multBrS.
  ///
  /// In en, this message translates to:
  /// **'broad singlet'**
  String get multBrS;

  /// No description provided for @matchExact.
  ///
  /// In en, this message translates to:
  /// **'Exact match'**
  String get matchExact;

  /// No description provided for @matchCompatible.
  ///
  /// In en, this message translates to:
  /// **'Compatible splitting'**
  String get matchCompatible;

  /// No description provided for @matchCompatibleHint.
  ///
  /// In en, this message translates to:
  /// **'Reported as a multiplet or a more complex pattern that can look like the one you saw.'**
  String get matchCompatibleHint;

  /// No description provided for @matchUnknown.
  ///
  /// In en, this message translates to:
  /// **'Splitting not reported'**
  String get matchUnknown;

  /// No description provided for @nearestHeader.
  ///
  /// In en, this message translates to:
  /// **'Nothing within ±{tol} ppm. Closest signals:'**
  String nearestHeader(String tol);

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String resultCount(int count);

  /// No description provided for @closeExactHeader.
  ///
  /// In en, this message translates to:
  /// **'Nearby exact matches (outside the tolerance):'**
  String get closeExactHeader;

  /// No description provided for @addPeak.
  ///
  /// In en, this message translates to:
  /// **'Add peak'**
  String get addPeak;

  /// No description provided for @removePeak.
  ///
  /// In en, this message translates to:
  /// **'Remove peak'**
  String get removePeak;

  /// No description provided for @stepMultiplicityShort.
  ///
  /// In en, this message translates to:
  /// **'Splitting'**
  String get stepMultiplicityShort;

  /// No description provided for @peakRowsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter each peak and, if you can see it, its splitting. You can also paste a list such as \"2.05 s, 4.12 q, 1.26 t\".'**
  String get peakRowsHint;

  /// No description provided for @peakLabel.
  ///
  /// In en, this message translates to:
  /// **'Peak {n}'**
  String peakLabel(int n);

  /// No description provided for @tabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get tabInfo;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutApp;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @feature1.
  ///
  /// In en, this message translates to:
  /// **'Solvent guide: residual ¹H/¹³C peaks with coupling constants, water/HOD peak, physical properties and storage.'**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In en, this message translates to:
  /// **'Impurity tables: search by name, abbreviation or formula, with the source of every value.'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In en, this message translates to:
  /// **'Peak search: enter the solvent, chemical shift and splitting of a peak in your spectrum to find what it may be.'**
  String get feature3;

  /// No description provided for @feature4.
  ///
  /// In en, this message translates to:
  /// **'Multiple peaks: enter several peaks, with their splittings, to rank the most likely impurities.'**
  String get feature4;

  /// No description provided for @feature5.
  ///
  /// In en, this message translates to:
  /// **'Temperature-dependent HDO shift calculator for D₂O.'**
  String get feature5;

  /// No description provided for @feature6.
  ///
  /// In en, this message translates to:
  /// **'Turkish and English interface, six colour themes, light and dark mode.'**
  String get feature6;

  /// No description provided for @dataContent.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataContent;

  /// No description provided for @dataMethodText.
  ///
  /// In en, this message translates to:
  /// **'Values were transcribed from the tables of the references below and checked against the printed tables. When a compound appears in the same solvent in more than one source, the order of precedence is Fulmer 2010 > Gottlieb 1997 > Babij 2016; later sources only fill in missing data. The app shows the source of every value. Green-chemistry scores and rankings come from the original CHEM21 guide.'**
  String get dataMethodText;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Important note'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'Chemical shifts vary with concentration, temperature, pH and instrument. This app is a reference aid; for a definitive assignment consult the original sources and your own measurements. The tabulated data belong to their publishers and to Cambridge Isotope Laboratories; this app is not affiliated with them.'**
  String get disclaimerText;

  /// No description provided for @referenceList.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get referenceList;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @dataStats.
  ///
  /// In en, this message translates to:
  /// **'{solvents} deuterated solvents · {impurities} impurities · {signals} signals'**
  String dataStats(int solvents, int impurities, int signals);

  /// No description provided for @rankRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get rankRecommended;

  /// No description provided for @rankProblematic.
  ///
  /// In en, this message translates to:
  /// **'Problematic'**
  String get rankProblematic;

  /// No description provided for @rankHazardous.
  ///
  /// In en, this message translates to:
  /// **'Hazardous'**
  String get rankHazardous;

  /// No description provided for @rankHighlyHazardous.
  ///
  /// In en, this message translates to:
  /// **'Highly hazardous'**
  String get rankHighlyHazardous;

  /// No description provided for @rankRecommendedDef.
  ///
  /// In en, this message translates to:
  /// **'To be tested first in a screening exercise, if there is no chemical incompatibility with the process.'**
  String get rankRecommendedDef;

  /// No description provided for @rankProblematicDef.
  ///
  /// In en, this message translates to:
  /// **'Can be used in the lab or kilo lab, but scale-up to pilot plant or production needs specific measures or significant energy.'**
  String get rankProblematicDef;

  /// No description provided for @rankHazardousDef.
  ///
  /// In en, this message translates to:
  /// **'Very strong constraints on scale-up; substituting them during process development is a priority.'**
  String get rankHazardousDef;

  /// No description provided for @rankHighlyHazardousDef.
  ///
  /// In en, this message translates to:
  /// **'To be avoided, even in the laboratory.'**
  String get rankHighlyHazardousDef;

  /// No description provided for @greenChemistry.
  ///
  /// In en, this message translates to:
  /// **'Green chemistry (CHEM21)'**
  String get greenChemistry;

  /// No description provided for @safetyScore.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safetyScore;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthScore;

  /// No description provided for @envScore.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get envScore;

  /// No description provided for @flashPoint.
  ///
  /// In en, this message translates to:
  /// **'Flash point'**
  String get flashPoint;

  /// No description provided for @worstH3.
  ///
  /// In en, this message translates to:
  /// **'Worst health statement'**
  String get worstH3;

  /// No description provided for @worstH4.
  ///
  /// In en, this message translates to:
  /// **'Environment statement'**
  String get worstH4;

  /// No description provided for @hNone.
  ///
  /// In en, this message translates to:
  /// **'None (full REACh registration)'**
  String get hNone;

  /// No description provided for @hNa.
  ///
  /// In en, this message translates to:
  /// **'Not available (no full REACh registration)'**
  String get hNa;

  /// No description provided for @rankingDefault.
  ///
  /// In en, this message translates to:
  /// **'Ranking from the scores'**
  String get rankingDefault;

  /// No description provided for @rankingFinal.
  ///
  /// In en, this message translates to:
  /// **'CHEM21 ranking'**
  String get rankingFinal;

  /// No description provided for @rankChangedNote.
  ///
  /// In en, this message translates to:
  /// **'The CHEM21 team changed the ranking from the scores after discussion.'**
  String get rankChangedNote;

  /// No description provided for @casNumber.
  ///
  /// In en, this message translates to:
  /// **'CAS No.'**
  String get casNumber;

  /// No description provided for @noteSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid at 20 °C'**
  String get noteSolid;

  /// No description provided for @noteWaterSensitive.
  ///
  /// In en, this message translates to:
  /// **'Water sensitive'**
  String get noteWaterSensitive;

  /// No description provided for @nmrSolventsView.
  ///
  /// In en, this message translates to:
  /// **'NMR solvents'**
  String get nmrSolventsView;

  /// No description provided for @chem21GuideView.
  ///
  /// In en, this message translates to:
  /// **'CHEM21 guide'**
  String get chem21GuideView;

  /// No description provided for @chem21Intro.
  ///
  /// In en, this message translates to:
  /// **'Solvent selection guide of the CHEM21 consortium for the pharmaceutical industry. Each solvent is scored 1–10 for safety, health and environment (1 is best) and ranked in four classes.'**
  String get chem21Intro;

  /// No description provided for @chem21BabijNote.
  ///
  /// In en, this message translates to:
  /// **'The CHEM21 marks in the Babij 2016 table differ from this original guide for some solvents; the app uses the original guide (Prat 2016).'**
  String get chem21BabijNote;

  /// No description provided for @searchChem21Hint.
  ///
  /// In en, this message translates to:
  /// **'Search solvents'**
  String get searchChem21Hint;

  /// No description provided for @howScored.
  ///
  /// In en, this message translates to:
  /// **'How are solvents scored?'**
  String get howScored;

  /// No description provided for @rankClasses.
  ///
  /// In en, this message translates to:
  /// **'Ranking classes'**
  String get rankClasses;

  /// No description provided for @scoreColors.
  ///
  /// In en, this message translates to:
  /// **'Scores 1–3 are green, 4–6 yellow and 7–10 red.'**
  String get scoreColors;

  /// No description provided for @safetyRule.
  ///
  /// In en, this message translates to:
  /// **'Based on the flash point: >60 °C → 1; 24–60 °C → 3; 0–23 °C → 4; −1 to −20 °C → 5; below −20 °C → 7. One point is added for each of: auto-ignition temperature below 200 °C, resistivity above 10⁸ Ω·m (static charge build-up) and ability to form peroxides (EUH019). Solvents with a decomposition energy above 500 J/g, such as nitromethane, score 10.'**
  String get safetyRule;

  /// No description provided for @healthRule.
  ///
  /// In en, this message translates to:
  /// **'Based on the most severe GHS/CLP hazard statement: carcinogen, mutagen or reprotoxic cat. 1 (H340, H350, H360) → 9, cat. 2 (H341, H351, H361) → 6; acute toxicity H300/H310/H330 → 9, H301/H311/H331 → 6, H302/H312/H332/H336 → 2; organ toxicity H370/H372 → 6, H334 → 4, H304/H371/H373 → 2; irritation H314 → 7, H318 → 4, H315/H317/H319/H335 → 2. One point is added if the boiling point is below 85 °C. A fully registered solvent without H3xx statements scores 1; without full data, 5.'**
  String get healthRule;

  /// No description provided for @envRule.
  ///
  /// In en, this message translates to:
  /// **'The higher of two scores: boiling point (70–139 °C → 3; 50–69 or 140–200 °C → 5; below 50 or above 200 °C → 7) and aquatic hazard statements (none → 3; H412/H413 → 5; H400/H410/H411 → 7). Without full REACh registration → 5; water → 1; ozone-depleting (H420) → 10.'**
  String get envRule;

  /// No description provided for @rankRule.
  ///
  /// In en, this message translates to:
  /// **'Ranking from the scores (the most stringent rule applies): any score ≥ 8, or two red scores (7–10) → hazardous; one score of 7, or two yellow scores (4–6) → problematic; otherwise recommended. For the classical solvents the CHEM21 team set the final ranking after discussion; highly hazardous is only assigned then.'**
  String get rankRule;

  /// No description provided for @showNmrData.
  ///
  /// In en, this message translates to:
  /// **'NMR data'**
  String get showNmrData;

  /// No description provided for @deuteratedForms.
  ///
  /// In en, this message translates to:
  /// **'Deuterated NMR solvents'**
  String get deuteratedForms;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @hStatementNote.
  ///
  /// In en, this message translates to:
  /// **'Hazard statement wording from the GHS/CLP regulation.'**
  String get hStatementNote;

  /// No description provided for @chem21For.
  ///
  /// In en, this message translates to:
  /// **'Unlabeled {name}'**
  String chem21For(String name);

  /// No description provided for @chem21Count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 solvent} other{{count} solvents}}'**
  String chem21Count(int count);

  /// No description provided for @feature7.
  ///
  /// In en, this message translates to:
  /// **'CHEM21 green-chemistry guide: safety, health and environment scores and ranking of 75 solvents, and how they are scored.'**
  String get feature7;

  /// No description provided for @tabRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get tabRecords;

  /// No description provided for @saveResults.
  ///
  /// In en, this message translates to:
  /// **'Save results'**
  String get saveResults;

  /// No description provided for @sampleName.
  ///
  /// In en, this message translates to:
  /// **'Sample name'**
  String get sampleName;

  /// No description provided for @sampleNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a sample name'**
  String get sampleNameRequired;

  /// No description provided for @analysisDate.
  ///
  /// In en, this message translates to:
  /// **'Analysis date'**
  String get analysisDate;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @markIdentified.
  ///
  /// In en, this message translates to:
  /// **'Mark the impurities you identified in the spectrum.'**
  String get markIdentified;

  /// No description provided for @identifiedSection.
  ///
  /// In en, this message translates to:
  /// **'Identified'**
  String get identifiedSection;

  /// No description provided for @otherCandidates.
  ///
  /// In en, this message translates to:
  /// **'Other candidates'**
  String get otherCandidates;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @recordSaved.
  ///
  /// In en, this message translates to:
  /// **'Record saved'**
  String get recordSaved;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @newRecord.
  ///
  /// In en, this message translates to:
  /// **'New record'**
  String get newRecord;

  /// No description provided for @editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get editRecord;

  /// No description provided for @recordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved records yet. Run a search in Peak search and tap \"Save results\".'**
  String get recordsEmpty;

  /// No description provided for @searchRecordsHint.
  ///
  /// In en, this message translates to:
  /// **'Sample name or note'**
  String get searchRecordsHint;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get deleteRecord;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @copyAsText.
  ///
  /// In en, this message translates to:
  /// **'Copy as text'**
  String get copyAsText;

  /// No description provided for @enteredPeaks.
  ///
  /// In en, this message translates to:
  /// **'Entered peaks'**
  String get enteredPeaks;

  /// No description provided for @searchType.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchType;

  /// No description provided for @noneIdentified.
  ///
  /// In en, this message translates to:
  /// **'No impurity marked as identified.'**
  String get noneIdentified;

  /// No description provided for @recordHeader.
  ///
  /// In en, this message translates to:
  /// **'NMR Solvent Impurities – analysis record'**
  String get recordHeader;

  /// No description provided for @localOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Records are stored only on this device. Uninstalling the app deletes them; use \"Copy as text\" to keep a copy.'**
  String get localOnlyNote;

  /// No description provided for @tolerance.
  ///
  /// In en, this message translates to:
  /// **'Tolerance'**
  String get tolerance;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the record \"{name}\"?'**
  String deleteConfirm(String name);

  /// No description provided for @peakCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 peak} other{{count} peaks}}'**
  String peakCount(int count);

  /// No description provided for @identifiedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} identified'**
  String identifiedCount(int count);

  /// No description provided for @savedOn.
  ///
  /// In en, this message translates to:
  /// **'Saved on {date}'**
  String savedOn(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
