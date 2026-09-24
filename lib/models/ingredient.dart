import 'enums.dart';

class Ingredient {
  final String id;
  final String name;
  final List<String> aliases;
  final KategoriBahan kategori;
  final List<String> conflicts;
  final List<JenisKulit> warningSkinType;
  final String note;

  const Ingredient({
    required this.id,
    required this.name,
    required this.aliases,
    required this.kategori,
    required this.conflicts,
    required this.warningSkinType,
    required this.note,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String,
      name: json['name'] as String,
      aliases: List<String>.from(json['aliases'] as List),
      kategori: _parseKategori(json['category'] as String?),
      conflicts: List<String>.from(json['conflicts'] as List),
      warningSkinType: (json['warning_skin_type'] as List)
          .map((e) => _parseJenisKulit(e as String))
          .toList(),
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'aliases': aliases,
        'category': kategori.name,
        'conflicts': conflicts,
        'warning_skin_type': warningSkinType.map((e) => e.name).toList(),
        'note': note,
      };

  static KategoriBahan _parseKategori(String? raw) {
    if (raw == null) return KategoriBahan.unknown;
    for (final k in KategoriBahan.values) {
      if (k.name.toLowerCase() == raw.toLowerCase()) return k;
    }
    return KategoriBahan.unknown;
  }

  static JenisKulit _parseJenisKulit(String raw) {
    for (final j in JenisKulit.values) {
      if (j.name.toLowerCase() == raw.toLowerCase()) return j;
    }
    return JenisKulit.normal;
  }
}