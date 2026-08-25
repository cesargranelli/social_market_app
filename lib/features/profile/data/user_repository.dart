import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../domain/user_model.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> ensureUserDocument(User user) async {
    final docRef = _users.doc(user.uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set(
        <String, dynamic>{
          'displayName': user.displayName ?? '',
          if (user.photoURL != null) 'photoUrl': user.photoURL,
          'points': 0,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return;
    }
    await docRef.set(
      <String, dynamic>{
        if (user.displayName != null && user.displayName!.isNotEmpty)
          'displayName': user.displayName,
        if (user.photoURL != null) 'photoUrl': user.photoURL,
      },
      SetOptions(merge: true),
    );
  }

  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return UserModel.fromMap(snapshot.id, data);
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return UserModel.fromMap(snapshot.id, data);
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
);
