import 'base_model.dart';
import 'enums.dart';

class DiaryEntry extends BaseModel {
  final String _id;
  final DateTime _tanggal;
  final KondisiKulit _kondisiUtama;
  final List<String> _masalah;
  final int _intensitas;
  final List<String> _areaBermasalah;
  final List<DiaryProduct> _produkDipakai;
  final String _catatan;

  DiaryEntry({
    required String id,
    required DateTime tanggal,
    KondisiKulit kondisiUtama = KondisiKulit.normal,
    List<String> masalah = const [],
    int intensitas = 50,
    List<String> areaBermasalah = const [],
    List<DiaryProduct> produkDipakai = const [],
    String catatan = '',
  })  : _id = id,
        _tanggal = tanggal,
        _kondisiUtama = kondisiUtama,
        _masalah = masalah,
        _intensitas = intensitas,
        _areaBermasalah = areaBermasalah,
        _produkDipakai = produkDipakai,
        _catatan = catatan;

  factory DiaryEntry.fromJson(Map<String, dynamic> json, {String? id}) {
    final tanggalRaw = json['tanggal'];
    final DateTime tanggal;
    if (tanggalRaw is String) {
      tanggal = DateTime.tryParse(tanggalRaw) ?? DateTime.now();
    } else if (tanggalRaw is DateTime) {
      tanggal = tanggalRaw;
    } else {
      tanggal = DateTime.now();
    }

    final produkRaw = json['produkDipakai'] as List? ?? const [];
    final produkList = produkRaw
        .whereType<Map>()
        .map((p) => DiaryProduct.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    return DiaryEntry(
      id: id ?? json['id'] as String? ?? '',
      tanggal: tanggal,
      kondisiUtama: _parseKondisi(json['kondisiUtama'] as String?),
      masalah: List<String>.from(json['masalah'] as List? ?? const []),
      intensitas: (json['intensitas'] as num?)?.toInt() ?? 50,
      areaBermasalah: List<String>.from(
        json['areaBermasalah'] as List? ?? const [],
      ),
      produkDipakai: produkList,
      catatan: json['catatan'] as String? ?? '',
    );
  }

  String get id => _id;
  DateTime get tanggal => _tanggal;
  KondisiKulit get kondisiUtama => _kondisiUtama;
  List<String> get masalah => List.unmodifiable(_masalah);
  int get intensitas => _intensitas;
  List<String> get areaBermasalah => List.unmodifiable(_areaBermasalah);
  List<DiaryProduct> get produkDipakai => List.unmodifiable(_produkDipakai);
  String get catatan => _catatan;

  bool get hasCatatan => _catatan.trim().isNotEmpty;
  int get jumlahProduk => _produkDipakai.length;
  int get jumlahMasalah => _masalah.length;

  String get tanggalLabel {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
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
        'kondisiUtama': _kondisiUtama.name,
        'masalah': _masalah,
        'intensitas': _intensitas,
        'areaBermasalah': _areaBermasalah,
        'produkDipakai': _produkDipakai.map((p) => p.toJson()).toList(),
        'catatan': _catatan,
      };

  DiaryEntry copyWith({
    String? id,
    DateTime? tanggal,
    KondisiKulit? kondisiUtama,
    List<String>? masalah,
    int? intensitas,
    List<String>? areaBermasalah,
    List<DiaryProduct>? produkDipakai,
    String? catatan,
  }) {
    return DiaryEntry(
      id: id ?? _id,
      tanggal: tanggal ?? _tanggal,
      kondisiUtama: kondisiUtama ?? _kondisiUtama,
      masalah: masalah ?? _masalah,
      intensitas: intensitas ?? _intensitas,
      areaBermasalah: areaBermasalah ?? _areaBermasalah,
      produkDipakai: produkDipakai ?? _produkDipakai,
      catatan: catatan ?? _catatan,
    );
  }

  static KondisiKulit _parseKondisi(String? raw) {
    if (raw == null) return KondisiKulit.normal;
    for (final k in KondisiKulit.values) {
      if (k.name.toLowerCase() == raw.toLowerCase()) return k;
    }
    return KondisiKulit.normal;
  }

  @override
  String toString() => 'DiaryEntry($tanggalLabel)';
}

// ═══════════════════════════════════════════
// DIARY PRODUCT — produk yang dipakai di diary
// ═══════════════════════════════════════════
class DiaryProduct {
  final String nama;
  final String kategori;
  final Map<String, dynamic> detail;

  const DiaryProduct({
    required this.nama,
    required this.kategori,
    this.detail = const {},
  });

  factory DiaryProduct.fromJson(Map<String, dynamic> json) {
    return DiaryProduct(
      nama: json['nama'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      detail: Map<String, dynamic>.from(json['detail'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'kategori': kategori,
        'detail': detail,
      };
}