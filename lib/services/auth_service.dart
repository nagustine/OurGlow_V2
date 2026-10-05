import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/enums.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  JenisKulit _jenisKulitCache = JenisKulit.normal;

  String? get currentUid => _auth.currentUser?.uid;

  Stream<AppAuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((u) {
      if (u == null) return null;
      return AppAuthUser(
        uid: u.uid,
        email: u.email ?? '',
        nama: u.displayName ?? '',
        jenisKulit: _jenisKulitCache,
      );
    });
  }

  AppAuthUser? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return AppAuthUser(
      uid: u.uid,
      email: u.email ?? '',
      nama: u.displayName ?? '',
      jenisKulit: _jenisKulitCache,
    );
  }

  Future<AppAuthUser> register({
    required String email,
    required String password,
    required String nama,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(nama);
    await cred.user?.reload();
    return AppAuthUser(
      uid: cred.user!.uid,
      email: email,
      nama: nama,
      jenisKulit: _jenisKulitCache,
    );
  }

  Future<AppAuthUser> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppAuthUser(
      uid: cred.user!.uid,
      email: cred.user!.email ?? email,
      nama: cred.user!.displayName ?? '',
      jenisKulit: _jenisKulitCache,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
    _jenisKulitCache = JenisKulit.normal;
  }

  Future<void> updateJenisKulit(JenisKulit jenis) async {
    _jenisKulitCache = jenis;
  }

  Future<void> updateNama(String nama) async {
    await _auth.currentUser?.updateDisplayName(nama);
    await _auth.currentUser?.reload();
  }

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