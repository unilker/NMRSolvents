# Mağaza yayını / Store release

Google Play ve App Store için gereken metinler, görseller ve form cevapları.

| Klasör / dosya | İçerik |
|---|---|
| `listing/tr.md`, `listing/en.md` | Ad, kısa açıklama, alt başlık, tanıtım metni, anahtar kelimeler, açıklama (karakter sınırları CI'de kontrol edilir) |
| `graphics/play-icon-512.png` | Play simgesi (512×512) |
| `graphics/play-feature-{tr,en}.png` | Play tanıtım görseli (1024×500) |
| `graphics/screenshots/play/{tr,en}/` | Play telefon ekran görüntüleri (1080×1920, 7 adet) |
| `graphics/screenshots/apple/{tr,en}/` | App Store iPhone 6.9" ekran görüntüleri (1320×2868, 7 adet) |

## Kimlikler

- Android paket adı ve iOS bundle ID: `net.kimyager.nmrimpurities` (yayından sonra değiştirilemez)
- Android yükleme anahtarı SHA-256: `7C:47:69:AC:CA:05:98:D7:66:1E:19:23:C0:8D:EE:A8:98:FC:59:55:66:6E:E2:7B:6A:9B:75:7A:2C:15:03:27`
- iOS: yalnızca iPhone (`TARGETED_DEVICE_FAMILY = 1`); iPad sonradan eklenebilir, eklendikten sonra kaldırılamaz.

## iOS: TestFlight ve App Store

Mac gerekmez: `.github/workflows/testflight.yml` macOS makinesinde imzalı uygulamayı derleyip
App Store Connect'e (TestFlight) yükler. Actions → TestFlight → **Run workflow** ile ya da `v1.0.0`
gibi bir etiketle çalışır; her yüklemenin yapı numarası (build) çalıştırma numarasıdır.

Gereken depo secret'ları: `IOS_DIST_CERT_P12_BASE64`, `IOS_DIST_CERT_PASSWORD`,
`IOS_PROVISIONING_PROFILE_BASE64` (Apple Distribution sertifikası ve `net.kimyager.nmrimpurities`
için App Store profili), `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
`APP_STORE_CONNECT_API_KEY` (App Store Connect API anahtarı, "App Manager" rolü, `.p8` içeriği).
Sertifika her yıl, profil sertifikayla birlikte yenilenir.

## Adresler

Tanıtım ve gizlilik sayfaları kimyager.net'te yayımlanır (depo: github.com/unilker/kimyager.net,
içerik `src/data/nmr-app.yaml`):

| | Türkçe | English |
|---|---|---|
| Gizlilik politikası | https://kimyager.net/uygulamalar/nmr-cozucu-safsizliklari/gizlilik/ | https://kimyager.net/en/apps/nmr-solvent-impurities/privacy/ |
| Destek / web sitesi | https://kimyager.net/uygulamalar/nmr-cozucu-safsizliklari/ | https://kimyager.net/en/apps/nmr-solvent-impurities/ |

- Telif (App Store): `2026 Dr. İlker ÜN`
- `PRIVACY.md` değişirse kimyager.net'teki gizlilik sayfasını da aynı içerikle güncelleyin.

## Form cevapları

| Soru | Cevap |
|---|---|
| Fiyat | Ücretsiz; uygulama içi satın alma yok |
| Reklam | Yok |
| Kategori | Play: Eğitim · App Store: Eğitim (birincil), Başvuru / Reference (ikincil) |
| Hedef kitle (Play) | 13–15, 16–17 ve 18+ (lise ve üniversite öğrencileri dahil); 13 yaş altı seçilmez (Aileler politikası) |
| İçerik derecelendirmesi | Şiddet, cinsellik, kumar vb. yok → Herkes / 4+ |
| Veri güvenliği (Play) | Veri toplanmıyor, paylaşılmıyor |
| Uygulama gizliliği (Apple) | Data Not Collected |
| Şifreleme (Apple) | Muaf; `ITSAppUsesNonExemptEncryption = false` Info.plist'te |
| Hesap / giriş | Yok (inceleme için demo hesap gerekmez) |
| Haber uygulaması, sağlık, finans vb. | Hayır |

Ekran görüntüleri uygulamanın web derlemesinden, örnek kayıtlarla alınmıştır (TR ve EN).
