import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../domain/store_model.dart';

class StoreRepository {
  StoreRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _stores =>
      _db.collection('stores');

  Future<String> createStore(StoreModel store) async {
    final docRef = _stores.doc();
    await docRef.set(<String, dynamic>{
      ...store.toMap(),
      if (store.createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<StoreModel?> getById(String id) async {
    final snapshot = await _stores.doc(id).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return StoreModel.fromMap(snapshot.id, data);
  }

  Future<List<StoreModel>> searchByName(String city, String query) async {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return const [];

    final snapshot =
        await _stores
            .where('city', isEqualTo: city)
            .orderBy('nameSearch')
            .startAt([term]).endAt(['$term\uf8ff']).get();

    return snapshot.docs
        .map((doc) => StoreModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<StoreModel>> watchAll({int limit = 50}) {
    return _stores
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StoreModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}

final storeRepositoryProvider = Provider<StoreRepository>(
  (ref) => StoreRepository(ref.watch(firestoreProvider)),
);
