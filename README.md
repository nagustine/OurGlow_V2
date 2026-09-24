# OurGlow — Skincare Checker

Aplikasi Flutter untuk memindai komposisi produk skincare, memeriksa kombinasi bahan yang aman, mengatur rutinitas pemakaian, dan mencatat kondisi kulit harian.

> **Tagline:** Scan Komposisi, Pilih yang Tepat Untuk Kulitmu, Pancarkan Glowing


## Fitur
- 🔍 **Scan Produk** — Deteksi bahan skincare dari teks komposisi (rule-based, bukan AI)
- ⚠️ **Conflict Checker** — Cek kombinasi bahan yang aman / bentrok berdasarkan database
- 📋 **Routine Checker** — Kelola rutinitas produk harian + skor kelengkapan
- 📔 **Skin Diary** — Catat kondisi kulit harian + korelasi dengan produk
- 📱 **Responsive** — Layout adaptif untuk mobile, tablet, dan desktop

## Tech Stack
| Layer | Teknologi |
|---|---|
| Framework | Flutter 3.x (target Web) |
| Bahasa | Dart |
| State | StatefulWidget + `ChangeNotifier` (native) |
| Backend | Firebase Auth + Firestore + Storage *(rencana)* |
| Font | Google Fonts (Poppins) |
| Tools | VS Code, Chrome DevTools |

## Struktur Project
lib/
├── main.dart
├── theme/ # Palet warna & style terpusat
├── models/ # Data class (Product, Ingredient, DiaryEntry, User)
├── services/ # AuthService, FirestoreService, StorageService
├── screens/
│ ├── home/ # Beranda
│ ├── scan/ # Scan Produk
│ ├── routine/ # Routine Checker + Detail Produk
│ ├── diary/ # Skin Diary + Detail
│ └── product/ # Product List (GridView) + Detail
├── widgets/ # Chip, StatusBadge, HeaderMoodCard, EmptyState
└── data/ # ingredients.json + mock_products.dart


## Design System
| Warna | Hex | Kegunaan |
|---|---|---|
| Maroon | `#8B1538` | Navbar, card utama, footer |
| Gold | `#E8B84B` | Tombol CTA, badge, border |
| Pink Muda | `#FDEDEC` | Background halaman |
| Cream | `#FFF6EF` | Card konten |


## Cara Menjalankan

```bash
# 1. Clone repo
git clone https://github.com/nagustine/OurGlow_V2.git
cd OurGlow_V2

# 2. Install dependencies
flutter pub get

# 3. Jalankan di Chrome
flutter run -d chrome