import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_themes.dart';

/// User preferences (theme, dark mode, language), persisted on the device.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs)
    : _paletteId = paletteById(_prefs.getString(_kPalette) ?? '').id,
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == _prefs.getString(_kMode),
        orElse: () => ThemeMode.system,
      ),
      _locale = switch (_prefs.getString(_kLocale)) {
        final String code => Locale(code),
        null => null,
      };

  static const _kPalette = 'palette';
  static const _kMode = 'themeMode';
  static const _kLocale = 'locale';

  final SharedPreferences _prefs;

  String _paletteId;
  ThemeMode _themeMode;
  Locale? _locale;

  AppPalette get palette => paletteById(_paletteId);
  ThemeMode get themeMode => palette.darkOnly ? ThemeMode.dark : _themeMode;

  /// The mode chosen by the user, even if the palette overrides it.
  ThemeMode get preferredThemeMode => _themeMode;

  /// Null means "follow the device language".
  Locale? get locale => _locale;

  Future<void> setPalette(String id) async {
    if (id == _paletteId) return;
    _paletteId = id;
    notifyListeners();
    await _prefs.setString(_kPalette, id);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_kMode, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, locale.languageCode);
    }
  }
}
