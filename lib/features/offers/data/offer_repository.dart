import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/firebase_providers.dart';
import '../domain/offer_model.dart';

class OfferRepository {
  OfferRepository(this._db, this._auth, {FirebaseStorage? storage})
    : _storage = storage;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage? _storage;

  CollectionReference<Map<String, dynamic>> get _offers =>
      _db.collection('offers');

  Future<String> createOffer(OfferModel offer) async {
    final docRef = _offers.doc();
    await docRef.set(offer.toMap());
    return docRef.id;
  }

  Stream<List<OfferModel>> watchRecent({String? storeId, int limit = 50}) {
    Query<Map<String, dynamic>> query =
        _offers.orderBy('createdAt', descending: true).limit(limit);
    if (storeId != null) {
      query = query.where('storeId', isEqualTo: storeId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => OfferModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<OfferModel?> getById(String id) async {
    final snapshot = await _offers.doc(id).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return OfferModel.fromMap(snapshot.id, data);
  }

  Future<void> markExpired(String id) {
    return _offers.doc(id).update(<String, dynamic>{
      'status': OfferStatus.expired.name,
    });
  }

  Future<String> uploadOfferImage(String path, XFile file) async {
    final storage = _storage;
    if (storage == null) {
      throw StateError('FirebaseStorage não configurado');
    }
    final ref = storage.ref('offers/$path');
    await ref.putFile(File(file.path));
    return ref.getDownloadURL();
  }

  Future<void> deleteOffer(String id) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('Usuário não autenticado');
    }
    final snapshot = await _offers.doc(id).get();
    if (!snapshot.exists) {
      throw StateError('Oferta não encontrada: $id');
    }
    if (snapshot.data()?['authorUid'] != currentUser.uid) {
      throw Exception('Somente o autor pode excluir a oferta');
    }
    await _offers.doc(id).delete();
  }
}

final offerRepositoryProvider = Provider<OfferRepository>(
  (ref) => OfferRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
    storage: ref.watch(firebaseStorageProvider),
  ),
);
