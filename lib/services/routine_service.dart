import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/routine_product.dart';
import '../models/enums.dart';
import 'service_locator.dart';

class RoutineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _routineCol(String uid) =>
      _db.collection('users').doc(uid).collection('routine_products');

  String get _uid {
    final uid = ServiceLocator.auth.currentUid;
    if (uid == null) throw Exception('User belum login');
    return uid;
  }

  Future<void> add(RoutineProduct product) async {
    await _routineCol(_uid).doc(product.id).set(product.toJson());
  }

  Future<void> update(RoutineProduct product) async {
    await _routineCol(_uid).doc(product.id).update(product.toJson());
  }

  Future<void> delete(String productId) async {
    await _routineCol(_uid).doc(productId).delete();
  }

  Future<List<RoutineProduct>> getAll() async {
    try {
      final snap = await _routineCol(_uid).orderBy('urutan').get();
      return snap.docs
          .map((d) => RoutineProduct.fromJson(d.data(), id: d.id))
          .toList();
    } catch (e) {
      try {
        final snap = await _routineCol(_uid).get();
        final list = snap.docs
            .map((d) => RoutineProduct.fromJson(d.data(), id: d.id))
            .toList();
        list.sort((a, b) => a.urutan.compareTo(b.urutan));
        return list;
      } catch (_) {
        return [];
      }
    }
  }

  Stream<List<RoutineProduct>> stream() {
    return _routineCol(_uid)
        .orderBy('urutan')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RoutineProduct.fromJson(d.data(), id: d.id))
            .toList());
  }

  Future<int> count() async {
    try {
      final snap = await _routineCol(_uid).count().get();
      return snap.count ?? 0;
    } catch (_) {
      final list = await getAll();
      return list.length;
    }
  }

  Future<int> countByWaktu(WaktuPakai waktu) async {
    final list = await getAll();
    return list.where((p) => p.waktuPakai == waktu).length;
  }

  Future<void> updateUrutan(List<RoutineProduct> products) async {
    final batch = _db.batch();
    for (var i = 0; i < products.length; i++) {
      final ref = _routineCol(_uid).doc(products[i].id);
      batch.update(ref, {'urutan': i});
    }
    await batch.commit();
  }
}