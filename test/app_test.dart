import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:io';

import 'package:nmr_solvents/app.dart';
import 'package:nmr_solvents/app_info.dart';
import 'package:nmr_solvents/data/repository.dart';
import 'package:nmr_solvents/records/records_store.dart';
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
  late RecordsStore records;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'locale': 'tr'});
    repo = await NmrRepository.load();
    final prefs = await SharedPreferences.getInstance();
    settings = SettingsController(prefs);
    records = RecordsStore(prefs);
  });

  testWidgets('shows Turkish tabs and switches to English', (tester) async {
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
    await tester.pumpAndSettle();
    expect(find.text('Safsızlıklar'), findsOneWidget);

    await settings.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Impurities'), findsOneWidget);
  });

  testWidgets('peak search finds dichloromethane at 5.30', (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pik ara'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('peakInput')), '5,30');
    await tester.pumpAndSettle();
    expect(find.text('Diklorometan'), findsOneWidget);
  });

  testWidgets('peak search with a splitting pattern', (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
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
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
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

  testWidgets('info page (from settings) shows developer and references', (
    tester,
  ) async {
    tallScreen(tester);
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('aboutApp')));
    await tester.pumpAndSettle();
    expect(find.text('Dr. İlker ÜN'), findsOneWidget);
    expect(find.byKey(const Key('appIcon')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('[5] NMR Solvent Data Chart'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    for (final n in [1, 2, 3, 4, 5]) {
      expect(find.textContaining('[$n] '), findsOneWidget);
    }
    expect(find.textContaining('10.1021/om100106e'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('packageLicenses')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('GPL-3.0'), findsWidgets);
    expect(find.text('© 2026 Dr. İlker ÜN'), findsOneWidget);
    expect(find.text(kSourceUrl), findsOneWidget);
  });

  testWidgets('pages leave room for the system navigation bar', (tester) async {
    tallScreen(tester);
    // Android 15+ edge to edge: the navigation buttons cover 48 dp.
    tester.view.padding = const FakeViewPadding(bottom: 48 * 2.6);
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
    await tester.pumpAndSettle();
    double listBottom() =>
        (tester.widget<ListView>(find.byType(ListView).last).padding!
                as EdgeInsets)
            .bottom;

    // Inside the tabs the navigation bar already takes the inset.
    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    expect(listBottom(), 24);

    // A pushed page scrolls its last lines above the navigation buttons.
    await tester.tap(find.byKey(const Key('aboutApp')));
    await tester.pumpAndSettle();
    expect(listBottom(), 24 + 48);
  });

  testWidgets('CHEM21 guide filters by ranking', (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('CHEM21 rehberi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rank-hh')));
    await tester.pumpAndSettle();
    expect(find.text('8 çözücü'), findsOneWidget);
    expect(find.text('Kloroform'), findsOneWidget);
    await tester.tap(find.text('Kloroform'));
    await tester.pumpAndSettle();
    expect(find.text('Çok tehlikeli'), findsWidgets);
    expect(find.textContaining('H351'), findsOneWidget);
  });

  testWidgets('save a search as a record, view, edit and delete it', (
    tester,
  ) async {
    tallScreen(tester);
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
    await tester.pumpAndSettle();

    // Search: CDCl3, 5.30 ppm, singlet.
    await tester.tap(find.text('Pik ara'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('peakInput')), '5,30');
    await tester.tap(find.byKey(const Key('mult-s')));
    await tester.pumpAndSettle();

    // Save it: the name is required.
    await tester.tap(find.byKey(const Key('saveResults')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveRecord')));
    await tester.pumpAndSettle();
    expect(find.text('Numune adını girin'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('sampleName')), 'IU-042');
    await tester.enterText(
      find.byKey(const Key('recordNote')),
      'kolon sonrası',
    );
    final dcm = find.widgetWithText(CheckboxListTile, 'Diklorometan');
    await tester.ensureVisible(dcm);
    await tester.tap(dcm);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveRecord')));
    await tester.pumpAndSettle();
    expect(records.records.single.sampleName, 'IU-042');
    expect(
      records.records.single.identified.single.impurityId,
      'dichloromethane',
    );

    // It is listed in the Records tab with the identified impurity.
    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    expect(find.text('IU-042'), findsOneWidget);
    expect(find.text('Diklorometan'), findsOneWidget);

    // Detail, then rename it.
    await tester.tap(find.text('IU-042'));
    await tester.pumpAndSettle();
    expect(find.text('kolon sonrası'), findsOneWidget);
    await tester.tap(find.byKey(const Key('editRecord')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sampleName')), 'IU-043');
    await tester.tap(find.byKey(const Key('saveRecord')));
    await tester.pumpAndSettle();
    expect(find.text('IU-043'), findsWidgets);

    // Delete it.
    await tester.tap(find.byKey(const Key('deleteRecord')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDelete')));
    await tester.pumpAndSettle();
    expect(records.records, isEmpty);
    expect(find.textContaining('Henüz kayıt yok'), findsOneWidget);
  });

  test('app version matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: ([\d.]+)',
      multiLine: true,
    ).firstMatch(pubspec)![1];
    expect(kAppVersion, version);
  });

  testWidgets('theme choice is applied and persisted', (tester) async {
    await tester.pumpWidget(
      NmrApp(settings: settings, repository: repo, records: records),
    );
    await tester.pumpAndSettle();
    await settings.setPalette('midnight');
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('palette'), 'midnight');
  });
}
