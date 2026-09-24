// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'NMR Çözücüler';

  @override
  String get tabSolvents => 'Çözücüler';

  @override
  String get tabImpurities => 'Safsızlıklar';

  @override
  String get tabPeakSearch => 'Pik ara';

  @override
  String get tabSettings => 'Ayarlar';

  @override
  String get searchSolventsHint => 'Çözücü ara';

  @override
  String get searchImpuritiesHint => 'Ad, kısaltma veya formül';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String get residualPeaks => 'Kalıntı çözücü pikleri';

  @override
  String get waterPeak => 'Su (H₂O/HOD)';

  @override
  String get meltingPoint => 'Erime noktası';

  @override
  String get boilingPoint => 'Kaynama noktası';

  @override
  String get impuritiesInSolvent => 'Bu çözücüdeki safsızlıklar';

  @override
  String get reference => 'Kaynak';

  @override
  String get solvent => 'Çözücü';

  @override
  String get allSolvents => 'Tüm çözücüler';

  @override
  String get formula => 'Formül';

  @override
  String get aliases => 'Diğer adlar';

  @override
  String get noDataForSolvent => 'Bu çözücü için veri yok';

  @override
  String get shift => 'δ (ppm)';

  @override
  String get multiplicity => 'Çokluk';

  @override
  String get assignment => 'Atama';

  @override
  String get nucleus => 'Çekirdek';

  @override
  String get singlePeak => 'Tek pik';

  @override
  String get multiplePeaks => 'Çoklu pik';

  @override
  String get shiftInputLabel => 'Kimyasal kayma (ppm)';

  @override
  String get peaksInputLabel => 'Gözlenen pikler (ppm)';

  @override
  String get peaksInputHint => 'örn. 2,05 4,12 1,26';

  @override
  String get anyMultiplicity => 'Hepsi';

  @override
  String get residualSolventPeak => 'Kalıntı çözücü piki';

  @override
  String get enterValueToSearch => 'Aramak için kimyasal kayma girin';

  @override
  String get language => 'Dil';

  @override
  String get systemLanguage => 'Cihaz dili';

  @override
  String get theme => 'Tema';

  @override
  String get appearance => 'Görünüm';

  @override
  String get modeSystem => 'Sistem';

  @override
  String get modeLight => 'Açık';

  @override
  String get modeDark => 'Koyu';

  @override
  String get darkOnlyTheme => 'Bu tema her zaman koyudur';

  @override
  String get references => 'Kaynaklar';

  @override
  String get about => 'Hakkında';

  @override
  String get aboutText =>
      'Döteryumlu NMR çözücüleri ve yaygın eser safsızlıkların kimyasal kaymaları için hızlı başvuru. Tamamen çevrimdışı çalışır.';

  @override
  String get themeClassic => 'Klasik (kırmızı · mavi · siyah)';

  @override
  String get themeMidnight => 'Gece';

  @override
  String get themeCrimson => 'Kızıl';

  @override
  String get themeOcean => 'Okyanus';

  @override
  String get themeEmerald => 'Zümrüt';

  @override
  String get themeGraphite => 'Grafit';

  @override
  String get copied => 'Kopyalandı';

  @override
  String toleranceLabel(String value) {
    return 'Tolerans: ±$value ppm';
  }

  @override
  String matchedSignals(int matched, int total) {
    return '$total sinyalden $matched tanesi eşleşti';
  }

  @override
  String signalsIn(String solvent) {
    return '$solvent içindeki sinyaller';
  }

  @override
  String deltaPpm(String value) {
    return 'Δ $value ppm';
  }

  @override
  String impurityCount(int count) {
    return '$count safsızlık';
  }

  @override
  String get properties => 'Fiziksel özellikler';

  @override
  String get density => 'Yoğunluk (20 °C)';

  @override
  String get dielectric => 'Dielektrik sabiti';

  @override
  String get molecularWeight => 'Molekül ağırlığı';

  @override
  String get mpBpNote =>
      'Erime ve kaynama noktaları döteryumsuz bileşiğe aittir (D₂O hariç).';

  @override
  String get storage => 'Saklama';

  @override
  String get storageRt => 'Oda sıcaklığında, ışık ve nemden uzak saklayın.';

  @override
  String get storageRt1y =>
      'Oda sıcaklığında, ışık ve nemden uzak saklayın. Açılmamış şişe 1 yıl kararlıdır; sonrasında saflığı yeniden kontrol edilmelidir.';

  @override
  String get storageFridge6m =>
      'Buzdolabında (−5 ile 5 °C), ışık ve nemden uzak saklayın. Açılmamış şişe 6 ay kararlıdır; sonrasında saflığı yeniden kontrol edilmelidir.';

  @override
  String get hodTemperature => 'Sıcaklığa göre HDO kayması';

  @override
  String get hodTemperatureNote =>
      'Gottlieb 1997, denklem 1. Sodyum 3-(trimetilsilil)propansülfonata göre.';

  @override
  String get chem21Recommended => 'CHEM21: önerilen';

  @override
  String get chem21Problematic => 'CHEM21: sorunlu';

  @override
  String get chem21Hint =>
      'CHEM21 çözücü seçim rehberindeki derecesi (Babij 2016\'ya göre).';

  @override
  String get note => 'Not';

  @override
  String get hodOnChart => 'HOD (CIL tablosu)';

  @override
  String get sources => 'Kaynaklar';

  @override
  String residualFrom(String source) {
    return '$source verisi';
  }

  @override
  String hodAt(String temp, String shift) {
    return '$temp °C\'de δ(HDO): $shift ppm';
  }
}
