import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:social_market_app/core/providers/firebase_providers.dart';
import 'package:social_market_app/core/theme.dart';
import 'package:social_market_app/features/offers/data/offer_repository.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/profile/data/user_repository.dart';
import 'package:social_market_app/features/profile/domain/user_model.dart';
import 'package:social_market_app/features/stores/data/store_repository.dart';
import 'package:social_market_app/features/stores/domain/store_model.dart';

/// Fakes leves usados nos widget tests da Fase 3 (sem Firebase real e sem
/// FakeFirebaseFirestore). Implementam as interfaces concretas dos
/// repositórios, registrando interações para verificação nos testes.

class FakeOfferRepository implements OfferRepository {
  final List<OfferModel> createdOffers = <OfferModel>[];
  final List<String> uploadedImagePaths = <String>[];

  /// Erro (se definido) lançado pela próxima chamada correspondente,
  /// simulando falhas de rede/Firebase nos testes.
  Object? createOfferError;
  Object? uploadOfferError;

  int _nextId = 1;

  @override
  Future<String> createOffer(OfferModel offer) async {
    final Object? error = createOfferError;
    if (error != null) throw error;
    createdOffers.add(offer);
    return 'offer-${_nextId++}';
  }

  @override
  Future<String> uploadOfferImage(String path, XFile file) async {
    // Registra a TENTATIVA mesmo quando falha (permite afirmar que o upload
    // foi acionado antes do erro simulado).
    uploadedImagePaths.add(path);
    final Object? error = uploadOfferError;
    if (error != null) throw error;
    return 'https://example.com/$path';
  }

  @override
  Stream<List<OfferModel>> watchRecent({String? storeId, int limit = 50}) {
    return Stream.value(const <OfferModel>[]);
  }

  @override
  Future<OfferModel?> getById(String id) async => null;

  @override
  Future<void> markExpired(String id) async {}

  @override
  Future<void> deleteOffer(String id) async {}
}

class FakeStoreRepository implements StoreRepository {
  FakeStoreRepository({List<StoreModel> stores = const <StoreModel>[]})
    : _stores = List<StoreModel>.of(stores);

  final List<StoreModel> _stores;
  final List<StoreModel> createdStores = <StoreModel>[];

  /// Registra cada chamada EFETIVA de busca no formato 'cidade|termo'.
  /// Se a tela validar antes de consultar, esta lista permanece vazia.
  final List<String> searchCalls = <String>[];

  int _nextId = 1;

  @override
  Future<List<StoreModel>> searchByName(String city, String query) async {
    searchCalls.add('$city|$query');
    final String term = query.trim().toLowerCase();
    if (term.isEmpty) return const <StoreModel>[];

    return _stores
        .where(
          (StoreModel store) =>
              store.city.toLowerCase() == city.trim().toLowerCase() &&
              store.name.toLowerCase().startsWith(term),
        )
        .toList();
  }

  @override
  Future<StoreModel?> getById(String id) async {
    for (final StoreModel store in _stores) {
      if (store.id == id) return store;
    }
    return null;
  }

  @override
  Future<String> createStore(StoreModel store) async {
    final String id = 'store-${_nextId++}';
    createdStores.add(store);
    _stores.add(
      StoreModel(
        id: id,
        name: store.name,
        city: store.city,
        neighborhood: store.neighborhood,
        address: store.address,
        createdBy: store.createdBy,
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  @override
  Stream<List<StoreModel>> watchAll({int limit = 50}) {
    return Stream.value(_stores.take(limit).toList());
  }
}

class FakeUserRepository implements UserRepository {
  FakeUserRepository({UserModel? profile}) : _profile = profile;

  UserModel? _profile;

  void setProfile(UserModel? profile) => _profile = profile;

  @override
  Stream<UserModel?> watchUser(String uid) async* {
    yield _profileFor(uid);
  }

  @override
  Future<UserModel?> getUser(String uid) async => _profileFor(uid);

  @override
  Future<void> ensureUserDocument(User user) async {}

  UserModel? _profileFor(String uid) {
    final UserModel? profile = _profile;
    if (profile == null || profile.uid != uid) return null;
    return profile;
  }
}

/// Harness com os overrides padrão dos widget tests da Fase 3.
///
/// Simula um usuário autenticado (uid `uid-1`), um perfil com pontos e um
/// catálogo opcional de mercados.
class Phase3TestHarness {
  Phase3TestHarness({
    MockUser? user,
    UserModel? profile,
    List<StoreModel> seedStores = const <StoreModel>[],
  }) : mockUser =
           user ??
           (MockUser(
             uid: 'uid-1',
             displayName: 'Maria Silva',
             email: 'maria@exemplo.com',
           )),
       offersRepository = FakeOfferRepository(),
       storesRepository = FakeStoreRepository(stores: seedStores),
       userRepository = FakeUserRepository() {
    userProfile =
        profile ??
        UserModel(
          uid: mockUser.uid,
          displayName: mockUser.displayName ?? '',
          points: 42,
          createdAt: DateTime(2026, 1, 1),
        );
    userRepository.setProfile(userProfile);
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
  }

  final MockUser mockUser;
  late final UserModel userProfile;
  late final MockFirebaseAuth mockAuth;

  final FakeOfferRepository offersRepository;
  final FakeStoreRepository storesRepository;
  final FakeUserRepository userRepository;

  /// Constrói o app de teste já envolto em [ProviderScope] com todos os
  /// overrides aplicados (o tipo dos elementos é inferido pelo contexto,
  /// pois `Override` não é exportado publicamente no Riverpod 3.x).
  Widget buildTestApp({required Widget home}) {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        authStateChangesProvider.overrideWith(
          (ref) => Stream<User?>.value(mockAuth.currentUser),
        ),
        offerRepositoryProvider.overrideWithValue(offersRepository),
        storeRepositoryProvider.overrideWithValue(storesRepository),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
      child: MaterialApp(theme: appTheme, home: home),
    );
  }
}
