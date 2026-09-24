import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tentang OurGlow')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    AppAssets.logo,
                    width: 100,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 100),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'OurGlow',
                    style: AppText.sectionTitle.copyWith(fontSize: 26),
                  ),
                  Text(
                    'Skincare Checker',
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _section(
              icon: Icons.apps,
              title: 'Tentang Aplikasi',
              paragraphs: const [
                'OurGlow dibuat karena satu masalah yang sering banget dialami: bingung apakah produk skincare yang dipakai udah aman dikombinasikan, atau malah bikin kulit iritasi tanpa disadari. Banyak orang beli produk berdasarkan review atau rekomendasi orang lain, tapi jarang cek apakah bahan-bahannya cocok dipakai bareng-bareng.',
                'Lewat OurGlow, kamu bisa:',
              ],
              bullets: const [
                'Scan komposisi produk buat tau bahan apa aja yang terkandung',
                'Cek kombinasi rutinitasmu biar tau mana yang aman dan mana yang berpotensi bentrok',
                'Catat progress kulit harian di Skin Diary, biar kamu bisa lihat sendiri pola dan perubahannya dari waktu ke waktu',
              ],
              footer:
                  'Tujuannya sederhana: bantu kamu pilih & pakai skincare dengan lebih sadar, bukan sekadar ikut tren.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _section(
              icon: Icons.psychology_outlined,
              title: 'Gimana OurGlow Menganalisis Produk?',
              paragraphs: const [
                'Biar transparan — OurGlow bukan pakai AI/machine learning. Analisis kombinasi bahan di sini berbasis rule-based, artinya sistem mencocokkan komposisi produk kamu dengan database bahan & aturan kombinasi yang sudah ditentukan berdasarkan referensi tepercaya (lihat bagian Sumber Referensi di bawah).',
                'Jadi hasil analisisnya konsisten dan bisa dipertanggungjawabkan sumbernya, meski tetap bukan pengganti konsultasi ke dokter kulit/dermatolog.',
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _section(
              icon: Icons.person_outline,
              title: 'Tentang Pembuat',
              paragraphs: const [
                'Dibuat oleh Dea Apriani Agustin sebagai bagian dari tugas mata kuliah Pemrograman Berbasis Platform (PBP).',
              ],
              footer: 'LinkedIn: Dea Apriani Agustin\nInstagram: @deeaayya',
            ),
            const SizedBox(height: AppSpacing.lg),
            _section(
              icon: Icons.library_books_outlined,
              title: 'Sumber Referensi',
              paragraphs: const [
                'Aturan kombinasi bahan yang digunakan di OurGlow disusun berdasarkan referensi dari sumber-sumber berikut:',
              ],
              bullets: const [
                'Jurnal dermatologi terkait interaksi bahan aktif skincare',
                "Paula's Choice — Ingredient Dictionary & panduan kombinasi bahan",
                'SkinCarisma — analisis komposisi produk',
              ],
              footer:
                  'Catatan: bagian ini sebaiknya diisi daftar sumber yang benar-benar dipakai untuk database ingredients.json, biar bisa disitasi valid di laporan tugas.',
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Column(
                children: [
                  Text(
                    'Versi Aplikasi',
                    style: AppText.badge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0',
                    style: AppText.sectionTitle.copyWith(
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dikembangkan sebagai tugas besar PBP, masih terus dikembangkan.',
                    textAlign: TextAlign.center,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    List<String> paragraphs = const [],
    List<String> bullets = const [],
    String? footer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppText.cardTitle.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...paragraphs.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                p,
                style: AppText.bodySmall.copyWith(height: 1.6),
              ),
            ),
          ),
          if (bullets.isNotEmpty)
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        b,
                        style: AppText.bodySmall.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (footer != null) ...[
            const SizedBox(height: 8),
            Text(
              footer,
              style: AppText.bodySmall.copyWith(
                height: 1.5,
                color: AppColors.textDark.withValues(alpha: 0.75),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}