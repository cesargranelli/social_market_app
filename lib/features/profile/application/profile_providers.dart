import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../offers/data/offer_interaction_repository.dart';
import '../../offers/data/offer_repository.dart';
import '../data/user_repository.dart';
import '../domain/badges.dart';
import '../domain/user_model.dart';

/// Observa o documento do usuário em tempo real (pontos, badges futuros etc.).
///
/// Family por [uid]; autoDispose evita manter streams abertas para uids
/// que saíram da tela.
final watchedUserProfileProvider =
    StreamProvider.autoDispose.family<UserModel?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).watchUser(uid);
});

/// Ranking global da comunidade: top 10 usuários ordenados por pontos,
/// atualizado em tempo real via stream do [UserRepository].
final topUsersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return ref.watch(userRepositoryProvider).watchTopUsers(limit: 10);
});

/// Badges conquistados pelo usuário [uid], computados a partir dos contadores
/// agregados de ofertas publicadas, ofertas verificadas e comentários.
///
/// Family por [uid]; autoDispose libera os Futures quando ninguém observa.
final userBadgesProvider = FutureProvider.autoDispose
    .family<List<Badge>, String>((ref, uid) async {
  final OfferRepository offers = ref.watch(offerRepositoryProvider);
  final OfferInteractionRepository interactions = ref.watch(
    offerInteractionRepositoryProvider,
  );

  final List<int> counts = await Future.wait<int>(<Future<int>>[
    offers.countOffersByAuthor(uid),
    offers.countVerifiedByAuthor(uid),
    interactions.countCommentsByAuthor(uid),
  ]);

  return computeBadges(
    offersCount: counts[0],
    verifiedCount: counts[1],
    commentsCount: counts[2],
  );
});
