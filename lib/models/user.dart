// ignore_for_file: unnecessary_getters_setters
import 'base_model.dart';
import 'enums.dart';
import 'enums_ext.dart';
import 'diary_entry.dart';
import 'product.dart';

class User implements BaseModel {
  final String _uid;
  final String _email;
  String _nama;
  JenisKulit _jenisKulit;
  String? _fotoPath;
  final DateTime _createdAt;
  final List<Product> _daftarProduk;
  final List<DiaryEntry> _daftarDiary;

  User({
    required String uid,
    required String email,
    required String nama,
    JenisKulit jenisKulit = JenisKulit.normal,
    String? fotoPath,
    required DateTime createdAt,
    List<Product> daftarProduk = const [],
    List<DiaryEntry> daftarDiary = const [],
  })  : _uid = uid,
        _email = email,
        _nama = nama,
        _jenisKulit = jenisKulit,
        _fotoPath = fotoPath,
        _createdAt = createdAt,
        _daftarProduk = daftarProduk,
        _daftarDiary = daftarDiary;

  factory User.fromJson(Map<String, dynamic> json, {String? uid}) {
    return User(
      uid: uid ?? json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      jenisKulit: _parseJenisKulit(json['jenisKulit'] as String?),
      fotoPath: json['fotoPath'] as String?,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String get uid => _uid;
  String get email => _email;
  String get nama => _nama;
  JenisKulit get jenisKulit => _jenisKulit;
  String? get fotoPath => _fotoPath;
  DateTime get createdAt => _createdAt;
  List<Product> get daftarProduk => List.unmodifiable(_daftarProduk);
  List<DiaryEntry> get daftarDiary => List.unmodifiable(_daftarDiary);

  String get inisial => _nama.isNotEmpty ? _nama[0].toUpperCase() : '?';
  bool get hasFoto => _fotoPath != null && _fotoPath!.isNotEmpty;
  bool get hasProduk => _daftarProduk.isNotEmpty;
  bool get hasDiary => _daftarDiary.isNotEmpty;
  int get jumlahProduk => _daftarProduk.length;
  int get jumlahDiary => _daftarDiary.length;
  String get labelJenisKulit => _jenisKulit.label;
  int get umurAkunHari => DateTime.now().difference(_createdAt).inDays;

  @override
  String get identifier => _uid;

  set nama(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Nama tidak boleh kosong');
    }
    _nama = value.trim();
  }

  set jenisKulit(JenisKulit value) {
    _jenisKulit = value;
  }

  set fotoPath(String? value) {
    _fotoPath = value;
  }

  @override
  Map<String, dynamic> toJson() => {
        'uid': _uid,
        'email': _email,
        'nama': _nama,
        'jenisKulit': _jenisKulit.name,
        if (_fotoPath != null) 'fotoPath': _fotoPath,
        'createdAt': _createdAt.toIso8601String(),
      };

  User copyWith({
    String? uid,
    String? email,
    String? nama,
    JenisKulit? jenisKulit,
    String? fotoPath,
    DateTime? createdAt,
    List<Product>? daftarProduk,
    List<DiaryEntry>? daftarDiary,
  }) {
    return User(
      uid: uid ?? _uid,
      email: email ?? _email,
      nama: nama ?? _nama,
      jenisKulit: jenisKulit ?? _jenisKulit,
      fotoPath: fotoPath ?? _fotoPath,
      createdAt: createdAt ?? _createdAt,
      daftarProduk: daftarProduk ?? _daftarProduk,
      daftarDiary: daftarDiary ?? _daftarDiary,
    );
  }

  void tambahProduk(Product p) => _daftarProduk.add(p);
  void tambahDiary(DiaryEntry d) => _daftarDiary.add(d);

  static JenisKulit _parseJenisKulit(String? raw) {
    if (raw == null) return JenisKulit.normal;
    for (final j in JenisKulit.values) {
      if (j.name.toLowerCase() == raw.toLowerCase()) return j;
    }
    return JenisKulit.normal;
  }

  @override
  String toString() => 'User($_uid — $_nama)';
}