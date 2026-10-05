import '../models/diary_entry.dart';
import '../models/product.dart';
import 'mock_products.dart';

class MockDiary {
  MockDiary._();

  /// Produk rekomendasi untuk form input (dengan foto)
  static List<Product> get produkTersedia => [
        mockProducts[0], // Gentle Cleanser
        mockProducts[1], // Glow Serum Vitamin C
        mockProducts[3], // BHA Exfoliating Toner
        mockProducts[5], // Sunscreen SPF 50
      ];

  /// Riwayat diary — KOSONG (user belum pernah catat apa-apa)
  static List<DiaryEntry> get riwayat => [];
}