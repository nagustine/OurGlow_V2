import 'base_model.dart';
import 'enums.dart';

class RoutineProduct extends BaseModel {
  final String _id;
  final String _nama;
  final KategoriProduk _kategori;
  final WaktuPakai _waktuPakai;
  final int _urutan;
  final List<String> _bahan;

  const RoutineProduct({
    required String id,
    required String nama,
    required KategoriProduk kategori,
    required WaktuPakai waktuPakai,
    required int urutan,
    List<String> bahan = const [],
  })  : _id = id,
        _nama = nama,
        _kategori = kategori,
        _waktuPakai = waktuPakai,
        _urutan = urutan,
        _bahan = bahan;

  factory RoutineProduct.fromJson(Map<String, dynamic> json, {String? id}) {
    return RoutineProduct(
      id: id ?? json['id'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      kategori: _parseKategori(json['kategori'] as String?),
      waktuPakai: _parseWaktu(json['waktuPakai'] as String?),
      urutan: (json['urutan'] as num?)?.toInt() ?? 0,
      bahan: List<String>.from(json['bahan'] as List? ?? const []),
    );
  }

  String get id => _id;
  String get nama => _nama;
  KategoriProduk get kategori => _kategori;
  WaktuPakai get waktuPakai => _waktuPakai;
  int get urutan => _urutan;
  List<String> get bahan => List.unmodifiable(_bahan);

  @override
  String get identifier => _id;

  @override
  Map<String, dynamic> toJson() => {
        'id': _id,
        'nama': _nama,
        'kategori': _kategori.name,
        'waktuPakai': _waktuPakai.name,
        'urutan': _urutan,
        'bahan': _bahan,
      };

  RoutineProduct copyWith({
    String? id,
    String? nama,
    KategoriProduk? kategori,
    WaktuPakai? waktuPakai,
    int? urutan,
    List<String>? bahan,
  }) {
    return RoutineProduct(
      id: id ?? _id,
      nama: nama ?? _nama,
      kategori: kategori ?? _kategori,
      waktuPakai: waktuPakai ?? _waktuPakai,
      urutan: urutan ?? _urutan,
      bahan: bahan ?? _bahan,
    );
  }

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