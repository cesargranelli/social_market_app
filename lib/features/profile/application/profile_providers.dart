import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';
import '../domain/user_model.dart';

/// Observa o documento do usuário em tempo real (pontos, badges futuros etc.).
///
/// Family por [uid]; autoDispose evita manter streams abertas para uids
/// que saíram da tela.
final watchedUserProfileProvider =
    StreamProvider.autoDispose.family<UserModel?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).watchUser(uid);
});
