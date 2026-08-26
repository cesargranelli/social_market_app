import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:social_market_app/features/offers/data/offer_interaction_repository.dart';
import 'package:social_market_app/features/offers/data/offer_repository.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/profile/data/user_repository.dart';
import 'package:social_market_app/features/profile/domain/badges.dart';

/// Drena eventos assíncronos do snapshot listener do FakeFirebaseFirestore.
Future<void> _drain([int ms = 20]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  final t1 = DateTime.utc(2026, 8, 1, 10, 0);

  group('UserRepository.watchTopUsers', () {
    late FakeFirebaseFirestore db;
    late UserRepository repository;

    setUp(() {
      db = FakeFirebaseFirestore();
      repository = UserRepository(db);
    });

    Future<void> seedUser(
      String uid, {
      required int points,
      String name = 'Ana',
    }) =>
        db.collection('users').doc(uid).set(<String, dynamic>{
          'displayName': name,
          'points': points,
          'createdAt': t1,
        });

    test('ordena por points desc e doc.id vira uid do model', () async {
      await seedUser('u-baixo', points: 5);
      await seedUser('u-topo', points: 100, name: 'Bruno');
      await seedUser('u-meio', points: 50);

      final topo = await repository.watchTopUsers().first;

      expect(topo.map((u) => u.uid).toList(), <String>[
        'u-topo',
        'u-meio',
        'u-baixo',
      ]);
      expect(topo.first.displayName, 'Bruno');
      expect(topo.first.points, 100);
      // uid do modelo vem do doc.id (não de campo interno).
      expect(topo.last.uid, 'u-baixo');
    });

    test('respeita o limit', () async {
      for (var i = 0; i < 5; i++) {
        await seedUser('u$i', points: i * 10);
      }

      final topo = await repository.watchTopUsers(limit: 2).first;

      expect(topo, hasLength(2));
      expect(topo.map((u) => u.uid), <String>['u4', 'u3']);
    });

    test('empate em pontos não lança e mantém todos os docs', () async {
      await seedUser('a', points: 10);
      await seedUser('b', points: 10);

      final topo = await repository.watchTopUsers().first;

      expect(topo.map((u) => u.uid), containsAllInOrder(<String>['a', 'b']));
    });

    test('emite ao vivo quando novo usuário ultrapassa o ranking',
        () async {
      final emissoes = <List<String>>[];
      final sub = repository.watchTopUsers().listen(
            (users) => emissoes.add(users.map((u) => u.uid).toList()),
          );
      await _drain();

      await seedUser('u1', points: 10);
      await _drain();
      await seedUser('u2', points: 99);
      await _drain();

      expect(emissoes, <List<String>>[
        <String>[],
        <String>['u1'],
        <String>['u2', 'u1'],
      ]);
      await sub.cancel();
    });
  });

  group('OfferRepository contadores por autor', () {
    late FakeFirebaseFirestore db;
    late OfferRepository repository;

    setUp(() {
      db = FakeFirebaseFirestore();
      repository = OfferRepository(db, MockFirebaseAuth());
    });

    Future<void> seedOffer({
      required String authorUid,
      required String status,
      String productName = 'Arroz',
    }) async {
      final offer = OfferModel(
        productName: productName,
        price: 9.9,
        storeId: 's1',
        authorUid: authorUid,
        createdAt: t1,
      );
      final id = await repository.createOffer(offer);
      if (status != 'active') {
        await db
            .collection('offers')
            .doc(id)
            .update(<String, dynamic>{'status': status});
      }
    }

    test('countOffersByAuthor conta só do autor com dados mistos', () async {
      await seedOffer(authorUid: 'autor-1', status: 'active');
      await seedOffer(authorUid: 'autor-1', status: 'verified');
      await seedOffer(authorUid: 'autor-1', status: 'expired');
      await seedOffer(authorUid: 'outro', status: 'active');

      expect(await repository.countOffersByAuthor('autor-1'), 3);
      expect(await repository.countOffersByAuthor('outro'), 1);
      expect(await repository.countOffersByAuthor('ninguem'), 0);
    });

    test(
        'countVerifiedByAuthor conta somente status verified do autor',
        () async {
      await seedOffer(authorUid: 'autor-1', status: 'verified');
      await seedOffer(authorUid: 'autor-1', status: 'verified');
      await seedOffer(authorUid: 'autor-1', status: 'active');
      await seedOffer(authorUid: 'autor-1', status: 'expired');
      await seedOffer(authorUid: 'outro', status: 'verified');

      expect(await repository.countVerifiedByAuthor('autor-1'), 2);
      expect(await repository.countVerifiedByAuthor('outro'), 1);
      expect(await repository.countVerifiedByAuthor('ninguem'), 0);
    });
  });

  group('OfferInteractionRepository.countCommentsByAuthor', () {
    late FakeFirebaseFirestore db;
    late OfferInteractionRepository repository;

    setUp(() {
      db = FakeFirebaseFirestore();
      repository = OfferInteractionRepository(db, MockFirebaseAuth());
    });

    Future<void> seedComment(String offerId, String uid) => db
        .collection('offers')
        .doc(offerId)
        .collection('comments')
        .add(<String, dynamic>{
          'uid': uid,
          'authorName': 'Alguém',
          'text': 'Bom preço!',
          'createdAt': t1,
        });

    test('conta via collectionGroup entre várias ofertas', () async {
      await seedComment('of1', 'comentador');
      await seedComment('of1', 'comentador');
      await seedComment('of2', 'comentador');
      await seedComment('of1', 'outro');

      expect(await repository.countCommentsByAuthor('comentador'), 3);
      expect(await repository.countCommentsByAuthor('outro'), 1);
      expect(await repository.countCommentsByAuthor('ninguem'), 0);
    });
  });

  group('computeBadges', () {
    const firstOfferId = 'first_offer';
    const prolificId = 'prolific';
    const trustedId = 'trusted';
    const commenterId = 'commenter';

    List<String> ids(int offers, int verified, int comments) =>
        computeBadges(
          offersCount: offers,
          verifiedCount: verified,
          commentsCount: comments,
        ).map((b) => b.id).toList();

    test('casos limite — tabela', () {
      final casos = <(int, int, int, List<String>)>[
        // (offers, verified, comments, badges esperados)
        (0, 0, 0, <String>[]),
        (1, 0, 0, <String>[firstOfferId]),
        (9, 0, 0, <String>[firstOfferId]),
        (10, 0, 0, <String>[firstOfferId, prolificId]),
        (11, 0, 4, <String>[firstOfferId, prolificId]),
        (0, 1, 0, <String>[trustedId]),
        (0, 0, 4, <String>[]),
        (0, 0, 5, <String>[commenterId]),
        (0, 0, 6, <String>[commenterId]),
        (1, 1, 5,
            <String>[firstOfferId, trustedId, commenterId]),
        (12, 3, 7, <String>[
          firstOfferId,
          prolificId,
          trustedId,
          commenterId,
        ]),
      ];

      for (final (offers, verified, comments, esperado) in casos) {
        expect(
          ids(offers, verified, comments),
          esperado,
          reason:
              'offers=$offers verified=$verified comments=$comments '
              'deve gerar $esperado na ordem fixa',
        );
      }
    });

    test('ordem fixa mesmo com entradas invertidas', () {
      final badges = computeBadges(
        offersCount: 15,
        verifiedCount: 2,
        commentsCount: 10,
      );

      expect(badges.map((b) => b.id).toList(), <String>[
        firstOfferId,
        prolificId,
        trustedId,
        commenterId,
      ]);
    });

    test('badges expõem label e ícone definidos', () {
      final badges = computeBadges(
        offersCount: 1,
        verifiedCount: 1,
        commentsCount: 5,
      );

      final porId = {for (final b in badges) b.id: b};
      expect(porId[firstOfferId]!.label, 'Primeira oferta publicada');
      expect(porId[trustedId]!.label, 'Oferta verificada');
      expect(porId[commenterId]!.label, 'Comentarista ativo');
      for (final badge in badges) {
        expect(badge.icon, isA<IconData>());
      }
      // Igualdade por id; sem duplicatas para a mesma entrada.
      expect(computeBadges(
        offersCount: 20,
        verifiedCount: 1,
        commentsCount: 9,
      ), unorderedEquals(<Badge>[
        ...computeBadges(offersCount: 20, verifiedCount: 1, commentsCount: 9),
      ]));
    });
  });
}
