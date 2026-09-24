import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repository.dart';
import 'settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (prefs, repository) = await (
    SharedPreferences.getInstance(),
    NmrRepository.load(),
  ).wait;
  runApp(NmrApp(settings: SettingsController(prefs), repository: repository));
}
