import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_market_app/features/offers/data/offer_interaction_repository.dart';
import 'package:social_market_app/features/offers/domain/offer_comment.dart';

/// Drena eventos assíncronos do snapshot listener do FakeFirebaseFirestore.
Future<void> _drain([int ms = 20]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  late FakeFirebaseFirestore db;
  late MockFirebaseAuth auth;
  late OfferInteractionRepository repository;

  setUp(() {
    db = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', displayName: 'Ana'),
    );
    repository = OfferInteractionRepository(db, auth);
  });

  CollectionReference<Map<String, dynamic>> likesCol(String offerId) =>
      db.collection('offers').doc(offerId).collection('likes');

  group('toggleLike', () {
    test('cria like retornando true e remove retornando false (idempotente)',
        () async {
      // 1o toggle: curtiu.
      expect(await repository.toggleLike('of1'), isTrue);
      final criado = await likesCol('of1').doc('u1').get();
      expect(criado.exists, isTrue);
      expect(criado.data(), isNotNull);

      // 2o toggle: descurtiu (mesma chamada repetida -> estado oposto).
      expect(await repository.toggleLike('of1'), isFalse);
      expect((await likesCol('of1').doc('u1').get()).exists, isFalse);

      // Toggle duplo volta ao estado inicial sem duplicar docs.
      expect(await repository.toggleLike('of1'), isTrue);
      expect(await repository.toggleLike('of1'), isFalse);
      expect((await likesCol('of1').get()).docs, isEmpty);
    });

    test('likes de usuários diferentes são independentes', () async {
      await likesCol('of2').doc('u2').set(<String, dynamic>{});

      expect(await repository.toggleLike('of2'), isTrue);

      final todos = await likesCol('of2').get();
      expect(todos.docs.map((d) => d.id), containsAll(<String>['u1', 'u2']));
    });
  });

  group('watchLikesCount', () {
    test('emite contagem correta após adds/removes', () async {
      final counts = <int>[];
      final sub = repository.watchLikesCount('of3').listen(counts.add);
      await _drain();

      await likesCol('of3').doc('a').set(<String, dynamic>{});
      await _drain();
      await likesCol('of3').doc('b').set(<String, dynamic>{});
      await _drain();
      await likesCol('of3').doc('a').delete();
      await _drain();

      expect(counts, <int>[0, 1, 2, 1]);
      await sub.cancel();
    });
  });

  group('hasLiked', () {
    test('reflete existência do doc de like do usuário', () async {
      final estados = <bool>[];
      final sub = repository.hasLiked('of4', 'u1').listen(estados.add);
      await _drain();

      await repository.toggleLike('of4'); // u1 curte
      await _drain();
      await repository.toggleLike('of4'); // u1 descurte
      await _drain();

      expect(estados, <bool>[false, true, false]);
      await sub.cancel();
    });
  });

  group('addComment / watchComments', () {
    test('grava campos corretos e trims o texto', () async {
      await repository.addComment('of5', '  Olá, bom preço!  ');

      final snapshot = await db
          .collection('offers')
          .doc('of5')
          .collection('comments')
          .get();
      expect(snapshot.docs, hasLength(1));

      final data = snapshot.docs.single.data();
      expect(data['uid'], 'u1');
      expect(data['authorName'], 'Ana');
      expect(data['text'], 'Olá, bom preço!');
      expect(data['createdAt'], isNotNull);

      final model = OfferComment.fromMap(snapshot.docs.single.id, data);
      expect(model.text, 'Olá, bom preço!');
    });

    test('authorName cai para "Usuário" quando displayName é null', () async {
      final authSemNome = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u2'),
      );
      final repo = OfferInteractionRepository(db, authSemNome);

      await repo.addComment('of5', 'Primeiro!');

      final data = (await db
              .collection('offers')
              .doc('of5')
              .collection('comments')
              .get())
          .docs
          .single
          .data();
      expect(data['uid'], 'u2');
      expect(data['authorName'], 'Usuário');
    });

    test('rejeita texto vazio/só espaços com ArgumentError', () async {
      expect(
        () => repository.addComment('of6', ''),
        throwsArgumentError,
      );
      expect(
        () => repository.addComment('of6', '   \n\t '),
        throwsArgumentError,
      );
      final snapshot = await db
          .collection('offers')
          .doc('of6')
          .collection('comments')
          .get();
      expect(snapshot.docs, isEmpty);
    });

    test('rejeita texto acima de 500 caracteres com ArgumentError', () async {
      expect(
        () => repository.addComment('of7', 'x' * 501),
        throwsArgumentError,
      );
      // Limite exato (500) é aceito.
      await repository.addComment('of7', 'x' * 500);
      expect(
        (await db
                .collection('offers')
                .doc('of7')
                .collection('comments')
                .get())
            .docs,
        hasLength(1),
      );
    });

    test('watchComments emite comentários ordenados por createdAt asc',
        () async {
      await repository.addComment('of8', 'primeiro');
      await _drain(30);
      await repository.addComment('of8', 'segundo');
      await _drain(30);
      await repository.addComment('of8', 'terceiro');

      final comentarios = await repository.watchComments('of8').first;

      expect(comentarios.map((c) => c.text).toList(), <String>[
        'primeiro',
        'segundo',
        'terceiro',
      ]);
      for (final comentario in comentarios) {
        expect(comentario.uid, 'u1');
        expect(comentario.authorName, 'Ana');
      }
    });
  });
}
