# NMR Solvents / NMR Çözücüler

Döteryumlu NMR çözücüleri ve yaygın eser safsızlıkların kimyasal kaymaları için
Android ve iOS uygulaması. Tamamen çevrimdışı çalışır, Türkçe ve İngilizce destekler.

*A Flutter app for Android and iOS: offline reference for deuterated NMR solvents
and the ¹H/¹³C chemical shifts of common trace impurities. Turkish and English UI.*

## Özellikler

| Sekme | İçerik |
|---|---|
| **Çözücüler** | Kalıntı ¹H/¹³C pikleri, multiplisite, su piki, erime/kaynama noktası, o çözücüdeki safsızlıklar |
| **Safsızlıklar** | Ad (TR/EN), kısaltma (EtOAc, DCM…) veya formülle arama, çözücüye göre filtre |
| **Pik ara** | *Tek pik*: δ ± tolerans ve multiplisiteye göre ters arama (çözücünün kendi pikleri dahil)<br>*Çoklu pik*: birden fazla gözlenen piki girip en olası safsızlıkları puanlı sıralama |
| **Ayarlar** | Dil (cihaz/Türkçe/English), 6 renk teması, açık/koyu/sistem görünümü, kaynaklar |

- ¹H verileri mavi, ¹³C verileri kırmızı gösterilir (tema değişse de anlamı korunur).
- Arama Türkçe karakterlere duyarsızdır: `diklorometan`, `DİKLOROMETAN`, `DCM`, `CH2Cl2` aynı sonucu verir.
- Pik girişi hem `2.05, 4.12` hem `2,05 4,12` biçimini kabul eder.

## Veri

Tüm veriler `assets/data/` altında düz JSON dosyalarıdır; yeni veri eklemek için kod
değiştirmek gerekmez.

- `references.json` — makaleler (DOI ile)
- `solvents.json` — döteryumlu çözücüler
- `impurities.json` — safsızlıklar ve her çözücüdeki sinyalleri

Örnek bir safsızlık kaydı:

```json
{
  "id": "ethyl_acetate",
  "name": { "en": "Ethyl acetate", "tr": "Etil asetat" },
  "formula": "CH3COOCH2CH3",
  "aliases": ["EtOAc", "AcOEt"],
  "signals": [
    { "solvent": "cdcl3", "nucleus": "1H",  "shift": 2.05,  "mult": "s", "assignment": "CH3CO" },
    { "solvent": "cdcl3", "nucleus": "13C", "shift": 171.36, "mult": "s", "assignment": "CO" }
  ],
  "ref": "gottlieb1997",
  "verified": false
}
```

> **Not:** Mevcut veri seti bir başlangıç setidir ve `"verified": false` olarak
> işaretlidir; uygulamada "Doğrulanmadı" etiketiyle görünür. Değerler kaynak
> makalelerle karşılaştırıldıkça `true` yapılacaktır.

`test/search_test.dart` her çözücü/kaynak kimliğinin geçerli olduğunu ve her kaydın
Türkçe ve İngilizce adı bulunduğunu denetler.

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

## Kaynaklar

- H. E. Gottlieb, V. Kotlyar, A. Nudelman, *J. Org. Chem.* **1997**, 62, 7512. doi:10.1021/jo971176v
- G. R. Fulmer et al., *Organometallics* **2010**, 29, 2176. doi:10.1021/om100106e
- N. R. Babij et al., *Org. Process Res. Dev.* **2016**, 20, 661. doi:10.1021/acs.oprd.5b00417
