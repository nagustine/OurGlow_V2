import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scan_result.dart';
import 'service_locator.dart';

class ScanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _scanCol(String uid) =>
      _db.collection('users').doc(uid).collection('scan_history');

  String get _uid {
    final uid = ServiceLocator.auth.currentUid;
    if (uid == null) throw Exception('User belum login');
    return uid;
  }

  Future<void> add(ScanResult scan) async {
    await _scanCol(_uid).doc(scan.id).set(scan.toJson());
  }

  Future<void> delete(String scanId) async {
    await _scanCol(_uid).doc(scanId).delete();
  }

  Future<List<ScanResult>> getAll() async {
    try {
      final snap = await _scanCol(_uid)
          .orderBy('tanggal', descending: true)
          .get();
      return snap.docs
          .map((d) => ScanResult.fromJson(d.data(), id: d.id))
          .toList();
    } catch (e) {
      try {
        final snap = await _scanCol(_uid).get();
        final list = snap.docs
            .map((d) => ScanResult.fromJson(d.data(), id: d.id))
            .toList();
        list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        return list;
      } catch (_) {
        return [];
      }
    }
  }

  Stream<List<ScanResult>> stream() {
    return _scanCol(_uid)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ScanResult.fromJson(d.data(), id: d.id))
            .toList());
  }

  Future<int> count() async {
    try {
      final snap = await _scanCol(_uid).count().get();
      return snap.count ?? 0;
    } catch (_) {
      final list = await getAll();
      return list.length;
    }
  }
}