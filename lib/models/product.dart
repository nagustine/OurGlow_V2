import 'base_model.dart';
import 'enums.dart';
import 'enums_ext.dart';

class Product extends BaseModel {
  final String _id;
  final String _nama;
  final KategoriProduk _kategori;
  final List<String> _bahan;
  final WaktuPakai _waktuPakai;
  final String? _fotoUrl;
  final DateTime _ditambahkanPada;

  Product({
    required String id,
    required String nama,
    required KategoriProduk kategori,
    required List<String> bahan,
    WaktuPakai waktuPakai = WaktuPakai.pagi,
    String? fotoUrl,
    required DateTime ditambahkanPada,
  })  : _id = id,
        _nama = nama,
        _kategori = kategori,
        _bahan = bahan,
        _waktuPakai = waktuPakai,
        _fotoUrl = fotoUrl,
        _ditambahkanPada = ditambahkanPada;

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

  String get id => _id;
  String get nama => _nama;
  KategoriProduk get kategori => _kategori;
  List<String> get bahan => List.unmodifiable(_bahan);
  WaktuPakai get waktuPakai => _waktuPakai;
  String? get fotoUrl => _fotoUrl;
  DateTime get ditambahkanPada => _ditambahkanPada;

  String get labelKategori => _kategori.label;
  String get labelWaktuPakai => _waktuPakai.label;
  bool get isPagi => _waktuPakai.isPagi;
  bool get isMalam => _waktuPakai.isMalam;
  bool get hasFoto => _fotoUrl != null && _fotoUrl!.isNotEmpty;
  bool get hasBahan => _bahan.isNotEmpty;
  int get jumlahBahan => _bahan.length;

  String get previewBahan {
    if (_bahan.isEmpty) return 'Tidak ada bahan';
    return _bahan.take(3).map(_formatBahan).join(', ');
  }

  int get umurHari => DateTime.now().difference(_ditambahkanPada).inDays;

  @override
  String get identifier => _id;

  Product copyWith({
    String? id,
    String? nama,
    KategoriProduk? kategori,
    List<String>? bahan,
    WaktuPakai? waktuPakai,
    String? fotoUrl,
    DateTime? ditambahkanPada,
  }) {
    return Product(
      id: id ?? _id,
      nama: nama ?? _nama,
      kategori: kategori ?? _kategori,
      bahan: bahan ?? _bahan,
      waktuPakai: waktuPakai ?? _waktuPakai,
      fotoUrl: fotoUrl ?? _fotoUrl,
      ditambahkanPada: ditambahkanPada ?? _ditambahkanPada,
    );
  }

  Product tambahBahan(String bahanBaru) =>
      copyWith(bahan: [..._bahan, bahanBaru]);

  Product hapusBahan(String bahanId) => copyWith(
        bahan: _bahan
            .where((b) => b.toLowerCase() != bahanId.toLowerCase())
            .toList(),
      );

  bool mengandungBahan(String bahanId) =>
      _bahan.any((b) => b.toLowerCase() == bahanId.toLowerCase());

  @override
  Map<String, dynamic> toJson() => {
        'id': _id,
        'nama': _nama,
        'kategori': _kategori.name,
        'bahan': _bahan,
        'waktuPakai': _waktuPakai.name,
        if (_fotoUrl != null) 'fotoUrl': _fotoUrl,
        'ditambahkanPada': _ditambahkanPada.toIso8601String(),
      };

  String _formatBahan(String id) => id
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

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

  @override
  String toString() =>
      'Product(id: $_id, nama: $_nama, kategori: ${_kategori.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}