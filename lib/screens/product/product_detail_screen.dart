import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/product.dart';
import '../../models/enums.dart';
import '../../data/mock_products.dart';
import '../../widgets/status_badge.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  Color _bahanColor(String bahanId) {
    final id = bahanId.toLowerCase();
    if (id.contains('bha') ||
        id.contains('aha') ||
        id.contains('retinol') ||
        id.contains('benzoyl') ||
        id.contains('azelaic') ||
        id.contains('vitamin_c')) {
      return const Color(0xFFFFE0B2);
    }
    if (id.contains('centella') ||
        id.contains('panthenol') ||
        id.contains('ceramide') ||
        id.contains('peptide')) {
      return const Color(0xFFC8E6C9);
    }
    if (id.contains('hyaluronic') || id.contains('glycerin')) {
      return const Color(0xFFB3E5FC);
    }
    if (id.contains('niacinamide') ||
        id.contains('arbutin') ||
        id.contains('tranexamic')) {
      return const Color(0xFFE1BEE7);
    }
    if (id.contains('zinc') || id.contains('titanium')) {
      return const Color(0xFFFFF9C4);
    }
    if (id.contains('fragrance') ||
        id.contains('alcohol') ||
        id.contains('essential')) {
      return const Color(0xFFFFCDD2);
    }
    return AppColors.accent.withValues(alpha: 0.25);
  }

  String _bahanLabel(String id) {
    return id
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  List<String> _getNotes() {
    final notes = <String>[];
    for (final b in product.bahan) {
      if (b == 'bha') {
        notes.add(
            'BHA bekerja optimal dipakai malam hari. Hindari pemakaian bareng retinol di waktu yang sama.');
      } else if (b == 'retinol') {
        notes.add(
            'Retinol sebaiknya dipakai malam hari. Gunakan pelembap setelahnya untuk mengurangi iritasi.');
      } else if (b == 'vitamin_c') {
        notes.add(
            'Vitamin C paling efektif di pagi hari, selalu lanjutkan dengan sunscreen.');
      } else if (b == 'niacinamide') {
        notes.add(
            'Niacinamide aman untuk pagi & malam, cocok untuk kulit berminyak dan kusam.');
      } else if (b == 'centella') {
        notes.add(
            'Centella membantu menenangkan kulit yang sedang iritasi atau merah.');
      } else if (b == 'hyaluronic_acid') {
        notes.add(
            'Hyaluronic acid paling efektif dipakai di kulit sedikit lembap.');
      } else if (b == 'glycerin') {
        notes.add('Glycerin aman untuk semua jenis kulit, cocok pagi & malam.');
      } else if (b == 'ceramide') {
        notes.add(
            'Ceramide memperkuat skin barrier, cocok dipakai setelah eksfoliasi.');
      } else if (b == 'sunscreen' || b == 'zinc_oxide') {
        notes.add(
            'Sunscreen wajib dipakai ulang setiap 2-3 jam kalau di luar ruangan.');
      } else if (b == 'fragrance') {
        notes.add(
            'Fragrance dapat memicu iritasi pada kulit sensitif — patch test dulu.');
      }
    }
    if (notes.isEmpty) {
      notes.add('Produk ini aman dipakai pagi & malam sesuai rutinitas.');
    }
    return notes;
  }

  List<String> _getKombinasiAman() {
    final others = mockProducts.where((p) => p.id != product.id).toList();
    final aman = <String>[];
    for (final o in others) {
      if (o.waktuPakai == product.waktuPakai ||
          o.waktuPakai == WaktuPakai.pagiDanMalam ||
          product.waktuPakai == WaktuPakai.pagiDanMalam) {
        aman.add(o.nama);
      }
    }
    return aman.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _getNotes();
    final kombinasi = _getKombinasiAman();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: Image.asset(
                      product.fotoUrl ?? '',
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.spa_outlined,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    product.nama,
                    textAlign: TextAlign.center,
                    style: AppText.sectionTitle.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.kategori.name,
                    style: AppText.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Center(
              child: StatusBadge(status: StatusAman.aman, large: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Bahan Terdeteksi',
              style: AppText.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.bahan
                  .map(
                    (b) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _bahanColor(b),
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _bahanLabel(b),
                            style: AppText.badge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Waktu Pakai',
              style: AppText.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    product.waktuPakai.name,
                    style: AppText.badge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tips Pemakaian',
              style: AppText.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...notes.map(
              (n) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        n,
                        style: AppText.bodySmall.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aman Dipakai Bersama',
              style: AppText.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: AppColors.statusSafe.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppColors.statusSafe,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cocok dengan ${kombinasi.length} produk di rutinmu',
                          style: AppText.body.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...kombinasi.map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(left: 26, bottom: 6),
                      child: Text(
                        '•  $k',
                        style: AppText.bodySmall.copyWith(height: 1.4),
                      ),
                    ),
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
}