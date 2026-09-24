import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/enums.dart';
import '../models/user.dart';

class AuthService {
  static const bool useMock = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<AppAuthUser> _mockUsers = [];

  AppAuthUser? _mockCurrentUser;

  Stream<AppAuthUser?> get authStateChanges {
    if (useMock) {
      return Stream<AppAuthUser?>.value(_mockCurrentUser);
    }
    return _auth.authStateChanges().map((u) {
      if (u == null) return null;
      return AppAuthUser(uid: u.uid, email: u.email ?? '');
    });
  }

  AppAuthUser? get currentUser {
    if (useMock) return _mockCurrentUser;
    final u = _auth.currentUser;
    if (u == null) return null;
    return AppAuthUser(uid: u.uid, email: u.email ?? '');
  }

  Future<AppAuthUser> register({
    required String email,
    required String password,
    required String nama,
  }) async {
    if (useMock) {
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

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(nama);
    return AppAuthUser(uid: cred.user!.uid, email: email, nama: nama);
  }

  Future<AppAuthUser> login({
    required String email,
    required String password,
  }) async {
    if (useMock) {
      final found = _mockUsers.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('Email belum terdaftar'),
      );
      _mockCurrentUser = found;
      return found;
    }

    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppAuthUser(
      uid: cred.user!.uid,
      email: cred.user!.email ?? email,
      nama: cred.user!.displayName ?? '',
    );
  }

  Future<void> logout() async {
    if (useMock) {
      _mockCurrentUser = null;
      return;
    }
    await _auth.signOut();
  }

  Future<void> updateJenisKulit(JenisKulit jenis) async {
    _mockCurrentUser = _mockCurrentUser?.copyWith(jenisKulit: jenis);
  }

  Map<String, dynamic> toUserJson(AppAuthUser u) => {
        'uid': u.uid,
        'email': u.email,
        'nama': u.nama,
        'jenisKulit': u.jenisKulit.name,
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

  const AppAuthUser({
    required this.uid,
    required this.email,
    this.nama = '',
    this.jenisKulit = JenisKulit.normal,
  });

  AppAuthUser copyWith({
    String? uid,
    String? email,
    String? nama,
    JenisKulit? jenisKulit,
  }) {
    return AppAuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      jenisKulit: jenisKulit ?? this.jenisKulit,
    );
  }
}