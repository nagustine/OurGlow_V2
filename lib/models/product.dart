import 'enums.dart';

class Product {
  final String id;
  final String nama;
  final KategoriProduk kategori;
  final List<String> bahan;
  final WaktuPakai waktuPakai;
  final String? fotoUrl;
  final DateTime ditambahkanPada;

  const Product({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.bahan,
    this.waktuPakai = WaktuPakai.pagi,
    this.fotoUrl,
    required this.ditambahkanPada,
  });

  factory Product.fromJson(Map<String, dynamic> json, {String? id}) {
    return Product(
      id: id ?? json['id'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      kategori: _parseKategori(json['kategori'] as String?),
      bahan: List<String>.from(json['bahan'] as List? ?? const []),
      waktuPakai: _parseWaktu(json['waktuPakai'] as String?),
      fotoUrl: json['fotoUrl'] as String?,
      ditambahkanPada: json['ditambahkanPada'] is String
          ? DateTime.parse(json['ditambahkanPada'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'kategori': kategori.name,
        'bahan': bahan,
        'waktuPakai': waktuPakai.name,
        if (fotoUrl != null) 'fotoUrl': fotoUrl,
        'ditambahkanPada': ditambahkanPada.toIso8601String(),
      };

  static KategoriProduk _parseKategori(String? raw) {
    if (raw == null) return KategoriProduk.lainnya;
    for (final k in KategoriProduk.values) {
      if (k.name.toLowerCase() == raw.toLowerCase()) return k;
    }
    return KategoriProduk.lainnya;
  }

  static WaktuPakai _parseWaktu(String? raw) {
    if (raw == null) return WaktuPakai.pagi;
    for (final w in WaktuPakai.values) {
      if (w.name.toLowerCase() == raw.toLowerCase()) return w;
    }
    return WaktuPakai.pagi;
  }
}

class ProductConflict {
  final Product produkA;
  final Product produkB;
  final String bahanBentrokA;
  final String bahanBentrokB;
  final String alasan;

  const ProductConflict({
    required this.produkA,
    required this.produkB,
    required this.bahanBentrokA,
    required this.bahanBentrokB,
    required this.alasan,
  });
}