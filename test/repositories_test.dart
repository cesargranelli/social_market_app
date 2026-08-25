import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_market_app/features/offers/data/offer_repository.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/profile/data/user_repository.dart';
import 'package:social_market_app/features/stores/data/store_repository.dart';
import 'package:social_market_app/features/stores/domain/store_model.dart';

void main() {
  final t1 = DateTime.utc(2026, 8, 1, 10, 0);
  final t2 = DateTime.utc(2026, 8, 2, 11, 0);
  final t3 = DateTime.utc(2026, 8, 3, 12, 0);

  group('OfferRepository', () {
    late FakeFirebaseFirestore db;
    late OfferRepository repository;

    setUp(() {
      db = FakeFirebaseFirestore();
      repository = OfferRepository(db, MockFirebaseAuth());
    });

    OfferModel buildOffer({
      required DateTime createdAt,
      String productName = 'Arroz 5kg',
      double price = 19.9,
      String authorUid = 'u1',
    }) => OfferModel(
      productName: productName,
      price: price,
      unit: 'un',
      storeId: 's1',
      authorUid: authorUid,
      createdAt: createdAt,
    );

    test('createOffer grava documento correto e retorna id', () async {
      final id = await repository.createOffer(
        buildOffer(createdAt: t1),
      );

      expect(id, isNotEmpty);

      final doc = await db.collection('offers').doc(id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['productName'], 'Arroz 5kg');
      expect(doc.data()!['price'], 19.9);
      expect(doc.data()!['authorUid'], 'u1');
      expect(doc.data()!['status'], 'active');
      expect(doc.data()!['confirmCount'], 0);

      final model = await repository.getById(id);
      expect(model, isNotNull);
      expect(model!.productName, 'Arroz 5kg');
    });

    test('watchRecent ordena por createdAt desc e filtra por loja', () async {
      await repository.createOffer(buildOffer(createdAt: t1));
      await repository.createOffer(
        buildOffer(createdAt: t2, productName: 'Feijão'),
      );
      await repository.createOffer(
        buildOffer(createdAt: t3, productName: 'Café', authorUid: 'u2'),
      );

      final recent = await repository.watchRecent().first;
      expect(recent.map((o) => o.productName), [
        'Café',
        'Feijão',
        'Arroz 5kg',
      ]);

      final limitado = await repository.watchRecent(limit: 2).first;
      expect(limitado, hasLength(2));

      await repository.createOffer(
        OfferModel(
          productName: 'Leite',
          price: 4.99,
          storeId: 's2',
          authorUid: 'u2',
          createdAt: t3,
        ),
      );
      final daLoja = await repository.watchRecent(storeId: 's2').first;
      expect(daLoja, hasLength(1));
      expect(daLoja.first.storeId, 's2');
    });

    test('markExpired altera somente o status', () async {
      final id = await repository.createOffer(buildOffer(createdAt: t1));

      await repository.markExpired(id);

      final doc = await db.collection('offers').doc(id).get();
      expect(doc.data()!['status'], 'expired');
      expect(doc.data()!['confirmCount'], 0);
    });

    test('deleteOffer permite autor e bloqueia não-autor', () async {
      final id = await repository.createOffer(
        buildOffer(createdAt: t1, authorUid: 'autor-1'),
      );

      final authAutor = MockFirebaseAuth(
        mockUser: MockUser(uid: 'autor-1'),
      );
      await authAutor.signInWithCredential(
        EmailAuthProvider.credential(email: 'autor@teste.com', password: '123'),
      );
      await OfferRepository(db, authAutor).deleteOffer(id);
      expect((await db.collection('offers').doc(id).get()).exists, isFalse);

      final id2 = await repository.createOffer(
        buildOffer(createdAt: t2, authorUid: 'autor-1'),
      );
      final authOutro = MockFirebaseAuth(mockUser: MockUser(uid: 'outro'));
      await authOutro.signInWithCredential(
        EmailAuthProvider.credential(email: 'outro@teste.com', password: '123'),
      );
      expect(
        () => OfferRepository(db, authOutro).deleteOffer(id2),
        throwsException,
      );
      expect((await db.collection('offers').doc(id2).get()).exists, isTrue);
    });
  });

  group('StoreRepository', () {
    late FakeFirebaseFirestore db;
    late StoreRepository repository;

    setUp(() {
      db = FakeFirebaseFirestore();
      repository = StoreRepository(db);
    });

    test('createStore + getById persistem e leem a loja', () async {
      const store = StoreModel(
        name: 'Mercado Central',
        city: 'Campinas',
        neighborhood: 'Centro',
        address: 'Rua X, 123',
        createdBy: 'u1',
      );

      final id = await repository.createStore(store);

      expect(id, isNotEmpty);
      final loaded = await repository.getById(id);
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Mercado Central');
      expect(loaded.city, 'Campinas');
      expect(loaded.createdBy, 'u1');
      expect(loaded.createdAt, isNotNull);
    });

    test('getById retorna null para id inexistente', () async {
      expect(await repository.getById('nao-existe'), isNull);
    });

    test('searchByName busca por prefixo do nome na cidade', () async {
      const mercadoCentral = StoreModel(
        name: 'Mercado Central',
        city: 'Campinas',
        neighborhood: 'Centro',
        createdBy: 'u1',
      );
      const mercadolivre = StoreModel(
        name: 'Mercadolivre',
        city: 'Campinas',
        neighborhood: 'Centro',
        createdBy: 'u1',
      );
      const outroBairro = StoreModel(
        name: 'Mercado do Bairro',
        city: 'Sorocaba',
        neighborhood: 'Barra',
        createdBy: 'u1',
      );

      await repository.createStore(mercadoCentral);
      await repository.createStore(mercadolivre);
      await repository.createStore(outroBairro);

      final resultado = await repository.searchByName(
        'Campinas',
        'mercaDO ',
      );

      expect(resultado.map((s) => s.name), containsAll(<String>[
        'Mercado Central',
        'Mercadolivre',
      ]));
      expect(resultado, hasLength(2));
      for (final store in resultado) {
        expect(store.city, 'Campinas');
      }

      final vazio = await repository.searchByName('Campinas', '');
      expect(vazio, isEmpty);
    });

    test('watchAll ordena por nome com limite', () async {
      await repository.createStore(const StoreModel(
        name: 'Zupermercado',
        city: 'Campinas',
        neighborhood: 'Centro',
        createdBy: 'u1',
      ));
      await repository.createStore(const StoreModel(
        name: 'Atacadão',
        city: 'Campinas',
        neighborhood: 'Centro',
        createdBy: 'u1',
      ));

      final todas = await repository.watchAll(limit: 50).first;
      expect(todas.map((s) => s.name).toList(), ['Atacadão', 'Zupermercado']);
    });
  });

  group('UserRepository', () {
    late FakeFirebaseFirestore db;
    late UserRepository repository;

    setUp(() {
      db = FakeFirebaseFirestore();
      repository = UserRepository(db);
    });

    test('ensureUserDocument cria documento básico na primeira vez', () async {
      final user = MockUser(uid: 'u1', displayName: 'Ana');

      await repository.ensureUserDocument(user);

      final snapshot = await db.collection('users').doc('u1').get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['displayName'], 'Ana');
      expect(snapshot.data()!['points'], 0);
      expect(snapshot.data()!['createdAt'], isNotNull);

      final model = await repository.getUser('u1');
      expect(model, isNotNull);
      expect(model!.points, 0);
    });

    test('ensureUserDocument PRESERVA points existente em segunda chamada',
        () async {
      final user = MockUser(uid: 'u1', displayName: 'Ana');

      await db.collection('users').doc('u1').set({
        'displayName': 'Nome antigo',
        'points': 77,
        'createdAt': t1,
      });

      await repository.ensureUserDocument(user);
      await repository.ensureUserDocument(user);

      final data = (await db.collection('users').doc('u1').get()).data()!;
      expect(data['points'], 77);
      expect(data['displayName'], 'Ana');

      final model = await repository.getUser('u1');
      expect(model!.points, 77);
    });

    test('watchUser emite null quando doc não existe e modelo quando existe',
        () async {
      final user = MockUser(uid: 'u9', displayName: 'Bob');

      final primeiro = await repository.watchUser('u9').first;
      expect(primeiro, isNull);

      await repository.ensureUserDocument(user);

      final segundo = await repository.watchUser('u9').first;
      expect(segundo, isNotNull);
      expect(segundo!.displayName, 'Bob');
    });
  });
}
