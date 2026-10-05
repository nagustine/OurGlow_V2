import 'base_model.dart';
import 'enums.dart';
import 'product.dart';

class DiaryEntry extends BaseModel {
  final String _id;
  final DateTime _tanggal;
  final List<KondisiKulit> _kondisiKulit;
  final String _catatan;
  final String? _fotoUrl;
  final List<Product> _produkDipakai;
  final StatusAman _statusRutin;

  DiaryEntry({
    required String id,
    required DateTime tanggal,
    required List<KondisiKulit> kondisiKulit,
    String catatan = '',
    String? fotoUrl,
    List<Product> produkDipakai = const [],
    StatusAman statusRutin = StatusAman.aman,
  })  : _id = id,
        _tanggal = tanggal,
        _kondisiKulit = kondisiKulit,
        _catatan = catatan,
        _fotoUrl = fotoUrl,
        _produkDipakai = produkDipakai,
        _statusRutin = statusRutin;

  factory DiaryEntry.fromJson(Map<String, dynamic> json, {String? id}) {
    final tanggalRaw = json['tanggal'];
    final tanggal = tanggalRaw is String
        ? DateTime.parse(tanggalRaw)
        : DateTime.now();

    final kondisiRaw = json['kondisiKulit'] as List? ?? const [];
    final kondisiList =
        kondisiRaw.map((e) => _parseKondisi(e as String)).toList();

    final produkRaw = json['produkDipakai'] as List? ?? const [];
    final produkList = produkRaw
        .whereType<Map>()
        .map((p) => Product.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    return DiaryEntry(
      id: id ?? json['id'] as String? ?? '',
      tanggal: tanggal,
      kondisiKulit: kondisiList,
      catatan: json['catatan'] as String? ?? '',
      fotoUrl: json['fotoUrl'] as String?,
      produkDipakai: produkList,
      statusRutin: _parseStatus(json['statusRutin'] as String?),
    );
  }

  String get id => _id;
  DateTime get tanggal => _tanggal;
  List<KondisiKulit> get kondisiKulit => List.unmodifiable(_kondisiKulit);
  String get catatan => _catatan;
  String? get fotoUrl => _fotoUrl;
  List<Product> get produkDipakai => List.unmodifiable(_produkDipakai);
  StatusAman get statusRutin => _statusRutin;

  bool get hasFoto => _fotoUrl != null && _fotoUrl!.isNotEmpty;
  bool get hasCatatan => _catatan.trim().isNotEmpty;
  int get jumlahProduk => _produkDipakai.length;
  int get jumlahKondisi => _kondisiKulit.length;
  bool get adaIritasi => _kondisiKulit.contains(KondisiKulit.iritasi);
  bool get adaJerawat => _kondisiKulit.contains(KondisiKulit.berjerawat);
  bool get kulitSehat => _kondisiKulit.contains(KondisiKulit.glowing);

  String get tanggalLabel {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${_tanggal.day} ${bulan[_tanggal.month - 1]} ${_tanggal.year}';
  }

  String get hariLabel {
    const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return hari[_tanggal.weekday - 1];
  }

  @override
  String get identifier => _id;

  @override
  Map<String, dynamic> toJson() => {
        'id': _id,
        'tanggal': _tanggal.toIso8601String(),
        'kondisiKulit': _kondisiKulit.map((e) => e.name).toList(),
        'catatan': _catatan,
        if (_fotoUrl != null) 'fotoUrl': _fotoUrl,
        'produkDipakai': _produkDipakai.map((p) => p.toJson()).toList(),
        'statusRutin': _statusRutin.name,
      };

  DiaryEntry copyWith({
    String? id,
    DateTime? tanggal,
    List<KondisiKulit>? kondisiKulit,
    String? catatan,
    String? fotoUrl,
    List<Product>? produkDipakai,
    StatusAman? statusRutin,
  }) {
    return DiaryEntry(
      id: id ?? _id,
      tanggal: tanggal ?? _tanggal,
      kondisiKulit: kondisiKulit ?? _kondisiKulit,
      catatan: catatan ?? _catatan,
      fotoUrl: fotoUrl ?? _fotoUrl,
      produkDipakai: produkDipakai ?? _produkDipakai,
      statusRutin: statusRutin ?? _statusRutin,
    );
  }

  DiaryEntry tambahProduk(Product p) =>
      copyWith(produkDipakai: [..._produkDipakai, p]);

  DiaryEntry hapusProduk(String productId) => copyWith(
        produkDipakai:
            _produkDipakai.where((p) => p.id != productId).toList(),
      );

  static KondisiKulit _parseKondisi(String raw) {
    for (final k in KondisiKulit.values) {
      if (k.name.toLowerCase() == raw.toLowerCase()) return k;
    }
    return KondisiKulit.normal;
  }

  static StatusAman _parseStatus(String? raw) {
    if (raw == null) return StatusAman.aman;
    for (final s in StatusAman.values) {
      if (s.name.toLowerCase() == raw.toLowerCase()) return s;
    }
    return StatusAman.aman;
  }

  @override
  String toString() =>
      'DiaryEntry($tanggalLabel, kondisi: $jumlahKondisi, produk: $jumlahProduk)';
}