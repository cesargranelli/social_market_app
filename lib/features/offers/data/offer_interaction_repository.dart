import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../domain/offer_comment.dart';

/// Interações sociais sobre uma oferta: curtidas, comentários e confirmações.
///
/// Estrutura no Firestore:
/// - offers/{offerId}/likes/{likerUid}  -> doc por usuário (id = uid)
/// - offers/{offerId}/comments/{autoId}
/// - offers/{offerId}/confirmations/{uid} -> dispara Cloud Functions que
///   mantêm `confirmCount`, status e pontuação do autor (docs/functions.md).
class OfferInteractionRepository {
  OfferInteractionRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _likes(String offerId) =>
      _db.collection('offers').doc(offerId).collection('likes');

  CollectionReference<Map<String, dynamic>> _comments(String offerId) =>
      _db.collection('offers').doc(offerId).collection('comments');

  CollectionReference<Map<String, dynamic>> _confirmations(String offerId) =>
      _db.collection('offers').doc(offerId).collection('confirmations');

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

  /// Registra a confirmação do usuário autenticado na oferta.
  ///
  /// O doc é idempotente por construção (doc id = uid), e as rules só
  /// permitem create/delete do próprio uid. Os efeitos (confirmCount,
  /// status `verified`, pontos do autor) são aplicados pelas Cloud
  /// Functions — o client NUNCA escreve esses campos diretamente.
  Future<void> addConfirmation(String offerId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }
    await _confirmations(offerId).doc(user.uid).set(<String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Emite true se [uid] já confirmou [offerId] (reage a add/remove ao vivo).
  Stream<bool> hasConfirmed(String offerId, String uid) {
    return _confirmations(offerId)
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  /// Contagem de confirmações da oferta em tempo real.
  ///
  /// Nota: `count().snapshots()` só existe em cloud_firestore >= 6; na v5
  /// observamos os snapshots da subcoleção e contamos os docs localmente.
  Stream<int> watchConfirmCount(String offerId) {
    return _confirmations(offerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Total de comentários feitos por [uid] em todas as ofertas, via
  /// collectionGroup sobre as subcoleções `comments` das ofertas.
  ///
  /// Requer índice automático (campo único `uid`) — sem índice composto,
  /// o Firestore atende sem configuração extra.
  Future<int> countCommentsByAuthor(String uid) async {
    final snapshot = await _db
        .collectionGroup('comments')
        .where('uid', isEqualTo: uid)
        .get();
    return snapshot.docs.length;
  }
}

final offerInteractionRepositoryProvider =
    Provider<OfferInteractionRepository>(
      (ref) => OfferInteractionRepository(
        ref.watch(firestoreProvider),
        ref.watch(firebaseAuthProvider),
      ),
    );
