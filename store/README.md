# Mağaza yayını / Store release

Google Play ve App Store için gereken metinler, görseller ve form cevapları.

| Klasör / dosya | İçerik |
|---|---|
| `listing/tr.md`, `listing/en.md` | Ad, kısa açıklama, alt başlık, tanıtım metni, anahtar kelimeler, açıklama (karakter sınırları CI'de kontrol edilir) |
| `graphics/play-icon-512.png` | Play simgesi (512×512) |
| `graphics/play-feature-{tr,en}.png` | Play tanıtım görseli (1024×500) |
| `graphics/screenshots/play/{tr,en}/` | Play telefon ekran görüntüleri (1080×1920, 7 adet) |
| `graphics/screenshots/apple/{tr,en}/` | App Store iPhone 6.9" ekran görüntüleri (1320×2868, 7 adet) |
| `web/privacy.html` | Gizlilik politikası sayfası (`PRIVACY.md`'den üretilir); kimyager.net'e yüklenir |

## Kimlikler

- Android paket adı ve iOS bundle ID: `net.kimyager.nmrimpurities` (yayından sonra değiştirilemez)
- Android yükleme anahtarı SHA-256: `7C:47:69:AC:CA:05:98:D7:66:1E:19:23:C0:8D:EE:A8:98:FC:59:55:66:6E:E2:7B:6A:9B:75:7A:2C:15:03:27`
- iOS: yalnızca iPhone (`TARGETED_DEVICE_FAMILY = 1`); iPad sonradan eklenebilir, eklendikten sonra kaldırılamaz.

## Adresler

- Gizlilik politikası: `store/web/privacy.html` dosyasını kimyager.net'e yükleyin, ör. `https://kimyager.net/nmrimpurities/privacy.html`
  (hazır olana kadar: https://github.com/unilker/NMRSolvents/blob/main/PRIVACY.md)
- Destek / web sitesi: https://kimyager.net (veya https://github.com/unilker/NMRSolvents/issues)
- Telif (App Store): `2026 Dr. İlker ÜN`

## Form cevapları

| Soru | Cevap |
|---|---|
| Fiyat | Ücretsiz; uygulama içi satın alma yok |
| Reklam | Yok |
| Kategori | Play: Eğitim · App Store: Eğitim (birincil), Başvuru / Reference (ikincil) |
| Hedef kitle (Play) | 18 yaş ve üzeri; çocuklara yönelik değil |
| İçerik derecelendirmesi | Şiddet, cinsellik, kumar vb. yok → Herkes / 4+ |
| Veri güvenliği (Play) | Veri toplanmıyor, paylaşılmıyor |
| Uygulama gizliliği (Apple) | Data Not Collected |
| Şifreleme (Apple) | Muaf; `ITSAppUsesNonExemptEncryption = false` Info.plist'te |
| Hesap / giriş | Yok (inceleme için demo hesap gerekmez) |
| Haber uygulaması, sağlık, finans vb. | Hayır |

Ekran görüntüleri uygulamanın web derlemesinden, örnek kayıtlarla alınmıştır (TR ve EN).
