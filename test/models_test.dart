import 'package:flutter_test/flutter_test.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/profile/domain/points_log_entry.dart';
import 'package:social_market_app/features/profile/domain/user_model.dart';
import 'package:social_market_app/features/stores/domain/store_model.dart';

void main() {
  final fixedDate = DateTime.utc(2026, 1, 15, 10, 30);
  final expiryDate = DateTime.utc(2026, 1, 20, 23, 59);

  group('UserModel', () {
    final user = UserModel(
      uid: 'u1',
      displayName: 'Ana',
      photoUrl: 'https://exemplo.com/foto.png',
      points: 42,
      createdAt: fixedDate,
    );

    test('roundtrip toMap/fromMap preserva campos', () {
      final restored = UserModel.fromMap(user.uid, user.toMap());

      expect(restored, user);
      expect(restored.uid, 'u1');
      expect(restored.displayName, 'Ana');
      expect(restored.photoUrl, 'https://exemplo.com/foto.png');
      expect(restored.points, 42);
      expect(restored.createdAt, fixedDate);
    });

    test('fromMap tolera campos ausentes com defaults', () {
      final minimal = UserModel.fromMap('u2', {
        'createdAt': DateTime.utc(2026, 2, 1),
      });

      expect(minimal.displayName, '');
      expect(minimal.points, 0);
      expect(minimal.photoUrl, isNull);
    });

    test('copyWith altera somente o campo informado', () {
      final updated = user.copyWith(points: 100);

      expect(updated.points, 100);
      expect(updated.uid, user.uid);
      expect(updated.displayName, user.displayName);
    });
  });

  group('StoreModel', () {
    const store = StoreModel(
      id: 's1',
      name: 'Mercado Central',
      city: 'Campinas',
      neighborhood: 'Centro',
      address: 'Rua X, 123',
      createdBy: 'u1',
    );

    test('roundtrip toMap/fromMap preserva campos', () {
      final withDate = store.copyWith(createdAt: fixedDate);
      final restored = StoreModel.fromMap('s1', withDate.toMap());

      expect(restored, withDate);
    });

    test('fromMap aceita createdAt ausente', () {
      final restored = StoreModel.fromMap('s1', store.toMap());

      expect(restored.createdAt, isNull);
      expect(restored.address, 'Rua X, 123');
    });

    test('copyWith remove endereço via null explícito não é necessário', () {
      final updated = store.copyWith(name: 'Mercado Novo');

      expect(updated.name, 'Mercado Novo');
      expect(updated.city, store.city);
      expect(updated.id, 's1');
    });
  });

  group('OfferModel', () {
    OfferModel buildOffer() => OfferModel(
      id: 'o1',
      productName: 'Arroz 5kg',
      price: 19.9,
      regularPrice: 24.9,
      unit: 'un',
      storeId: 's1',
      authorUid: 'u1',
      imageUrl: 'https://exemplo.com/arroz.jpg',
      createdAt: fixedDate,
      confirmCount: 0,
      status: OfferStatus.active,
      expiresAt: expiryDate,
    );

    test('roundtrip toMap/fromMap preserva campos e status', () {
      final offer = buildOffer();
      final restored = OfferModel.fromMap('o1', offer.toMap());

      expect(restored, offer);
      expect(restored.status, OfferStatus.active);
      expect(restored.expiresAt, expiryDate);
    });

    test('defaults aplicados quando ausentes no map', () {
      final restored = OfferModel.fromMap('o2', {
        'productName': 'Feijão',
        'price': 7.5,
        'storeId': 's1',
        'authorUid': 'u1',
        'createdAt': fixedDate,
      });

      expect(restored.unit, 'un');
      expect(restored.confirmCount, 0);
      expect(restored.status, OfferStatus.active);
      expect(restored.regularPrice, isNull);
      expect(restored.expiresAt, isNull);
    });

    test('price <= 0 é rejeitado', () {
      expect(() => buildOffer().copyWith(price: 0), throwsArgumentError);
      expect(() => buildOffer().copyWith(price: -3.0), throwsArgumentError);
    });

    test('productName vazio é rejeitado', () {
      expect(
        () => buildOffer().copyWith(productName: ''),
        throwsArgumentError,
      );
      expect(() => buildOffer().copyWith(productName: '   '), throwsArgumentError);
    });

    test('OfferStatus converte de/para string', () {
      expect(OfferStatus.fromString('active'), OfferStatus.active);
      expect(OfferStatus.fromString('expired'), OfferStatus.expired);
      expect(OfferStatus.active.name, 'active');
      expect(() => OfferStatus.fromString('invalido'), throwsArgumentError);
    });

    test('isExpired reflete status', () {
      expect(buildOffer().isExpired, isFalse);
      expect(
        buildOffer().copyWith(status: OfferStatus.expired).isExpired,
        isTrue,
      );
    });
  });

  group('PointsLogEntry', () {
    test('roundtrip toMap/fromMap preserva campos', () {
      final withDate = PointsLogEntry(
        reason: 'oferta confirmada',
        delta: 10,
        at: fixedDate,
      );

      final restored = PointsLogEntry.fromMap(withDate.toMap());

      expect(restored, withDate);
    });
  });
}
