import '../models/enums.dart';
import '../models/product.dart';
import '../theme/theme.dart';

final List<Product> mockProducts = [
  Product(
    id: 'p1',
    nama: 'Gentle Cleanser',
    kategori: KategoriProduk.cleanser,
    bahan: ['glycerin', 'centella', 'panthenol'],
    waktuPakai: WaktuPakai.pagiDanMalam,
    fotoUrl: AppAssets.produkCleanser,
    ditambahkanPada: DateTime(2026, 1, 10),
  ),
  Product(
    id: 'p2',
    nama: 'Glow Serum Vitamin C',
    kategori: KategoriProduk.serum,
    bahan: ['vitamin_c', 'hyaluronic_acid', 'niacinamide'],
    waktuPakai: WaktuPakai.pagi,
    fotoUrl: AppAssets.produkSerumVitC,
    ditambahkanPada: DateTime(2026, 1, 12),
  ),
  Product(
    id: 'p3',
    nama: 'Retinol Night Serum',
    kategori: KategoriProduk.serum,
    bahan: ['retinol', 'peptide', 'ceramide'],
    waktuPakai: WaktuPakai.malam,
    fotoUrl: AppAssets.produkRetinol,
    ditambahkanPada: DateTime(2026, 1, 15),
  ),
  Product(
    id: 'p4',
    nama: 'BHA Exfoliating Toner',
    kategori: KategoriProduk.toner,
    bahan: ['bha', 'panthenol', 'centella'],
    waktuPakai: WaktuPakai.malam,
    fotoUrl: AppAssets.produkTonerBha,
    ditambahkanPada: DateTime(2026, 1, 18),
  ),
  Product(
    id: 'p5',
    nama: 'Moisturizer Ceramide',
    kategori: KategoriProduk.moisturizer,
    bahan: ['ceramide', 'hyaluronic_acid', 'glycerin'],
    waktuPakai: WaktuPakai.pagiDanMalam,
    fotoUrl: AppAssets.produkMoisturizer,
    ditambahkanPada: DateTime(2026, 1, 20),
  ),
  Product(
    id: 'p6',
    nama: 'Sunscreen SPF 50',
    kategori: KategoriProduk.sunscreen,
    bahan: ['zinc_oxide', 'titanium_dioxide', 'glycerin'],
    waktuPakai: WaktuPakai.pagi,
    fotoUrl: AppAssets.produkSunscreen,
    ditambahkanPada: DateTime(2026, 1, 22),
  ),
];