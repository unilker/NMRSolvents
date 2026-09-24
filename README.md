# NMR Solvents / NMR Çözücüler

Döteryumlu NMR çözücüleri ve yaygın eser safsızlıkların kimyasal kaymaları için
Android ve iOS uygulaması. Tamamen çevrimdışı çalışır, Türkçe ve İngilizce destekler.

**Geliştirici:** Dr. İlker ÜN

*A Flutter app for Android and iOS: offline reference for deuterated NMR solvents
and the ¹H/¹³C chemical shifts of common trace impurities. Turkish and English UI.*

## Özellikler

| Sekme | İçerik |
|---|---|
| **Çözücüler** | Kalıntı ¹H/¹³C pikleri (kaynağa göre, J değerleriyle), su/HOD piki, fiziksel özellikler, saklama koşulları, o çözücüdeki safsızlıklar. D₂O için sıcaklığa göre HDO kayması hesaplayıcısı. *CHEM21 rehberi* görünümü: 75 çözücünün güvenlik/sağlık/çevre puanları, sıralaması (önerilen → çok tehlikeli), aileye göre gruplu ve filtrelenebilir; puanlamanın nasıl yapıldığı |
| **Safsızlıklar** | Ad (TR/EN), kısaltma (EtOAc, DCM…) veya formülle arama, çözücüye göre filtre, CHEM21 yeşil kimya derecesi, sinyal başına kaynak |
| **Pik ara** | *Tek pik*: spektrumda gördüğünüz pik için üç adım: ① çözücü, ② kimyasal kayma (ppm, ± tolerans), ③ yarılma (singlet, dublet, triplet…). Tam eşleşenler önce, uyumlu yarılmalar (ör. triplet için td/dt veya içinde triplet gizlenebilecek multiplet) sonra listelenir; tekil pik gibi uyumsuz olanlar elenir. Çözücünün kendi pikleri de aranır. Sonuç yoksa en yakın adaylar, yalnızca uyumlu sonuç varsa yakındaki tam eşleşmeler gösterilir.<br>*Çoklu pik*: her pik için ayrı satırda ppm ve yarılma (isteğe bağlı). "2,05 s; 4,12 q; 1,26 t" gibi yapıştırılan bir liste satırlara otomatik bölünür. Yarılması uyumsuz pik o sinyale eşlenmez; safsızlıklar eşleşen sinyal sayısına, yakınlığa ve yarılma uyumuna göre puanlanır. |
| **Bilgi** | Geliştirici, uygulama hakkında, özellikler, veri içeriği ve hazırlanışı, önemli not, numaralı kaynakça |
| **Ayarlar** | Dil (cihaz/Türkçe/English), 6 renk teması, açık/koyu/sistem görünümü |

- ¹H verileri mavi, ¹³C verileri kırmızı gösterilir (tema değişse de anlamı korunur).
- Arama Türkçe karakterlere duyarsızdır: `diklorometan`, `DİKLOROMETAN`, `DCM`, `CH2Cl2` aynı sonucu verir.
- Pik girişi hem `2.05, 4.12` hem `2,05 4,12` biçimini kabul eder.

## Veri ve kaynaklar

| Kaynak | İçerik |
|---|---|
| Fulmer ve ark., *Organometallics* **2010**, 29, 2176 | 12 döteryumlu çözücüde 45 safsızlık, ¹H ve ¹³C |
| Gottlieb, Kotlyar, Nudelman, *J. Org. Chem.* **1997**, 62, 7512 | Fulmer'de olmayan bileşikler (MTBE, BHT, DMAc, DMSO, MEK), D₂O'da tuzlar, HDO–sıcaklık denklemi |
| Babij ve ark., *Org. Process Res. Dev.* **2016**, 20, 661 | Endüstride tercih edilen 48 çözücü, 6 döteryumlu çözücü (CHEM21 işaretleri yerine özgün rehber kullanılır) |
| Prat ve ark., *Green Chem.* **2016**, 18, 288 | CHEM21 çözücü seçim rehberi: Tablo 7 (53 klasik) ve Tablo 8 (22 yeni nesil çözücü) puanları ve sıralamaları, puanlama kuralları |
| Cambridge Isotope Laboratories, *NMR Solvent Data Chart* | 19 döteryumlu çözücünün kalıntı pikleri, J(H,D)/J(C,D), HOD, yoğunluk, e.n./k.n., dielektrik sabiti, saklama |

Toplam: **20 çözücü, 86 safsızlık, 3245 sinyal.** Uygulamadaki her değer, geldiği makaleyle birlikte gösterilir.

**Birleştirme kuralı.** Aynı bileşik aynı çözücüde birden fazla makalede varsa öncelik
**Fulmer 2010 > Gottlieb 1997 > Babij 2016** şeklindedir. Fulmer, Gottlieb'in verilerini
yeniden ölçüp düzeltmiştir. Babij ise daha önce yayımlanmış çözücüler için Gottlieb ile
Fulmer'in verilerini kullanır. Sonraki kaynaklar yalnızca önceki kaynaklarda eksik olan
çözücüleri ve bileşikleri tamamlar. Kalıntı çözücü piklerinde Fulmer esastır; CIL
değerleri ikinci bir set olarak ayrıca gösterilir.

**Aktarım ve doğrulama** (`tool/`):

- `extract_fulmer.py`, `extract_gottlieb.py`: PDF metin katmanından tabloları kelime
  koordinatlarıyla yeniden kurar. Çıktılar `tool/sources/*.json` dosyalarına yazılır ve
  basılı sayfayla karşılaştırılmıştır.
- `sources/babij2016.py`: Babij tabloları PDF'de resim olarak gömülü olduğu için elle
  aktarılmıştır. `check_babij.py`, bu aktarımı bağımsız bir Tesseract OCR okumasıyla hücre
  hücre karşılaştırır. Uyuşmayan hücrelerin hepsi büyütülmüş görüntüde kontrol
  edilmiştir.
- `sources/cil_chart.py`: CIL tablosunun aktarımı.
- `sources/chem21_2016.py`: CHEM21 tablolarının aktarımı (resim). `check_chem21.py`, her
  satırın sağlık/çevre puanlarını ve varsayılan sıralamasını makalenin kendi kurallarıyla
  (Tablo 4–6) yeniden hesaplar; CI'de çalışır. Tek istisna DME'nin basılı sağlık puanıdır
  (10; kural 9 verir).
- `build_data.py`: kaynakları birleştirip `assets/data/*.json` dosyalarını üretir.
  CI, bu dosyaların kaynaklarla güncel olduğunu denetler.

Makalelerdeki bilinen baskı hataları: Fulmer Tablo 2'de asetonun TFE-d₃ sütununda CO ve
CH₃ değerleri yer değiştirmiştir; uygulamada düzeltilmiş ve not düşülmüştür. Babij
Tablo 2'de MEK CH₂**CH₃** değeri CD₃CN için 7.14 basılmıştır; Gottlieb'in 8.14 değeri
öncelikli olduğu için bu değer kullanılmaz.

Yeni bir makale eklemek için: tabloyu `tool/sources/` altına aktarın, bileşik adlarını
`build_data.py` içindeki `SOURCE_NAMES` ve `IMPURITIES` tablolarına ekleyin, ardından
`python3 tool/build_data.py` komutunu çalıştırın.

## Geliştirme

```bash
flutter pub get
flutter test
flutter run            # bağlı cihaz veya emülatörde
flutter build apk      # Android
flutter build ios      # iOS (macOS + Xcode gerekir)
```

Kod yapısı:

```
lib/
  models/      veri modelleri
  data/        JSON yükleme (repository) ve arama algoritmaları (search)
  theme/       renk temaları
  settings/    kullanıcı tercihleri (tema, dil) – cihazda saklanır
  screens/     ekranlar
  widgets/     ortak bileşenler
  l10n/        app_en.arb, app_tr.arb (çeviriler)
```

Her push'ta GitHub Actions testleri çalıştırır, Android APK'sı üretir (Actions →
*nmr-solvents-apk* artifact) ve iOS derlemesini doğrular.

## Uygulama simgesi

Mavi zemin üzerinde beyaz NMR sinyalleri; büyüteç, kırmızı safsızlık pikini büyütür.
Kaynak `tool/icon/make_icon.py` (SVG üretir) ve `tool/icon/render.js` (PNG'ye çevirir)
dosyalarındadır. Değiştirdikten sonra:

```bash
python3 tool/icon/make_icon.py
node tool/icon/render.js          # playwright-core + Chromium gerekir
dart run flutter_launcher_icons   # Android (uyarlanabilir dahil) ve iOS boyutları
git checkout ios/Runner.xcodeproj/project.pbxproj   # aracın ilgisiz bir Xcode ayarını değiştirmesini geri al
```

## Kaynaklar

- H. E. Gottlieb, V. Kotlyar, A. Nudelman, *J. Org. Chem.* **1997**, 62, 7512. doi:10.1021/jo971176v
- G. R. Fulmer et al., *Organometallics* **2010**, 29, 2176. doi:10.1021/om100106e
- N. R. Babij et al., *Org. Process Res. Dev.* **2016**, 20, 661. doi:10.1021/acs.oprd.5b00417
