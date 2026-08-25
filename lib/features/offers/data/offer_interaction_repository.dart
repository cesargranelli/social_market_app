import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../domain/offer_comment.dart';

/// Interações sociais sobre uma oferta: curtidas e comentários.
///
/// Estrutura no Firestore:
/// - offers/{offerId}/likes/{likerUid}  -> doc por usuário (id = uid)
/// - offers/{offerId}/comments/{autoId}
class OfferInteractionRepository {
  OfferInteractionRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _likes(String offerId) =>
      _db.collection('offers').doc(offerId).collection('likes');

  CollectionReference<Map<String, dynamic>> _comments(String offerId) =>
      _db.collection('offers').doc(offerId).collection('comments');

  /// Curte/descurte a oferta para o usuário atual. Retorna `true` quando a
  /// chamada RESULTOU em curtida (criação) e `false` quando em descurtida
  /// (remoção). Idempotente por construção: o doc de like tem id = uid.
  Future<bool> toggleLike(String offerId) async {
    final String uid = _auth.currentUser!.uid;
    final DocumentReference<Map<String, dynamic>> likeDoc =
        _likes(offerId).doc(uid);

    final snapshot = await likeDoc.get();
    if (snapshot.exists) {
      await likeDoc.delete();
      return false;
    }
    await likeDoc.set(<String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  Stream<int> watchLikesCount(String offerId) {
    return _likes(offerId).snapshots().map((snapshot) => snapshot.docs.length);
  }

  /// true se [uid] já curtiu a oferta (para estado do botão de curtir).
  Stream<bool> hasLiked(String offerId, String uid) {
    return _likes(offerId)
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  /// Adiciona um comentário à oferta. Texto é trimado; vazio ou >500
  /// caracteres rejeita com [ArgumentError] (mesmo limite das rules).
  Future<void> addComment(String offerId, String text) async {
    final User? user = _auth.currentUser;
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(text, 'text', 'Comentário não pode ser vazio');
    }
    if (trimmed.length > 500) {
      throw ArgumentError.value(
        text,
        'text',
        'Comentário deve ter no máximo 500 caracteres',
      );
    }

    await _comments(offerId).add(<String, dynamic>{
      'uid': user!.uid,
      'authorName': user.displayName ?? 'Usuário',
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OfferComment>> watchComments(String offerId) {
    return _comments(offerId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OfferComment.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}

final offerInteractionRepositoryProvider =
    Provider<OfferInteractionRepository>(
      (ref) => OfferInteractionRepository(
        ref.watch(firestoreProvider),
        ref.watch(firebaseAuthProvider),
      ),
    );
