import 'enums.dart';

class ScanResult {
  final String id;
  final String productName;
  final String rawText;
  final DateTime tanggal;
  final List<String> detectedIngredients;
  final List<String> warnings;
  final List<String> conflicts;
  final String summary;
  final StatusAman status;

  const ScanResult({
    required this.id,
    required this.productName,
    required this.rawText,
    required this.tanggal,
    required this.detectedIngredients,
    this.warnings = const [],
    this.conflicts = const [],
    this.summary = '',
    this.status = StatusAman.aman,
  });

  int get jumlahIngredients => detectedIngredients.length;
  bool get hasConflicts => conflicts.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  factory ScanResult.fromJson(Map<String, dynamic> json, {String? id}) {
    final tanggalRaw = json['tanggal'];
    final DateTime tanggal;
    if (tanggalRaw is String) {
      tanggal = DateTime.tryParse(tanggalRaw) ?? DateTime.now();
    } else if (tanggalRaw is DateTime) {
      tanggal = tanggalRaw;
    } else {
      tanggal = DateTime.now();
    }

    return ScanResult(
      id: id ?? json['id'] as String? ?? '',
      productName: json['productName'] as String? ?? 'Product Scan',
      rawText: json['rawText'] as String? ?? '',
      tanggal: tanggal,
      detectedIngredients: List<String>.from(
        json['detectedIngredients'] as List? ?? const [],
      ),
      warnings: List<String>.from(json['warnings'] as List? ?? const []),
      conflicts: List<String>.from(json['conflicts'] as List? ?? const []),
      summary: json['summary'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'rawText': rawText,
        'tanggal': tanggal.toIso8601String(),
        'detectedIngredients': detectedIngredients,
        'warnings': warnings,
        'conflicts': conflicts,
        'summary': summary,
        'status': status.name,
      };

  ScanResult copyWith({
    String? id,
    String? productName,
    String? rawText,
    DateTime? tanggal,
    List<String>? detectedIngredients,
    List<String>? warnings,
    List<String>? conflicts,
    String? summary,
    StatusAman? status,
  }) {
    return ScanResult(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      rawText: rawText ?? this.rawText,
      tanggal: tanggal ?? this.tanggal,
      detectedIngredients: detectedIngredients ?? this.detectedIngredients,
      warnings: warnings ?? this.warnings,
      conflicts: conflicts ?? this.conflicts,
      summary: summary ?? this.summary,
      status: status ?? this.status,
    );
  }

  static StatusAman _parseStatus(String? raw) {
    if (raw == null) return StatusAman.aman;
    for (final s in StatusAman.values) {
      if (s.name.toLowerCase() == raw.toLowerCase()) return s;
    }
    return StatusAman.aman;
  }

  String get tanggalLabel {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }
}