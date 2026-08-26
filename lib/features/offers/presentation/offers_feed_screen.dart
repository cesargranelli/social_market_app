import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money_format.dart';
import '../../../core/utils/time_format.dart';
import '../data/offer_repository.dart';
import '../domain/offer_model.dart';
import 'widgets/offer_image.dart';
import 'widgets/offer_status_chip.dart';

/// Stream das ofertas mais recentes, indexado pela "geração" de subscrição.
/// Ao incrementar a geração (botão Tentar novamente), o provider devolve um
/// NOVO stream — re-subscrito no Firestore sem recarregar a tela inteira.
final _recentOffersStreamProvider = Provider.autoDispose
    .family<Stream<List<OfferModel>>, int>((ref, generation) {
      return ref.watch(offerRepositoryProvider).watchRecent(limit: 50);
    });

/// Feed principal com as ofertas recentes da comunidade.
///
/// Estados: carregando (spinner central), vazio (convite à primeira oferta),
/// erro (mensagem amigável + retry com nova subscrição) e dados
/// ([ListView.builder] de [_OfferCard] navegando para '/oferta/{id}').
class OffersFeedScreen extends ConsumerStatefulWidget {
  const OffersFeedScreen({super.key});

  @override
  ConsumerState<OffersFeedScreen> createState() => _OffersFeedScreenState();
}

class _OffersFeedScreenState extends ConsumerState<OffersFeedScreen> {
  int _generation = 0;

  void _retry() => setState(() => _generation++);

  @override
  Widget build(BuildContext context) {
    final Stream<List<OfferModel>> offersStream = ref.watch(
      _recentOffersStreamProvider(_generation),
    );

    return StreamBuilder<List<OfferModel>>(
      stream: offersStream,
      builder: (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
        if (snapshot.hasError) {
          return _FeedErrorView(onRetry: _retry);
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Carregando ofertas'),
          );
        }

        final List<OfferModel> offers =
            snapshot.data ?? const <OfferModel>[];

        if (offers.isEmpty) {
          return const _FeedEmptyView();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: offers.length,
          itemBuilder: (BuildContext context, int index) {
            final OfferModel offer = offers[index];
            return _OfferCard(
              offer: offer,
              onTap: () {
                final String? id = offer.id;
                if (id == null || id.isEmpty) return;
                context.push('/oferta/$id');
              },
            );
          },
        );
      },
    );
  }
}

/// Estado vazio: convida o usuário a publicar a primeira promoção.
class _FeedEmptyView extends StatelessWidget {
  const _FeedEmptyView();

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
              Icons.storefront,
              size: 72,
              color: theme.colorScheme.primary,
              semanticLabel: 'Lojas',
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma oferta publicada ainda.',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Seja o primeiro a compartilhar uma promoção!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de erro do stream, com retry que gera nova subscrição.
class _FeedErrorView extends StatelessWidget {
  const _FeedErrorView({required this.onRetry});

  final VoidCallback onRetry;

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
              Icons.cloud_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
              semanticLabel: 'Erro de conexão',
            ),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar as ofertas.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('feed_retry_button'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de oferta do feed: foto/placeholder, produto, preços, mercado,
/// autor e tempo relativo. Chips de status (expirada/verificada) são
/// apenas indicativos — o card segue clicável — e ofertas com confirmações
/// exibem um mini-indicador com a contagem.
class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.onTap});

  final OfferModel offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool showRegularPrice =
        offer.regularPrice != null && offer.regularPrice! > offer.price;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OfferImage(imageUrl: offer.imageUrl),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                    Expanded(
                      child: Text(
                        offer.productName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (offer.status != OfferStatus.active)
                      OfferStatusChip(status: offer.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        formatBrl(offer.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '/${offer.unit}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (showRegularPrice) ...<Widget>[
                        const SizedBox(width: 8),
                        Text(
                          formatBrl(offer.regularPrice!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.store,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          offer.storeName.isEmpty
                              ? 'Mercado não informado'
                              : offer.storeName,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Mini-indicador de validação da comunidade.
                      if (offer.confirmCount > 0) ...<Widget>[
                        const SizedBox(width: 8),
                        Semantics(
                          label:
                              '${offer.confirmCount} confirmações da comunidade',
                          excludeSemantics: true,
                          child: Row(
                            key: const Key('offer_card_confirm_indicator'),
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.green.shade700,
                                semanticLabel: 'Confirmações',
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${offer.confirmCount}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          offer.authorName.isEmpty
                              ? 'Usuário'
                              : offer.authorName,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
