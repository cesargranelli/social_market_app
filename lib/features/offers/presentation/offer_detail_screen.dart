import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/geo_distance.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/utils/time_format.dart';
import '../../stores/data/store_repository.dart';
import '../../stores/domain/store_model.dart';
import '../data/offer_interaction_repository.dart';
import '../data/offer_repository.dart';
import '../domain/offer_comment.dart';
import '../domain/offer_model.dart';
import 'widgets/offer_image.dart';
import 'widgets/offer_status_chip.dart';

/// Carrega a oferta por id (null = não encontrada/excluída).
final _offerByIdProvider = FutureProvider.autoDispose
    .family<OfferModel?, String>((ref, offerId) {
      return ref.watch(offerRepositoryProvider).getById(offerId);
    });

/// Carrega o mercado da oferta para exibir a distância, quando disponível.
final _storeByIdProvider = FutureProvider.autoDispose
    .family<StoreModel?, String>((ref, storeId) {
      return ref.watch(storeRepositoryProvider).getById(storeId);
    });

/// Detalhe de uma oferta: dados completos, curtida, validação da
/// comunidade e comentários.
///
/// Recebe o [offerId] como parâmetro da rota '/oferta/:id'.
class OfferDetailScreen extends ConsumerWidget {
  const OfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<OfferModel?> offerAsync = ref.watch(
      _offerByIdProvider(offerId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da oferta')),
      body: offerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Carregando oferta',
          ),
        ),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  semanticLabel: 'Erro de conexão',
                ),
                const SizedBox(height: 16),
                Text(
                  'Não foi possível carregar esta oferta.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(_offerByIdProvider(offerId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (OfferModel? offer) {
          if (offer == null) return const _OfferNotFoundView();
          return _OfferDetailView(offer: offer);
        },
      ),
    );
  }
}

/// Oferta removida/inexistente: mensagem amigável e volta segura.
class _OfferNotFoundView extends StatelessWidget {
  const _OfferNotFoundView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search_off,
              size: 72,
              color: theme.colorScheme.onSurfaceVariant,
              semanticLabel: 'Oferta não encontrada',
            ),
            const SizedBox(height: 16),
            Text('Oferta não encontrada', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Esta oferta pode ter sido removida pelo autor.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                if (context.canPop()) context.pop();
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conteúdo do detalhe quando a oferta foi carregada.
class _OfferDetailView extends ConsumerWidget {
  const _OfferDetailView({required this.offer});

  final OfferModel offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final StoreModel? store =
        ref.watch(_storeByIdProvider(offer.storeId)).value;
    final Position? userPosition =
        ref.watch(currentPositionProvider).value;
    final double? distanceKm = (store?.geoPoint == null || userPosition == null)
        ? null
        : haversineDistanceKm(
            lat1: userPosition.latitude,
            lon1: userPosition.longitude,
            lat2: store!.geoPoint!.latitude,
            lon2: store.geoPoint!.longitude,
          );
    final bool showRegularPrice =
        offer.regularPrice != null && offer.regularPrice! > offer.price;
    final int? savingsPercent = showRegularPrice
        ? (((offer.regularPrice! - offer.price) / offer.regularPrice!) * 100)
              .round()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OfferImage(imageUrl: offer.imageUrl, semanticLabel: 'Foto do produto'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        offer.productName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (offer.status != OfferStatus.active)
                      OfferStatusChip(status: offer.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      formatBrl(offer.price),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/${offer.unit}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showRegularPrice) ...<Widget>[
                      const SizedBox(width: 8),
                      Text(
                        formatBrl(offer.regularPrice!),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
                if (savingsPercent != null && savingsPercent > 0) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Economize $savingsPercent%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.store,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        offer.storeName.isEmpty
                            ? 'Mercado não informado'
                            : offer.storeName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                if (distanceKm != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Row(
                    key: const Key('offer_detail_distance_row'),
                    children: <Widget>[
                      Icon(
                        Icons.near_me_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Distância: ${formatDistanceKm(distanceKm)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        offer.authorName.isEmpty
                            ? 'Usuário'
                            : offer.authorName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      formatRelativeTime(offer.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _LikeSection(offerId: offer.id ?? ''),
                const Divider(),
                _ValidationSection(
                  offerId: offer.id ?? '',
                  status: offer.status,
                ),
                const Divider(),
                _CommentsSection(offerId: offer.id ?? ''),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Curtida com feedback otimista simples.
///
/// Enquanto o toggle está em voo, exibimos estado local (_optimisticLiked +
/// _countOffset). Quando o stream do servidor confirma o mesmo valor,
/// descartamos o otimismo sem flicker; em erro, revertemos + SnackBar.
class _LikeSection extends ConsumerStatefulWidget {
  const _LikeSection({required this.offerId});

  final String offerId;

  @override
  ConsumerState<_LikeSection> createState() => _LikeSectionState();
}

class _LikeSectionState extends ConsumerState<_LikeSection> {
  bool _busy = false;
  bool? _optimisticLiked;
  int _countOffset = 0;
  bool _awaitingServerAck = false;

  Future<void> _onTogglePressed({required bool streamedLiked}) async {
    if (_busy) return;
    final bool optimisticLiked = !streamedLiked;

    setState(() {
      _busy = true;
      _optimisticLiked = optimisticLiked;
      _countOffset += optimisticLiked ? 1 : -1;
      _awaitingServerAck = true;
    });

    try {
      final bool resultLiked = await ref
          .read(offerInteractionRepositoryProvider)
          .toggleLike(widget.offerId);
      if (!mounted) return;
      // Alinha o otimismo ao resultado real (sem esperar o stream emitir).
      setState(() => _optimisticLiked = resultLiked);
    } catch (error) {
      debugPrint('[OfferDetail] Falha ao registrar curtida: $error');
      if (!mounted) return;
      // Reverte ao último estado confirmado pelo stream.
      setState(() {
        _optimisticLiked = null;
        _countOffset = 0;
        _awaitingServerAck = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text(
              'Não foi possível registrar sua curtida. Tente novamente.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Descarta o estado otimista quando o servidor já confirma o mesmo valor
  /// (atribuição direta, sem setState: os valores derivados deste mesmo
  /// build já saem consistentes, evitando flicker de contagem).
  void _reconcileWithServer(bool streamedLiked) {
    if (_awaitingServerAck &&
        _optimisticLiked != null &&
        streamedLiked == _optimisticLiked) {
      _awaitingServerAck = false;
      _optimisticLiked = null;
      _countOffset = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? uid = ref.watch(authStateChangesProvider).value?.uid;

    if (uid == null || uid.isEmpty) {
      return Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Entre para curtir',
            onPressed: null,
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      );
    }

    final OfferInteractionRepository repository = ref.watch(
      offerInteractionRepositoryProvider,
    );

    return Row(
      children: <Widget>[
        StreamBuilder<bool>(
          stream: repository.hasLiked(widget.offerId, uid),
          builder: (BuildContext context, AsyncSnapshot<bool> likedSnapshot) {
            final bool streamedLiked = likedSnapshot.data ?? false;
            _reconcileWithServer(streamedLiked);

            final bool liked = _optimisticLiked ?? streamedLiked;
            return IconButton(
              key: const Key('offer_detail_like_button'),
              tooltip: liked ? 'Descurtir' : 'Curtir',
              onPressed: _busy
                  ? null
                  : () =>
                        _onTogglePressed(streamedLiked: streamedLiked),
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? theme.colorScheme.primary : null,
              ),
            );
          },
        ),
        StreamBuilder<int>(
          stream: repository.watchLikesCount(widget.offerId),
          builder: (BuildContext context, AsyncSnapshot<int> countSnapshot) {
            final int streamedCount = countSnapshot.data ?? 0;
            final int displayCount =
                streamedCount + _countOffset > 0
                    ? streamedCount + _countOffset
                    : 0;
            return Text(
              '$displayCount',
              style: theme.textTheme.titleMedium,
            );
          },
        ),
      ],
    );
  }
}

/// Validação colaborativa: contador de confirmações em tempo real e botão
/// para confirmar o preço.
///
/// Feedback imediato via estado local otimista: o botão desabilita no
/// toque, antes do ack do servidor. Em erro, o estado reverte com SnackBar
/// amigável. Ofertas expiradas exibem o botão desabilitado com hint
/// explicativo.
class _ValidationSection extends ConsumerStatefulWidget {
  const _ValidationSection({required this.offerId, required this.status});

  final String offerId;
  final OfferStatus status;

  @override
  ConsumerState<_ValidationSection> createState() => _ValidationSectionState();
}

class _ValidationSectionState extends ConsumerState<_ValidationSection> {
  bool _busy = false;

  /// Confirmação otimista: true assim que o usuário toca (feedback
  /// imediato); revertido em erro até o stream confirmar.
  bool _optimisticConfirmed = false;

  Future<void> _confirm() async {
    if (_busy || _optimisticConfirmed) return;
    if (widget.status == OfferStatus.expired) return;

    setState(() {
      _busy = true;
      _optimisticConfirmed = true;
    });

    try {
      await ref
          .read(offerInteractionRepositoryProvider)
          .addConfirmation(widget.offerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Obrigado por validar!'),
          ),
        );
    } catch (error) {
      debugPrint('[OfferDetail] Falha ao registrar confirmação: $error');
      if (!mounted) return;
      // Reverte ao último estado confirmado pelo stream.
      setState(() => _optimisticConfirmed = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text(
              'Não foi possível registrar sua confirmação. Tente novamente.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _countLabel(int count) {
    if (count <= 0) return 'Seja o primeiro a confirmar';
    if (count == 1) return '1 confirmação';
    return '$count confirmações';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? uid = ref.watch(authStateChangesProvider).value?.uid;
    final OfferInteractionRepository repository = ref.watch(
      offerInteractionRepositoryProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Validação da comunidade', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        // Contador de confirmações em tempo real.
        StreamBuilder<int>(
          stream: repository.watchConfirmCount(widget.offerId),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            final int? count = snapshot.data;
            if (count == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return Semantics(
              label: '${_countLabel(count)} da comunidade',
              excludeSemantics: true,
              child: Text(
                _countLabel(count),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: count > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: count > 0 ? FontWeight.w600 : null,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Estado de confirmação do usuário atual + botão.
        StreamBuilder<bool>(
          stream: (uid == null || uid.isEmpty)
              ? null
              : repository.hasConfirmed(widget.offerId, uid),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            final bool streamedConfirmed = snapshot.data ?? false;
            final bool confirmed = _optimisticConfirmed || streamedConfirmed;
            final bool expired = widget.status == OfferStatus.expired;
            final bool signedOut = uid == null || uid.isEmpty;
            final bool enabled =
                !_busy && !confirmed && !expired && !signedOut;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FilledButton.tonalIcon(
                  key: const Key('offer_detail_confirm_button'),
                  onPressed: enabled ? _confirm : null,
                  icon: Icon(
                    confirmed ? Icons.verified : Icons.verified_outlined,
                    semanticLabel:
                        'Confirmar preço desta oferta',
                  ),
                  label: Text(
                    confirmed
                        ? 'Você confirmou esta oferta'
                        : 'Confirmei esse preço',
                  ),
                ),
                if (expired)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Esta oferta expirou e não aceita novas confirmações.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else if (signedOut)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Entre com sua conta para validar esta oferta.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Lista de comentários + campo de envio. Valida não-vazio no cliente
/// (desabilita o botão); após sucesso limpa o campo — o novo comentário
/// chega via stream do repositório.
class _CommentsSection extends ConsumerStatefulWidget {
  const _CommentsSection({required this.offerId});

  final String offerId;

  @override
  ConsumerState<_CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<_CommentsSection> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(offerInteractionRepositoryProvider)
          .addComment(widget.offerId, text);
      if (!mounted) return;
      _controller.clear();
    } catch (error) {
      debugPrint('[OfferDetail] Falha ao enviar comentário: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text(
              'Não foi possível enviar seu comentário. Tente novamente.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final OfferInteractionRepository repository = ref.watch(
      offerInteractionRepositoryProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StreamBuilder<List<OfferComment>>(
          stream: repository.watchComments(widget.offerId),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<OfferComment>> snapshot,
              ) {
                final List<OfferComment>? comments = snapshot.data;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      comments == null
                          ? 'Comentários'
                          : 'Comentários (${comments.length})',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (comments == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (comments.isEmpty)
                      Text(
                        'Nenhum comentário ainda. Inicie a conversa!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      Column(
                        children: <Widget>[
                          for (final OfferComment comment in comments)
                            _CommentTile(comment: comment),
                        ],
                      ),
                  ],
                );
              },
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextFormField(
                key: const Key('offer_detail_comment_field'),
                controller: _controller,
                enabled: !_sending,
                maxLength: 500,
                maxLines: 1,
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _submitComment(),
                decoration: const InputDecoration(
                  labelText: 'Adicione um comentário',
                  hintText: 'Ex.: Confirmei esse preço hoje!',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const Key('offer_detail_send_comment_button'),
              tooltip: 'Enviar comentário',
              onPressed:
                  _sending || _controller.text.trim().isEmpty
                      ? null
                      : _submitComment,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tile de comentário: avatar com inicial, autor, tempo relativo e texto.
class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final OfferComment comment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String author = comment.authorName.isEmpty
        ? 'Usuário'
        : comment.authorName;
    final String initial = author.substring(0, 1).toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 16,
            child: Text(initial, style: theme.textTheme.labelMedium),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        author,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatRelativeTime(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
