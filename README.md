# OurGlow — Skincare Checker

Aplikasi Flutter berbasis web untuk memindai komposisi produk skincare, memeriksa kombinasi bahan, mengatur rutinitas, dan mencatat kondisi kulit harian.

**Repository:** https://github.com/nagustine/OurGlow_V2

---

## Deskripsi

OurGlow adalah aplikasi skincare checker berbasis *rule-based* (bukan AI). Pengguna dapat memindai komposisi produk, memeriksa potensi konflik antar bahan, menyusun rutinitas pagi dan malam, serta mencatat kondisi kulit harian. Seluruh keputusan analisis diambil dari aturan yang tersimpan di `ingredients.json`, sehingga hasil dapat ditelusuri dan dipertanggungjawabkan.

---

## Fitur

- Scan Produk — deteksi bahan dari teks komposisi
- Conflict Checker — cek kombinasi bahan aman atau bentrok
- Routine Checker — kelola rutinitas pagi/malam dengan skor kecocokan
- Input Bahan Manual — tambah bahan sendiri jika produk tidak ada di katalog
- Skin Diary — catat kondisi kulit harian
- Responsive — layout adaptif untuk mobile, tablet, dan desktop

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| Framework | Flutter 3.x (Web) |
| Bahasa | Dart |
| State | StatefulWidget + ChangeNotifier |
| Backend | Firebase Auth, Firestore, Storage |
| Font | Google Fonts (Poppins) |
| Tools | VS Code, Chrome DevTools, GitHub |

---

## Struktur Project
lib/
├── main.dart
├── theme/ Palet warna dan style terpusat
├── models/ Product, Ingredient, RoutineProduct, DiaryEntry, User
├── services/ AuthService, FirestoreService, RoutineService, RoutineAnalyzer
├── screens/
│ ├── auth/ Login dan Register
│ ├── home/ Beranda
│ ├── scan/ Scan Produk
│ ├── routine/ Routine Checker, Pilih Produk, Detail Produk
│ ├── diary/ Skin Diary dan Detail
│ └── product/ Product List dan Detail
├── widgets/ Chip, StatusBadge, HeaderMoodCard, EmptyState
└── data/ ingredients.json, mock_products.dart


---

## Design System

| Warna | Hex | Kegunaan |
|---|---|---|
| Maroon | `#8B1538` | Navbar, card utama, footer |
| Gold | `#E8B84B` | Tombol CTA, badge, border |
| Pink Muda | `#FDEDEC` | Background halaman |
| Cream | `#FFF6EF` | Card konten |

---

## Cara Menjalankan

```bash
git clone https://github.com/nagustine/OurGlow_V2.git
cd OurGlow_V2
flutter pub get
flutter run -d chrome