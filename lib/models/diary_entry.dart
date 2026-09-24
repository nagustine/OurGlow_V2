import 'enums.dart';
import 'product.dart';

class DiaryEntry {
  final String id;
  final DateTime tanggal;
  final List<KondisiKulit> kondisiKulit;
  final String catatan;
  final String? fotoUrl;
  final List<Product> produkDipakai;
  final StatusAman statusRutin;

  const DiaryEntry({
    required this.id,
    required this.tanggal,
    required this.kondisiKulit,
    this.catatan = '',
    this.fotoUrl,
    this.produkDipakai = const [],
    this.statusRutin = StatusAman.aman,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json, {String? id}) {
    final tanggalRaw = json['tanggal'];
    final DateTime tanggal = tanggalRaw is String
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

  Map<String, dynamic> toJson() => {
        'tanggal': tanggal.toIso8601String(),
        'kondisiKulit': kondisiKulit.map((e) => e.name).toList(),
        'catatan': catatan,
        if (fotoUrl != null) 'fotoUrl': fotoUrl,
        'produkDipakai': produkDipakai.map((p) => p.toJson()).toList(),
        'statusRutin': statusRutin.name,
      };

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
}