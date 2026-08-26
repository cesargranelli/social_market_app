import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:social_market_app/core/providers/firebase_providers.dart';
import 'package:social_market_app/core/theme.dart';
import 'package:social_market_app/features/offers/data/offer_interaction_repository.dart';
import 'package:social_market_app/features/offers/data/offer_repository.dart';
import 'package:social_market_app/features/offers/domain/offer_comment.dart';
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

  /// Ofertas devolvidas por [watchRecent] e [getById] (configuráveis por
  /// teste antes do pumpWidget).
  List<OfferModel> recentOffers = const <OfferModel>[];
  Map<String, OfferModel> offersById = const <String, OfferModel>{};

  /// Erro (se definido) lançado pela próxima chamada correspondente,
  /// simulando falhas de rede/Firebase nos testes.
  Object? createOfferError;
  Object? uploadOfferError;
  Object? watchRecentError;

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
    final Object? error = watchRecentError;
    if (error != null) return Stream<List<OfferModel>>.error(error);
    return Stream<List<OfferModel>>.value(
      List<OfferModel>.of(recentOffers.take(limit)),
    );
  }

  @override
  Future<OfferModel?> getById(String id) async => offersById[id];

  @override
  Future<void> markExpired(String id) async {}

  @override
  Future<void> deleteOffer(String id) async {}
}

/// Fake leve de [OfferInteractionRepository]: mantém estado interno de
/// curtidas/comentários/confirmações e emite atualizações pelos streams,
/// como o Firestore faria. Chamadas e erros são registrados/forçáveis nos
/// testes.
///
/// Limitação assumida: `hasLiked`/`hasConfirmed` refletem apenas o usuário
/// atual ([currentUid]) — suficiente para os widget tests.
class FakeOfferInteractionRepository implements OfferInteractionRepository {
  FakeOfferInteractionRepository({
    this.currentUid = 'uid-1',
    this.currentUserName = 'Maria Silva',
  });

  final String currentUid;
  final String currentUserName;

  final List<({String offerId, bool liked})> toggleLikeCalls =
      <({String offerId, bool liked})>[];
  final List<({String offerId, String text})> addCommentCalls =
      <({String offerId, String text})>[];
  final List<String> addConfirmationCalls = <String>[];

  Object? toggleLikeError;
  Object? addCommentError;

  /// Erro (se definido) lançado pela próxima [addConfirmation] — a chamada
  /// é registrada ANTES do throw (permite afirmar que foi tentada).
  Object? addConfirmationError;

  final Map<String, Set<String>> _likedBy = <String, Set<String>>{};
  final Map<String, int> _likeCounts = <String, int>{};
  final Map<String, List<OfferComment>> _comments =
      <String, List<OfferComment>>{};

  final Map<String, List<StreamController<int>>> _countSubscribers =
      <String, List<StreamController<int>>>{};
  final Map<String, List<StreamController<bool>>> _hasLikedSubscribers =
      <String, List<StreamController<bool>>>{};
  final Map<String, List<StreamController<List<OfferComment>>>>
  _commentSubscribers =
      <String, List<StreamController<List<OfferComment>>>>{};
  final Map<String, Set<String>> _confirmedBy = <String, Set<String>>{};
  final Map<String, List<StreamController<int>>> _confirmCountSubscribers =
      <String, List<StreamController<int>>>{};
  final Map<String, List<StreamController<bool>>> _hasConfirmedSubscribers =
      <String, List<StreamController<bool>>>{};

  int _nextCommentId = 1;

  /// Semeia o estado inicial de uma oferta (chamar ANTES do pumpWidget).
  ///
  /// [confirmCount] é a contagem TOTAL de confirmações; se
  /// [confirmedByCurrentUser] for true, o próprio uid conta como uma delas
  /// e o restante é preenchido com uids sintéticos.
  void seed({
    required String offerId,
    int likeCount = 0,
    bool likedByCurrentUser = false,
    List<OfferComment> comments = const <OfferComment>[],
    int confirmCount = 0,
    bool confirmedByCurrentUser = false,
  }) {
    _likeCounts[offerId] = likeCount;
    final Set<String> liked = _likedBy.putIfAbsent(offerId, () => <String>{});
    if (likedByCurrentUser) liked.add(currentUid);
    _comments[offerId] = List<OfferComment>.of(comments);

    final Set<String> confirmed = <String>{};
    if (confirmedByCurrentUser) confirmed.add(currentUid);
    int extras = confirmCount - confirmed.length;
    for (int i = 0; i < extras; i++) {
      confirmed.add('uid-confirmacao-$i');
    }
    _confirmedBy[offerId] = confirmed;
  }

  @override
  Future<bool> toggleLike(String offerId) async {
    final Object? error = toggleLikeError;
    if (error != null) throw error;

    final Set<String> liked = _likedBy.putIfAbsent(offerId, () => <String>{});
    bool nowLiked;
    if (liked.contains(currentUid)) {
      liked.remove(currentUid);
      nowLiked = false;
      _likeCounts[offerId] = (_likeCounts[offerId] ?? 1) - 1;
    } else {
      liked.add(currentUid);
      nowLiked = true;
      _likeCounts[offerId] = (_likeCounts[offerId] ?? 0) + 1;    }
    toggleLikeCalls.add((offerId: offerId, liked: nowLiked));

    for (final StreamController<bool> controller
        in _hasLikedSubscribers[offerId] ?? const <StreamController<bool>>[]) {
      controller.add(nowLiked);
    }
    for (final StreamController<int> controller
        in _countSubscribers[offerId] ?? const <StreamController<int>>[]) {
      controller.add(_likeCounts[offerId] ?? 0);
    }
    return nowLiked;
  }

  @override
  Stream<int> watchLikesCount(String offerId) {
    final StreamController<int> controller = StreamController<int>();
    controller.add(_likeCounts[offerId] ?? 0);
    _countSubscribers.putIfAbsent(offerId, () => <StreamController<int>>[])
        .add(controller);
    return controller.stream;
  }

  @override
  Stream<bool> hasLiked(String offerId, String uid) {
    final StreamController<bool> controller = StreamController<bool>();
    controller.add(
      (_likedBy[offerId] ?? const <String>{}).contains(currentUid),
    );
    _hasLikedSubscribers
        .putIfAbsent(offerId, () => <StreamController<bool>>[])
        .add(controller);
    return controller.stream;
  }

  @override
  Future<void> addComment(String offerId, String text) async {
    final Object? error = addCommentError;
    if (error != null) throw error;

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

    addCommentCalls.add((offerId: offerId, text: trimmed));
    final OfferComment comment = OfferComment(
      id: 'comment-${_nextCommentId++}',
      uid: currentUid,
      authorName: currentUserName,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    _comments
        .putIfAbsent(offerId, () => <OfferComment>[])
        .add(comment);

    for (final StreamController<List<OfferComment>> controller
        in _commentSubscribers[offerId] ??
            const <StreamController<List<OfferComment>>>[]) {
      controller.add(List<OfferComment>.unmodifiable(_comments[offerId]!));
    }
  }

  @override
  Stream<List<OfferComment>> watchComments(String offerId) {
    final StreamController<List<OfferComment>> controller =
        StreamController<List<OfferComment>>();
    controller.add(List<OfferComment>.unmodifiable(_comments[offerId] ?? const <OfferComment>[]));
    _commentSubscribers
        .putIfAbsent(offerId, () => <StreamController<List<OfferComment>>>[])
        .add(controller);
    return controller.stream;
  }

  @override
  Future<void> addConfirmation(String offerId) async {
    // Registra a TENTATIVA mesmo quando falha (mesmo padrão do upload).
    addConfirmationCalls.add(offerId);
    final Object? error = addConfirmationError;
    if (error != null) throw error;

    final Set<String> confirmed = _confirmedBy.putIfAbsent(
      offerId,
      () => <String>{},
    );
    confirmed.add(currentUid);
    _notifyConfirmationsChanged(offerId);
  }

  @override
  Stream<bool> hasConfirmed(String offerId, String uid) {
    final StreamController<bool> controller = StreamController<bool>();
    controller.add((_confirmedBy[offerId] ?? const <String>{}).contains(uid));
    _hasConfirmedSubscribers
        .putIfAbsent(offerId, () => <StreamController<bool>>[])
        .add(controller);
    return controller.stream;
  }

  @override
  Stream<int> watchConfirmCount(String offerId) {
    final StreamController<int> controller = StreamController<int>();
    controller.add(_confirmedBy[offerId]?.length ?? 0);
    _confirmCountSubscribers
        .putIfAbsent(offerId, () => <StreamController<int>>[])
        .add(controller);
    return controller.stream;
  }

  /// Reemite contagem/estado de confirmação para os subscribers ativos,
  /// simulando o snapshot do Firestore após a escrita.
  void _notifyConfirmationsChanged(String offerId) {
    final Set<String> confirmed =
        _confirmedBy[offerId] ?? const <String>{};
    for (final StreamController<int> controller
        in _confirmCountSubscribers[offerId] ??
            const <StreamController<int>>[]) {
      controller.add(confirmed.length);
    }
    for (final StreamController<bool> controller
        in _hasConfirmedSubscribers[offerId] ??
            const <StreamController<bool>>[]) {
      controller.add(confirmed.contains(currentUid));
    }
  }
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
/// Simula um usuário autenticado (uid `uid-1`), um perfil com pontos, um
/// catálogo opcional de mercados e um repositório de interações fake.
class Phase3TestHarness {
  Phase3TestHarness({
    MockUser? user,
    UserModel? profile,
    List<StoreModel> seedStores = const <StoreModel>[],
    FakeOfferInteractionRepository? interactions,
  }) : mockUser =
           user ??
           (MockUser(
             uid: 'uid-1',
             displayName: 'Maria Silva',
             email: 'maria@exemplo.com',
           )),
       offersRepository = FakeOfferRepository(),
       storesRepository = FakeStoreRepository(stores: seedStores),
       userRepository = FakeUserRepository(),
       interactionsRepository =
           interactions ?? FakeOfferInteractionRepository() {
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
  final FakeOfferInteractionRepository interactionsRepository;

  /// Constrói o app de teste já envolto em [ProviderScope] com todos os
  /// overrides aplicados (o tipo dos elementos é inferido pelo contexto,
  /// pois `Override` não é exportado publicamente no Riverpod 3.x).
  Widget buildTestApp({required Widget home}) {
    return wrapWithScope(child: MaterialApp(theme: appTheme, home: home));
  }

  /// Envolve [child] apenas no [ProviderScope] com os overrides do harness
  /// — útil com `MaterialApp.router`/`GoRouter` nos testes de navegação.
  Widget wrapWithScope({required Widget child}) {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        authStateChangesProvider.overrideWith(
          (ref) => Stream<User?>.value(mockAuth.currentUser),
        ),
        offerRepositoryProvider.overrideWithValue(offersRepository),
        offerInteractionRepositoryProvider.overrideWithValue(
          interactionsRepository,
        ),
        storeRepositoryProvider.overrideWithValue(storesRepository),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
      child: child,
    );
  }
}
