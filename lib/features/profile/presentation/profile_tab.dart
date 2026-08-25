import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../application/profile_providers.dart';
import '../domain/user_model.dart';

/// Aba de perfil: dados de autenticação, pontos e logout.
///
/// Construída com UI própria (sem depender de ProfileScreen do
/// firebase_ui_auth, que exige FirebaseAuth.instance inicializado).
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<User?> authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível carregar seu perfil. '
            'Tente novamente mais tarde.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (User? user) {
        if (user == null) {
          return const Center(child: Text('Nenhum usuário autenticado.'));
        }
        return _ProfileContent(user: user);
      },
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    final String? displayName = user.displayName?.trim();
    final String name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (user.email ?? 'Usuário Social Market');
    final String email = user.email ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const SizedBox(height: 8),
        _buildAvatar(context),
        const SizedBox(height: 16),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        if (email.isNotEmpty)
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        _PointsCard(uid: user.uid),
        const SizedBox(height: 24),
        const Center(child: SignOutButton()),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Avatar com foto quando disponível; fallback com ícone caso não haja
  /// foto ou a URL falhe.
  Widget _buildAvatar(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? photoUrl = user.photoURL;

    final Widget fallback = ColoredBox(
      color: colors.primaryContainer,
      child: Icon(Icons.person, size: 48, color: colors.onPrimaryContainer),
    );

    final Widget content =
        (photoUrl == null || photoUrl.isEmpty)
        ? fallback
        : Image.network(
            photoUrl,
            fit: BoxFit.cover,
            semanticLabel: 'Foto do perfil',
            errorBuilder: (_, _, _) => fallback,
          );

    return Center(
      child: ClipOval(
        child: SizedBox(width: 96, height: 96, child: content),
      ),
    );
  }
}

class _PointsCard extends ConsumerWidget {
  const _PointsCard({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<UserModel?> profileAsync = ref.watch(
      watchedUserProfileProvider(uid),
    );

    final Widget title = profileAsync.when(
      loading: () => Text('Carregando pontos...', style:
          theme.textTheme.titleMedium),
      error: (_, _) => Text(
        'Pontos indisponíveis no momento',
        style: theme.textTheme.titleMedium,
      ),
      data: (UserModel? profile) =>
          Text('${profile?.points ?? 0} pontos', style:
              theme.textTheme.titleMedium),
    );

    return Card(
      margin: const EdgeInsets.only(top: 24),
      child: ListTile(
        leading: Icon(
          Icons.stars,
          size: 36,
          color: theme.colorScheme.primary,
          semanticLabel: 'Pontos',
        ),
        title: title,
        subtitle: const Text('Em breve: badges e ranking!'),
      ),
    );
  }
}
