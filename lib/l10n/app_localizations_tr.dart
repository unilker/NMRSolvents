// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'NMR Çözücü Safsızlıkları';

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
  String get aboutText =>
      'NMR Çözücü Safsızlıkları, NMR spektrumlarında sık karşılaşılan döteryumlu çözücü sinyallerini ve eser safsızlıkları hızlıca tanımlamak için hazırlanmış bir başvuru uygulamasıdır. Veriler hakemli literatürden ve bir üreticinin çözücü tablosundan derlenmiştir. Uygulama internet bağlantısı gerektirmeden çalışır.';

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

  @override
  String get stepSolvent => 'Çözücü';

  @override
  String get stepShift => 'Kimyasal kayma';

  @override
  String get stepShifts => 'Gözlenen pikler';

  @override
  String get stepMultiplicity => 'Yarılma (çokluk)';

  @override
  String get multiplicityHint => 'Spektrumunuzda gördüğünüz yarılmayı seçin.';

  @override
  String get multS => 'singlet';

  @override
  String get multD => 'dublet';

  @override
  String get multT => 'triplet';

  @override
  String get multQ => 'kuartet';

  @override
  String get multQuint => 'kentet';

  @override
  String get multSept => 'septet';

  @override
  String get multM => 'multiplet';

  @override
  String get multDd => 'dublet dubleti';

  @override
  String get multBrS => 'geniş singlet';

  @override
  String get matchExact => 'Tam eşleşme';

  @override
  String get matchCompatible => 'Uyumlu yarılma';

  @override
  String get matchCompatibleHint =>
      'Bu sinyal multiplet ya da daha karmaşık bir yarılma olarak bildirilmiş; gördüğünüz desen bunun içinde olabilir.';

  @override
  String get matchUnknown => 'Yarılma bildirilmemiş';

  @override
  String nearestHeader(String tol) {
    return '±$tol ppm içinde sonuç yok. En yakın sinyaller:';
  }

  @override
  String resultCount(int count) {
    return '$count sonuç';
  }

  @override
  String get closeExactHeader => 'Yakındaki tam eşleşmeler (tolerans dışında):';

  @override
  String get addPeak => 'Pik ekle';

  @override
  String get removePeak => 'Piki sil';

  @override
  String get stepMultiplicityShort => 'Yarılma';

  @override
  String get peakRowsHint =>
      'Her piki ve görebiliyorsanız yarılmasını girin. \"2,05 s; 4,12 q; 1,26 t\" gibi bir listeyi de yapıştırabilirsiniz.';

  @override
  String peakLabel(int n) {
    return 'Pik $n';
  }

  @override
  String get tabInfo => 'Bilgi';

  @override
  String get developer => 'Geliştirici';

  @override
  String get aboutApp => 'Uygulama hakkında';

  @override
  String get features => 'Özellikler';

  @override
  String get feature1 =>
      'Çözücü rehberi: J değerleriyle kalıntı ¹H/¹³C pikleri, su/HOD piki, fiziksel özellikler ve saklama koşulları.';

  @override
  String get feature2 =>
      'Safsızlık tabloları: ad, kısaltma veya formülle arama; her değerin kaynağı gösterilir.';

  @override
  String get feature3 =>
      'Pik arama: spektrumunuzdaki pikin çözücüsünü, kimyasal kaymasını ve yarılmasını girerek neye ait olabileceğini bulun.';

  @override
  String get feature4 =>
      'Çoklu pik: birden fazla piki yarılmalarıyla girerek en olası safsızlıkları puanlı sıralayın.';

  @override
  String get feature5 => 'D₂O için sıcaklığa bağlı HDO kayması hesaplayıcısı.';

  @override
  String get feature6 =>
      'Türkçe ve İngilizce arayüz, altı renk teması, açık ve koyu görünüm.';

  @override
  String get dataContent => 'Veri içeriği';

  @override
  String get dataMethodText =>
      'Değerler aşağıdaki kaynakların tablolarından aktarılmış ve basılı tablolarla karşılaştırılarak doğrulanmıştır. Aynı bileşik aynı çözücüde birden fazla kaynakta yer aldığında öncelik sırası Fulmer 2010 > Gottlieb 1997 > Babij 2016\'dır; sonraki kaynaklar yalnızca eksik verileri tamamlar. Uygulama her değerin hangi kaynaktan geldiğini gösterir. Yeşil kimya puanları ve sıralamaları özgün CHEM21 rehberinden alınmıştır.';

  @override
  String get disclaimerTitle => 'Önemli not';

  @override
  String get disclaimerText =>
      'Kimyasal kaymalar derişime, sıcaklığa, pH\'a ve cihaza göre değişebilir. Bu uygulama bir başvuru aracıdır; kesin tanımlama için orijinal kaynaklara ve kendi ölçümlerinize başvurun. Tablolardaki veriler ilgili yayıncılara ve Cambridge Isotope Laboratories\'e aittir; bu uygulamanın onlarla bir bağlantısı yoktur.';

  @override
  String get referenceList => 'Kaynakça';

  @override
  String versionLabel(String version) {
    return 'Sürüm $version';
  }

  @override
  String dataStats(int solvents, int impurities, int signals) {
    return '$solvents döteryumlu çözücü · $impurities safsızlık · $signals sinyal';
  }

  @override
  String get rankRecommended => 'Önerilen';

  @override
  String get rankProblematic => 'Sorunlu';

  @override
  String get rankHazardous => 'Tehlikeli';

  @override
  String get rankHighlyHazardous => 'Çok tehlikeli';

  @override
  String get rankRecommendedDef =>
      'Proses koşullarıyla kimyasal uyumsuzluk yoksa, tarama çalışmalarında ilk denenecek çözücüler.';

  @override
  String get rankProblematicDef =>
      'Laboratuvarda ve kilolab ölçeğinde kullanılabilir; pilot tesis veya üretim ölçeğinde özel önlemler ya da yüksek enerji tüketimi gerektirir.';

  @override
  String get rankHazardousDef =>
      'Ölçek büyütmede kısıtlar çok ağırdır; proses geliştirmede bu çözücülerin ikamesi önceliklidir.';

  @override
  String get rankHighlyHazardousDef =>
      'Laboratuvarda bile kaçınılması gereken çözücüler.';

  @override
  String get greenChemistry => 'Yeşil kimya (CHEM21)';

  @override
  String get safetyScore => 'Güvenlik';

  @override
  String get healthScore => 'Sağlık';

  @override
  String get envScore => 'Çevre';

  @override
  String get flashPoint => 'Parlama noktası';

  @override
  String get worstH3 => 'En ağır sağlık ifadesi';

  @override
  String get worstH4 => 'Çevre ifadesi';

  @override
  String get hNone => 'Yok (tam REACh kaydı)';

  @override
  String get hNa => 'Veri yok (tam REACh kaydı yok)';

  @override
  String get rankingDefault => 'Puanlara göre sıralama';

  @override
  String get rankingFinal => 'CHEM21 sıralaması';

  @override
  String get rankChangedNote =>
      'CHEM21 ekibi, puanlardan çıkan sıralamayı tartışma sonrasında değiştirmiştir.';

  @override
  String get casNumber => 'CAS No.';

  @override
  String get noteSolid => '20 °C\'de katı';

  @override
  String get noteWaterSensitive => 'Suya duyarlı';

  @override
  String get nmrSolventsView => 'NMR çözücüleri';

  @override
  String get chem21GuideView => 'CHEM21 rehberi';

  @override
  String get chem21Intro =>
      'CHEM21 konsorsiyumunun ilaç endüstrisi için hazırladığı çözücü seçim rehberi. Her çözücü güvenlik, sağlık ve çevre açısından 1–10 arasında puanlanır (1 en iyi) ve dört sınıfa ayrılır.';

  @override
  String get chem21BabijNote =>
      'Babij 2016 tablosundaki CHEM21 işaretleri bazı çözücülerde bu özgün rehberden farklıdır; uygulamada özgün rehber (Prat 2016) kullanılır.';

  @override
  String get searchChem21Hint => 'Çözücü ara';

  @override
  String get howScored => 'Puanlama nasıl yapılır?';

  @override
  String get rankClasses => 'Sıralama sınıfları';

  @override
  String get scoreColors =>
      'Puanlar 1–3 yeşil, 4–6 sarı, 7–10 kırmızı gösterilir.';

  @override
  String get safetyRule =>
      'Parlama noktasına göre verilir: >60 °C → 1; 24–60 °C → 3; 0–23 °C → 4; −1 ile −20 °C → 5; −20 °C\'nin altı → 7. Otomatik tutuşma sıcaklığının 200 °C\'nin altında olması, özdirencin 10⁸ Ω·m\'nin üzerinde olması (statik elektrik birikimi) ve peroksit oluşturma (EUH019) için her biri +1 eklenir. Bozunma enerjisi 500 J/g\'nin üzerinde olanlar (ör. nitrometan) 10 alır.';

  @override
  String get healthRule =>
      'En ağır GHS/CLP tehlike ifadesine göre verilir: kanserojen, mutajen veya üreme için toksik kategori 1 (H340, H350, H360) → 9, kategori 2 (H341, H351, H361) → 6; akut toksisite H300/H310/H330 → 9, H301/H311/H331 → 6, H302/H312/H332/H336 → 2; hedef organ toksisitesi H370/H372 → 6, H334 → 4, H304/H371/H373 → 2; tahriş H314 → 7, H318 → 4, H315/H317/H319/H335 → 2. Kaynama noktası 85 °C\'nin altındaysa +1 eklenir. Tam REACh kaydı olup H3xx ifadesi olmayanlar 1, verisi eksik olanlar 5 alır.';

  @override
  String get envRule =>
      'İki puandan yüksek olanı alınır: kaynama noktası (70–139 °C → 3; 50–69 veya 140–200 °C → 5; 50 °C\'nin altı veya 200 °C\'nin üstü → 7) ve sucul tehlike ifadeleri (yok → 3; H412/H413 → 5; H400/H410/H411 → 7). Tam REACh kaydı yoksa 5; su 1; ozon tabakasına zararlı (H420) çözücüler 10 alır.';

  @override
  String get rankRule =>
      'Puanlara göre sıralama (en katı kural geçerlidir): herhangi bir puan ≥8 veya iki kırmızı puan (7–10) → tehlikeli; bir puan 7 veya iki sarı puan (4–6) → sorunlu; aksi halde önerilen. Klasik çözücülerde nihai sıralamayı CHEM21 ekibi tartışarak belirlemiştir; \"çok tehlikeli\" sınıfı yalnızca bu aşamada verilir.';

  @override
  String get showNmrData => 'NMR verileri';

  @override
  String get deuteratedForms => 'Döteryumlu NMR çözücüleri';

  @override
  String get family => 'Aile';

  @override
  String get hStatementNote =>
      'Tehlike ifadelerinin metni GHS/CLP mevzuatından alınmıştır.';

  @override
  String chem21For(String name) {
    return 'Döteryumsuz $name';
  }

  @override
  String chem21Count(int count) {
    return '$count çözücü';
  }

  @override
  String get feature7 =>
      'CHEM21 yeşil kimya rehberi: 75 çözücünün güvenlik, sağlık ve çevre puanları, sıralaması ve puanlamanın nasıl yapıldığı.';

  @override
  String get tabRecords => 'Kayıtlar';

  @override
  String get saveResults => 'Sonuçları kaydet';

  @override
  String get sampleName => 'Numune adı';

  @override
  String get sampleNameRequired => 'Numune adını girin';

  @override
  String get analysisDate => 'Analiz tarihi';

  @override
  String get noteOptional => 'Not (isteğe bağlı)';

  @override
  String get markIdentified =>
      'Spektrumda tanımladığınız safsızlıkları işaretleyin.';

  @override
  String get identifiedSection => 'Tanımlanan';

  @override
  String get otherCandidates => 'Diğer adaylar';

  @override
  String get save => 'Kaydet';

  @override
  String get recordSaved => 'Kayıt kaydedildi';

  @override
  String get view => 'Görüntüle';

  @override
  String get newRecord => 'Yeni kayıt';

  @override
  String get editRecord => 'Kaydı düzenle';

  @override
  String get recordsEmpty =>
      'Henüz kayıt yok. Pik ara\'da bir arama yapıp \"Sonuçları kaydet\"e dokunun.';

  @override
  String get searchRecordsHint => 'Numune adı veya not';

  @override
  String get deleteRecord => 'Kaydı sil';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get copyAsText => 'Metin olarak kopyala';

  @override
  String get enteredPeaks => 'Girilen pikler';

  @override
  String get searchType => 'Arama';

  @override
  String get noneIdentified => 'Tanımlandı olarak işaretlenmiş safsızlık yok.';

  @override
  String get recordHeader => 'NMR Çözücü Safsızlıkları – analiz kaydı';

  @override
  String get localOnlyNote =>
      'Kayıtlar yalnızca bu cihazda saklanır. Uygulama silinirse kayıtlar da silinir; yedek için \"Metin olarak kopyala\"yı kullanın.';

  @override
  String get tolerance => 'Tolerans';

  @override
  String get edit => 'Düzenle';

  @override
  String deleteConfirm(String name) {
    return '\"$name\" kaydı silinsin mi?';
  }

  @override
  String peakCount(int count) {
    return '$count pik';
  }

  @override
  String identifiedCount(int count) {
    return '$count tanımlandı';
  }

  @override
  String savedOn(String date) {
    return 'Kayıt tarihi: $date';
  }

  @override
  String get license => 'Lisans';

  @override
  String get licenseText =>
      'Bu uygulama özgür ve açık kaynaklı bir yazılımdır; GNU Genel Kamu Lisansı sürüm 3 (GPL-3.0) koşullarıyla dağıtılır. Ücretsizdir, reklam içermez ve hiçbir garanti verilmez. Bu lisansın koşullarına uyarak yeniden dağıtabilir ve değiştirebilirsiniz.';

  @override
  String get sourceCode => 'Kaynak kodu';

  @override
  String get packageLicenses => 'Kullanılan paketlerin lisansları';
}
