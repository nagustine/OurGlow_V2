import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry.dart';
import '../models/product.dart';

class FirestoreService {
  static const bool useMock = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Map<String, List<Product>> _mockProducts = {};
  final Map<String, List<DiaryEntry>> _mockDiary = {};

  CollectionReference<Map<String, dynamic>> _diaryCol(String uid) =>
      _db.collection('users').doc(uid).collection('diary_entries');

  CollectionReference<Map<String, dynamic>> _productCol(String uid) =>
      _db.collection('users').doc(uid).collection('routine_products');

  // ═══════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════
  Future<void> addProduct(String uid, Product product) async {
    if (useMock) {
      _mockProducts.putIfAbsent(uid, () => []).add(product);
      return;
    }
    await _productCol(uid).doc(product.id).set(product.toJson());
  }

  Future<void> deleteProduct(String uid, String productId) async {
    if (useMock) {
      _mockProducts[uid]?.removeWhere((p) => p.id == productId);
      return;
    }
    await _productCol(uid).doc(productId).delete();
  }

  Future<List<Product>> getProducts(String uid) async {
    if (useMock) {
      return List.unmodifiable(_mockProducts[uid] ?? []);
    }
    final snap = await _productCol(uid).get();
    return snap.docs
        .map((d) => Product.fromJson(d.data(), id: d.id))
        .toList();
  }

  Stream<List<Product>> streamProducts(String uid) {
    if (useMock) {
      return Stream.value(List.unmodifiable(_mockProducts[uid] ?? []));
    }
    return _productCol(uid).snapshots().map((snap) => snap.docs
        .map((d) => Product.fromJson(d.data(), id: d.id))
        .toList());
  }

  Future<int> countProducts(String uid) async {
    if (useMock) {
      return _mockProducts[uid]?.length ?? 0;
    }
    try {
      final snap = await _productCol(uid).count().get();
      return snap.count ?? 0;
    } catch (_) {
      final list = await getProducts(uid);
      return list.length;
    }
  }

  // ═══════════════════════════════════════════
  // DIARY
  // ═══════════════════════════════════════════
  Future<void> addDiary(String uid, DiaryEntry entry) async {
    if (useMock) {
      _mockDiary.putIfAbsent(uid, () => []).add(entry);
      return;
    }
    await _diaryCol(uid).doc(entry.id).set(entry.toJson());
  }

  Future<void> updateDiary(String uid, DiaryEntry entry) async {
    if (useMock) {
      final list = _mockDiary[uid];
      if (list == null) return;
      final idx = list.indexWhere((d) => d.id == entry.id);
      if (idx != -1) list[idx] = entry;
      return;
    }
    await _diaryCol(uid).doc(entry.id).update(entry.toJson());
  }

  Future<void> deleteDiary(String uid, String entryId) async {
    if (useMock) {
      _mockDiary[uid]?.removeWhere((d) => d.id == entryId);
      return;
    }
    await _diaryCol(uid).doc(entryId).delete();
  }

  Future<List<DiaryEntry>> getDiary(String uid) async {
    if (useMock) {
      final list = List<DiaryEntry>.from(_mockDiary[uid] ?? []);
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return list;
    }
    final snap =
        await _diaryCol(uid).orderBy('tanggal', descending: true).get();
    return snap.docs
        .map((d) => DiaryEntry.fromJson(d.data(), id: d.id))
        .toList();
  }

  Stream<List<DiaryEntry>> streamDiary(String uid) {
    if (useMock) {
      return Stream.value(
        List<DiaryEntry>.from(_mockDiary[uid] ?? [])
          ..sort((a, b) => b.tanggal.compareTo(a.tanggal)),
      );
    }
    return _diaryCol(uid)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DiaryEntry.fromJson(d.data(), id: d.id))
            .toList());
  }

  Future<DiaryEntry?> getDiaryByDate(String uid, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    if (useMock) {
      final list = _mockDiary[uid] ?? [];
      for (final d in list) {
        if (!d.tanggal.isBefore(start) && d.tanggal.isBefore(end)) {
          return d;
        }
      }
      return null;
    }
    final snap = await _diaryCol(uid)
        .where('tanggal', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('tanggal', isLessThan: end.toIso8601String())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return DiaryEntry.fromJson(doc.data(), id: doc.id);
  }
}