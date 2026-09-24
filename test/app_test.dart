import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmr_solvents/app.dart';
import 'package:nmr_solvents/data/repository.dart';
import 'package:nmr_solvents/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A phone-width screen tall enough to show the form and the first results.
void tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4200);
  tester.view.devicePixelRatio = 2.6;
  addTearDown(tester.view.reset);
}

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
    tallScreen(tester);
    await tester.pumpWidget(NmrApp(settings: settings, repository: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pik ara'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('peakInput')), '5,30');
    await tester.pumpAndSettle();
    expect(find.text('Diklorometan'), findsOneWidget);
  });

  testWidgets('peak search with a splitting pattern', (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(NmrApp(settings: settings, repository: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pik ara'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('peakInput')), '4,30');
    await tester.tap(find.byKey(const Key('mult-t')));
    await tester.pumpAndSettle();
    expect(find.textContaining('triplet'), findsWidgets);
    expect(find.text('L-Etil laktat'), findsOneWidget);
    expect(find.text('Nitrometan'), findsNothing);
  });

  testWidgets('multiple peaks: a pasted list becomes rows', (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(NmrApp(settings: settings, repository: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pik ara'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Çoklu pik'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('peak-0')),
      '2,05 s; 4,12 q; 1,26 t',
    );
    await tester.pumpAndSettle();
    // Three rows from the pasted text; the empty starting rows are dropped.
    expect(find.byKey(const Key('peak-2')), findsOneWidget);
    expect(find.byKey(const Key('peak-3')), findsNothing);
    expect(find.text('Etil asetat'), findsOneWidget);
    expect(find.text('4.12 q'), findsOneWidget);
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
