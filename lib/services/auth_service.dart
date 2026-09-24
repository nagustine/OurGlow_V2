import '../models/enums.dart';
import '../models/user.dart';

class AuthService {
  static const bool useMock = true;

  final List<AppAuthUser> _mockUsers = [];
  AppAuthUser? _mockCurrentUser;

  Stream<AppAuthUser?> get authStateChanges =>
      Stream<AppAuthUser?>.value(_mockCurrentUser);

  AppAuthUser? get currentUser => _mockCurrentUser;

  Future<AppAuthUser> register({
    required String email,
    required String password,
    required String nama,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_mockUsers.any((u) => u.email == email)) {
      throw Exception('Email sudah terdaftar');
    }

    final newUser = AppAuthUser(
      uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      nama: nama,
    );
    _mockUsers.add(newUser);
    _mockCurrentUser = newUser;
    return newUser;
  }

  Future<AppAuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final found = _mockUsers.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Email belum terdaftar'),
    );
    _mockCurrentUser = found;
    return found;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockCurrentUser = null;
  }

  Future<void> updateJenisKulit(JenisKulit jenis) async {
    if (_mockCurrentUser == null) return;
    _mockCurrentUser = _mockCurrentUser!.copyWith(jenisKulit: jenis);
  }

  void updateNama(String nama) {
    if (_mockCurrentUser == null) return;
    _mockCurrentUser = _mockCurrentUser!.copyWith(nama: nama);
  }

  void updateFoto(String? fotoPath) {
    if (_mockCurrentUser == null) return;
    _mockCurrentUser = _mockCurrentUser!.copyWith(fotoPath: fotoPath);
  }

  Map<String, dynamic> toUserJson(AppAuthUser u) => {
        'uid': u.uid,
        'email': u.email,
        'nama': u.nama,
        'jenisKulit': u.jenisKulit.name,
        if (u.fotoPath != null) 'fotoPath': u.fotoPath,
        'createdAt': DateTime.now().toIso8601String(),
      };

  User toAppUser(AppAuthUser u) => User(
        uid: u.uid,
        email: u.email,
        nama: u.nama,
        jenisKulit: u.jenisKulit,
        createdAt: DateTime.now(),
      );
}

class AppAuthUser {
  final String uid;
  final String email;
  final String nama;
  final JenisKulit jenisKulit;
  final String? fotoPath;

  const AppAuthUser({
    required this.uid,
    required this.email,
    this.nama = '',
    this.jenisKulit = JenisKulit.normal,
    this.fotoPath,
  });

  AppAuthUser copyWith({
    String? uid,
    String? email,
    String? nama,
    JenisKulit? jenisKulit,
    String? fotoPath,
  }) {
    return AppAuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      jenisKulit: jenisKulit ?? this.jenisKulit,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }
}