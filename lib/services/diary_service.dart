import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry.dart';
import 'service_locator.dart';

class DiaryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _diaryCol(String uid) =>
      _db.collection('users').doc(uid).collection('diary_entries');

  String get _uid {
    final uid = ServiceLocator.auth.currentUid;
    if (uid == null) throw Exception('User belum login');
    return uid;
  }

  Future<void> add(DiaryEntry entry) async {
    await _diaryCol(_uid).doc(entry.id).set(entry.toJson());
  }

  Future<void> update(DiaryEntry entry) async {
    await _diaryCol(_uid).doc(entry.id).update(entry.toJson());
  }

  Future<void> delete(String entryId) async {
    await _diaryCol(_uid).doc(entryId).delete();
  }

  Future<List<DiaryEntry>> getAll() async {
    final snap =
        await _diaryCol(_uid).orderBy('tanggal', descending: true).get();
    return snap.docs
        .map((d) => DiaryEntry.fromJson(d.data(), id: d.id))
        .toList();
  }

  Stream<List<DiaryEntry>> stream() {
    return _diaryCol(_uid)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DiaryEntry.fromJson(d.data(), id: d.id))
            .toList());
  }

  Future<DiaryEntry?> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _diaryCol(_uid)
        .where('tanggal', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('tanggal', isLessThan: end.toIso8601String())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return DiaryEntry.fromJson(doc.data(), id: doc.id);
  }

  Future<bool> hasEntryOn(DateTime date) async {
    final entry = await getByDate(date);
    return entry != null;
  }

  Future<int> count() async {
    try {
      final snap = await _diaryCol(_uid).count().get();
      return snap.count ?? 0;
    } catch (_) {
      final list = await getAll();
      return list.length;
    }
  }
}