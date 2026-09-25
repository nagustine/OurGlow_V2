import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/enums.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AppAuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((u) {
      if (u == null) return null;
      return AppAuthUser(
        uid: u.uid,
        email: u.email ?? '',
        nama: u.displayName ?? '',
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
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateJenisKulit(JenisKulit jenis) async {
    // TODO: Simpan ke Firestore (nanti)
  }

  void updateNama(String nama) {
    _auth.currentUser?.updateDisplayName(nama);
  }

  void updateFoto(String? fotoPath) {
    // TODO: Simpan ke Firestore/Storage (nanti)
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