import '../models/enums.dart';
import '../models/product.dart';
import '../theme/theme.dart';

final List<Product> mockProducts = [
  Product(
    id: 'p1',
    nama: 'Gentle Cleanser',
    kategori: KategoriProduk.cleanser,
    bahan: [],
    waktuPakai: WaktuPakai.pagiDanMalam,
    fotoUrl: AppAssets.produkCleanser,
    ditambahkanPada: DateTime(2026, 1, 10),
  ),
  Product(
    id: 'p2',
    nama: 'Toner',
    kategori: KategoriProduk.toner,
    bahan: [],
    waktuPakai: WaktuPakai.pagiDanMalam,
    fotoUrl: AppAssets.produkTonerBha,
    ditambahkanPada: DateTime(2026, 1, 11),
  ),
  Product(
    id: 'p3',
    nama: 'Serum',
    kategori: KategoriProduk.serum,
    bahan: [],
    waktuPakai: WaktuPakai.pagi,
    fotoUrl: AppAssets.produkSerumVitC,
    ditambahkanPada: DateTime(2026, 1, 12),
  ),
  Product(
    id: 'p4',
    nama: 'Moisturizer',
    kategori: KategoriProduk.moisturizer,
    bahan: [],
    waktuPakai: WaktuPakai.pagiDanMalam,
    fotoUrl: AppAssets.produkMoisturizer,
    ditambahkanPada: DateTime(2026, 1, 20),
  ),
  Product(
    id: 'p5',
    nama: 'Sunscreen',
    kategori: KategoriProduk.sunscreen,
    bahan: [],
    waktuPakai: WaktuPakai.pagi,
    fotoUrl: AppAssets.produkSunscreen,
    ditambahkanPada: DateTime(2026, 1, 22),
  ),
  Product(
    id: 'p6',
    nama: 'Exfoliator',
    kategori: KategoriProduk.exfoliator,
    bahan: [],
    waktuPakai: WaktuPakai.malam,
    fotoUrl: AppAssets.produkTonerBha,
    ditambahkanPada: DateTime(2026, 1, 25),
  ),
  Product(
    id: 'p7',
    nama: 'Masker',
    kategori: KategoriProduk.masker,
    bahan: [],
    waktuPakai: WaktuPakai.malam,
    fotoUrl: AppAssets.produkMoisturizer,
    ditambahkanPada: DateTime(2026, 1, 26),
  ),
];