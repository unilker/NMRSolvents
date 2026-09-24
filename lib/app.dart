import 'package:flutter/material.dart';

import 'data/repository.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'settings/settings_controller.dart';
import 'theme/app_themes.dart';
import 'widgets/common.dart';

class NmrApp extends StatelessWidget {
  const NmrApp({super.key, required this.settings, required this.repository});

  final SettingsController settings;
  final NmrRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => AppScope(
        repository: repository,
        settings: settings,
        child: MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(settings.palette, Brightness.light),
          darkTheme: buildTheme(settings.palette, Brightness.dark),
          themeMode: settings.themeMode,
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
