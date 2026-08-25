import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/fake_repositories.dart';
import 'package:social_market_app/core/utils/time_format.dart';
import 'package:social_market_app/features/offers/domain/offer_comment.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/offers/presentation/offer_detail_screen.dart';
import 'package:social_market_app/features/offers/presentation/offers_feed_screen.dart';

/// Bombeia alguns frames discretos (evita pumpAndSettle, que nunca
/// terminaria com spinners/SnackBars na árvore).
Future<void> _pumpFrames(WidgetTester tester, [int frames = 3]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

OfferModel _offer({
  required String id,
  required String productName,
  required double price,
  double? regularPrice,
  required String storeName,
  required String authorName,
  required DateTime createdAt,
  String unit = 'un',
}) => OfferModel(
  id: id,
  productName: productName,
  price: price,
  regularPrice: regularPrice,
  unit: unit,
  storeId: 'store-$id',
  storeName: storeName,
  authorUid: 'autor-$id',
  authorName: authorName,
  createdAt: createdAt,
);

void main() {
  group('OffersFeedScreen', () {
    testWidgets(
      'Teste A: renderiza cards de 2 ofertas e navega para /oferta/:id no tap',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        final DateTime now = DateTime.now();

        harness.offersRepository.recentOffers = <OfferModel>[
          _offer(
            id: 'offer-1',
            productName: 'Café torrado 500 g',
            price: 9.90,
            storeName: 'Bom Preço',
            authorName: 'Maria Silva',
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
          _offer(
            id: 'offer-2',
            productName: 'Arroz tipo 1 5 kg',
            price: 19.99,
            regularPrice: 29.99,
            unit: 'kg',
            storeName: 'Supermercado Central',
            authorName: 'João Souza',
            createdAt: now.subtract(const Duration(days: 3)),
          ),
        ];

        final GoRouter router = GoRouter(
          initialLocation: '/',
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  const Scaffold(body: OffersFeedScreen()),
            ),
            GoRoute(
              path: '/oferta/:id',
              builder: (_, state) => Scaffold(
                body: Center(
                  child: Text('abriu-oferta:${state.pathParameters['id']}'),
                ),
              ),
            ),
          ],
        );

        await tester.binding.setSurfaceSize(const Size(1000, 2200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          harness.wrapWithScope(child: MaterialApp.router(routerConfig: router)),
        );
        await _pumpFrames(tester);

        // Card 1: produto, preço com vírgula, mercado e autor.
        expect(find.text('Café torrado 500 g'), findsOneWidget);
        expect(find.text('R\$ 9,90'), findsOneWidget);
        expect(find.text('Bom Preço'), findsOneWidget);
        expect(find.text('Maria Silva'), findsOneWidget);
        expect(find.text('há 2 h'), findsOneWidget);

        // Card 2: preço regular riscado + tempo relativo em dias.
        expect(find.text('Arroz tipo 1 5 kg'), findsOneWidget);
        expect(find.text('R\$ 19,99'), findsOneWidget);
        expect(find.text('R\$ 29,99'), findsOneWidget);
        expect(find.text('Supermercado Central'), findsOneWidget);
        expect(find.text('João Souza'), findsOneWidget);
        expect(find.text('há 3 d'), findsOneWidget);

        // Tap no card navega para a rota nomeada do detalhe.
        await tester.ensureVisible(find.text('Café torrado 500 g'));
        await tester.tap(find.text('Café torrado 500 g'));
        await _pumpFrames(tester);

        expect(find.text('abriu-oferta:offer-1'), findsOneWidget);
      },
    );

    testWidgets('Teste B: feed vazio mostra empty state convidando a publicar', (
      WidgetTester tester,
    ) async {
      final Phase3TestHarness harness = Phase3TestHarness();

      await tester.pumpWidget(
        harness.buildTestApp(home: const Scaffold(body: OffersFeedScreen())),
      );
      await _pumpFrames(tester);

      expect(find.byIcon(Icons.storefront), findsAtLeastNWidgets(1));
      expect(find.text('Nenhuma oferta publicada ainda.'), findsOneWidget);
      expect(
        find.text('Seja o primeiro a compartilhar uma promoção!'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Teste B: feed em erro mostra retry e re-subescreve ao tentar novamente',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        final DateTime now = DateTime.now();

        harness.offersRepository.watchRecentError = Exception('falha de rede');

        await tester.binding.setSurfaceSize(const Size(1000, 2200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          harness.buildTestApp(home: const Scaffold(body: OffersFeedScreen())),
        );
        await _pumpFrames(tester);

        expect(find.text('Não foi possível carregar as ofertas.'), findsOneWidget);
        expect(find.text('Tentar novamente'), findsOneWidget);

        // Recupera o repositório e aciona o retry -> nova subscrição.
        harness.offersRepository.watchRecentError = null;
        harness.offersRepository.recentOffers = <OfferModel>[
          _offer(
            id: 'offer-1',
            productName: 'Café torrado 500 g',
            price: 9.90,
            storeName: 'Bom Preço',
            authorName: 'Maria Silva',
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
        ];

        await tester.tap(find.byKey(const Key('feed_retry_button')));
        await _pumpFrames(tester);

        expect(find.text('Café torrado 500 g'), findsOneWidget);
        expect(find.text('Tentar novamente'), findsNothing);
      },
    );
  });

  group('OfferDetailScreen', () {
    testWidgets(
      'Teste C: exibe dados + comentários; comentar trima/limpa campo; curtir incrementa contador',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        final DateTime now = DateTime.now();

        harness.offersRepository.offersById = <String, OfferModel>{
          'of1': OfferModel(
            id: 'of1',
            productName: 'Leite integral 1 L',
            price: 4.49,
            regularPrice: 5.99,
            unit: 'L',
            storeId: 'store-1',
            storeName: 'Mercado do Bairro',
            authorUid: 'autor-1',
            authorName: 'Ana Lima',
            createdAt: now.subtract(const Duration(minutes: 5)),
          ),
        };
        harness.interactionsRepository.seed(
          offerId: 'of1',
          likeCount: 3,
          likedByCurrentUser: false,
          comments: <OfferComment>[
            OfferComment(
              id: 'c1',
              uid: 'u2',
              authorName: 'Carlos',
              text: 'Bom preço!',
              createdAt: now.subtract(const Duration(hours: 1)),
            ),
            OfferComment(
              id: 'c2',
              uid: 'u3',
              authorName: 'Bruna',
              text: 'Confirmado, comprei.',
              createdAt: now.subtract(const Duration(minutes: 30)),
            ),
          ],
        );

        await tester.binding.setSurfaceSize(const Size(1000, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          harness.buildTestApp(home: OfferDetailScreen(offerId: 'of1')),
        );
        await _pumpFrames(tester);

        // Dados da oferta.
        expect(find.text('Leite integral 1 L'), findsOneWidget);
        expect(find.text('R\$ 4,49'), findsOneWidget);
        expect(find.text('R\$ 5,99'), findsOneWidget);
        expect(find.text('Economize 25%'), findsOneWidget);
        expect(find.text('Mercado do Bairro'), findsOneWidget);
        expect(find.text('Ana Lima'), findsOneWidget);
        expect(find.text('há 5 min'), findsOneWidget);

        // Comentários vindos do fake (header com contador).
        expect(find.text('Comentários (2)'), findsOneWidget);
        expect(find.text('Carlos'), findsOneWidget);
        expect(find.text('Bom preço!'), findsOneWidget);
        expect(find.text('Bruna'), findsOneWidget);
        expect(find.text('Confirmado, comprei.'), findsOneWidget);

        // Contagem inicial de curtidas.
        expect(find.text('3'), findsOneWidget);

        // --- Envia um comentário com espaços nas pontas. ---
        await tester.enterText(
          find.byKey(const Key('offer_detail_comment_field')),
          '  Ótimo achei!  ',
        );
        await _pumpFrames(tester); // onChanged habilita o botão.

        await tester.tap(
          find.byKey(const Key('offer_detail_send_comment_button')),
        );
        await _pumpFrames(tester, 4);

        expect(harness.interactionsRepository.addCommentCalls, hasLength(1));
        expect(harness.interactionsRepository.addCommentCalls.single.offerId, 'of1');
        expect(harness.interactionsRepository.addCommentCalls.single.text, 'Ótimo achei!');

        // Lista atualizada via stream + campo limpo após envio.
        expect(find.text('Comentários (3)'), findsOneWidget);
        final TextFormField field = tester.widget<TextFormField>(
          find.byKey(const Key('offer_detail_comment_field')),
        );
        expect(field.controller!.text, isEmpty);

        // --- Curte a oferta (feedback otimista + confirmação do fake). ---
        await tester.tap(find.byKey(const Key('offer_detail_like_button')));
        await _pumpFrames(tester, 4);

        expect(harness.interactionsRepository.toggleLikeCalls, hasLength(1));
        expect(harness.interactionsRepository.toggleLikeCalls.single.offerId, 'of1');
        expect(harness.interactionsRepository.toggleLikeCalls.single.liked, isTrue);

        // Contador exibido incrementou de 3 para 4.
        expect(find.text('4'), findsOneWidget);

        // Ícone de favorito preenchido após a curtida.
        final IconButton likeButton = tester.widget<IconButton>(
          find.byKey(const Key('offer_detail_like_button')),
        );
        expect((likeButton.icon as Icon).icon, Icons.favorite);
      },
    );

    testWidgets('Teste C: oferta inexistente mostra estado amigável', (
      WidgetTester tester,
    ) async {
      final Phase3TestHarness harness = Phase3TestHarness();

      await tester.pumpWidget(
        harness.buildTestApp(home: OfferDetailScreen(offerId: 'fantasma')),
      );
      await _pumpFrames(tester);

      expect(find.text('Oferta não encontrada'), findsOneWidget);
      expect(
        find.text('Esta oferta pode ter sido removida pelo autor.'),
        findsOneWidget,
      );
    });
  });

  group('formatRelativeTime (Teste D)', () {
    final DateTime now = DateTime(2026, 8, 25, 12, 0, 0);

    test('retorna "agora" para nulo, futuro e menos de 1 minuto', () {
      expect(formatRelativeTime(null, now: now), 'agora');
      expect(formatRelativeTime(now, now: now), 'agora');
      expect(
        formatRelativeTime(now.add(const Duration(seconds: 10)), now: now),
        'agora',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(seconds: 59)), now: now),
        'agora',
      );
    });

    test('minutos: "há X min" abaixo de 1 hora', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(minutes: 5)), now: now),
        'há 5 min',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(minutes: 59)), now: now),
        'há 59 min',
      );
    });

    test('horas: "há X h" abaixo de 24 horas', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(hours: 2)), now: now),
        'há 2 h',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(hours: 23)), now: now),
        'há 23 h',
      );
    });

    test('dias: "há X d" abaixo de 30 dias', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 3)), now: now),
        'há 3 d',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 29)), now: now),
        'há 29 d',
      );
    });

    test('acima de 30 dias cai para data absoluta dd/MM/yyyy', () {
      expect(
        formatRelativeTime(DateTime(2026, 7, 15), now: now),
        '15/07/2026',
      );
    });
  });
}
