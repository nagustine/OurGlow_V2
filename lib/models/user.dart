import 'enums.dart';
import 'product.dart';
import 'diary_entry.dart';

class User {
  final String uid;
  final String email;
  final String nama;
  final JenisKulit jenisKulit;
  final List<Product> daftarProduk;
  final List<DiaryEntry> daftarDiary;
  final DateTime createdAt;

  const User({
    required this.uid,
    required this.email,
    required this.nama,
    this.jenisKulit = JenisKulit.normal,
    this.daftarProduk = const [],
    this.daftarDiary = const [],
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? uid}) {
    return User(
      uid: uid ?? json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      jenisKulit: _parseJenisKulit(json['jenisKulit'] as String?),
      daftarProduk: const [],
      daftarDiary: const [],
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'nama': nama,
        'jenisKulit': jenisKulit.name,
        'createdAt': createdAt.toIso8601String(),
      };

  static JenisKulit _parseJenisKulit(String? raw) {
    if (raw == null) return JenisKulit.normal;
    for (final j in JenisKulit.values) {
      if (j.name.toLowerCase() == raw.toLowerCase()) return j;
    }
    return JenisKulit.normal;
  }
}