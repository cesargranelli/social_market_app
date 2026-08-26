import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../application/profile_providers.dart';
import '../domain/user_model.dart';

/// Aba de perfil: dados de autenticação, pontos, badges e ranking da
/// comunidade, além do logout.
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
        _BadgesSection(uid: user.uid),
        const SizedBox(height: 24),
        _RankingSection(currentUid: user.uid),
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
        subtitle: const Text('Ganhe pontos publicando e confirmando ofertas.'),
      ),
    );
  }
}

/// Linha horizontal de chips com os badges conquistados pelo usuário.
///
/// Estados: carregando (spinner compacto), vazio (convite a publicar ofertas)
/// e erro (mensagem discreta — badges são acessório, não bloqueiam o perfil).
class _BadgesSection extends ConsumerWidget {
  const _BadgesSection({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    // hasError vem ANTES de isLoading: com o retry automático do Riverpod 3,
    // um estado em nova tentativa é AsyncLoading(retrying) — sem este guard,
    // a mensagem de erro nunca apareceria entre tentativas.
    //
    // Tipo inferido (sem anotar `List<Badge>`) para NÃO colidir com o widget
    // Badge do Material 3.
    final badgesAsync = ref.watch(userBadgesProvider(uid));
    final Widget content;
    if (badgesAsync.hasError) {
      content = Text(
        'Não foi possível carregar suas conquistas.',
        style: hintStyle,
      );
    } else if (badgesAsync.isLoading) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else {
      final badges = badgesAsync.value ?? const [];
      if (badges.isEmpty) {
        content = Text('Publique ofertas para ganhar badges!', style: hintStyle);
      } else {
        content = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: <Widget>[
              for (final badge in badges)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InputChip(
                    avatar: Icon(badge.icon, size: 18),
                    label: Text(badge.label),
                    onPressed: null, // Chip informativo (não clicável).
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        );
      }
    }

    return Semantics(
      label: 'Conquistas',
      container: true,
      child: content,
    );
  }
}

/// Seção de ranking da comunidade: top 10 usuários por pontos.
///
/// Destaca a linha do usuário logado e usa medalhas (ouro/prata/bronze)
/// para as três primeiras posições. Estados: carregando, vazio e erro
/// amigável.
class _RankingSection extends ConsumerWidget {
  const _RankingSection({required this.currentUid});

  final String currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<UserModel>> rankingAsync = ref.watch(
      topUsersProvider,
    );

    // hasError vem ANTES de isLoading: com o retry automático do Riverpod 3,
    // um estado em nova tentativa é AsyncLoading(retrying) — sem este guard,
    // a mensagem de erro nunca apareceria entre tentativas.
    final Widget content;
    if (rankingAsync.hasError) {
      content = Text(
        'Não foi possível carregar o ranking agora. '
        'Tente novamente mais tarde.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else if (rankingAsync.isLoading) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      final List<UserModel> users = rankingAsync.value ?? const [];
      content =
          users.isEmpty
              ? Text(
                'Ninguém pontuou ainda.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: users.length,
                itemBuilder:
                    (_, int index) => _RankingTile(
                      position: index + 1,
                      user: users[index],
                      isCurrentUser: users[index].uid == currentUid,
                    ),
                separatorBuilder: (_, _) => const SizedBox(height: 4),
              );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.leaderboard,
              size: 22,
              color: theme.colorScheme.primary,
              semanticLabel: 'Ranking',
            ),
            const SizedBox(width: 8),
            Text('Ranking da comunidade', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}

/// Uma linha do ranking: posição (medalha no top 3), nome e pontos.
class _RankingTile extends StatelessWidget {
  const _RankingTile({
    required this.position,
    required this.user,
    required this.isCurrentUser,
  });

  final int position;
  final UserModel user;
  final bool isCurrentUser;

  static const Color _gold = Color(0xFFD4A017);
  static const Color _silver = Color(0xFF8FA3B8);
  static const Color _bronze = Color(0xFFA97142);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String name = user.displayName.trim().isEmpty
        ? 'Usuário'
        : user.displayName.trim();

    final Widget leading = switch (position) {
      1 => const Icon(
        Icons.emoji_events,
        color: _gold,
        semanticLabel: '1º lugar',
      ),
      2 => const Icon(
        Icons.emoji_events,
        color: _silver,
        semanticLabel: '2º lugar',
      ),
      3 => const Icon(
        Icons.emoji_events,
        color: _bronze,
        semanticLabel: '3º lugar',
      ),
      _ => Text(
        '$positionº',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.onSurfaceVariant,
        ),
      ),
    };

    return Semantics(
      label: '$positionº lugar: $name, ${user.points} pontos',
      excludeSemantics: true,
      child: Container(
        key: Key('ranking_row_${user.uid}'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser ? colors.primaryContainer : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: 40, child: Center(child: leading)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isCurrentUser ? FontWeight.bold : null,
                  color: isCurrentUser ? colors.onPrimaryContainer : null,
                ),
              ),
            ),
            Text(
              '${user.points} pts',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isCurrentUser ? colors.onPrimaryContainer : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
