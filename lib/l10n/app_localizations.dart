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
  /// **'NMR Solvents'**
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

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @notVerifiedHint.
  ///
  /// In en, this message translates to:
  /// **'Preliminary data – to be checked against the cited article.'**
  String get notVerifiedHint;

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

  /// No description provided for @peaksInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Observed peaks (ppm)'**
  String get peaksInputLabel;

  /// No description provided for @peaksInputHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2.05, 4.12, 1.26'**
  String get peaksInputHint;

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

  /// No description provided for @references.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get references;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'Quick reference for deuterated NMR solvents and the chemical shifts of common trace impurities. Works fully offline.'**
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
