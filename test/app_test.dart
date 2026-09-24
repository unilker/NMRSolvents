import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmr_solvents/app.dart';
import 'package:nmr_solvents/data/repository.dart';
import 'package:nmr_solvents/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late NmrRepository repo;
  late SettingsController settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'locale': 'tr'});
    repo = await NmrRepository.load();
    settings = SettingsController(await SharedPreferences.getInstance());
  });

  testWidgets('shows Turkish tabs and switches to English', (tester) async {
    await tester.pumpWidget(NmrApp(settings: settings, repository: repo));
    await tester.pumpAndSettle();
    expect(find.text('Safsızlıklar'), findsOneWidget);

    await settings.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Impurities'), findsOneWidget);
  });

  testWidgets('peak search finds dichloromethane at 5.30', (tester) async {
    await tester.pumpWidget(NmrApp(settings: settings, repository: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pik ara'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('peakInput')), '5,30');
    await tester.pumpAndSettle();
    expect(find.text('Diklorometan'), findsOneWidget);
  });

  testWidgets('theme choice is applied and persisted', (tester) async {
    await tester.pumpWidget(NmrApp(settings: settings, repository: repo));
    await tester.pumpAndSettle();
    await settings.setPalette('midnight');
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('palette'), 'midnight');
  });
}
