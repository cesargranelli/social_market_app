import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_repositories.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/offers/presentation/offer_detail_screen.dart';
import 'package:social_market_app/features/offers/presentation/offers_feed_screen.dart';

/// Widget tests da validação colaborativa (confirmações + badges).
///
/// Usa o mesmo harness da Fase 3: usuário autenticado `uid-1` e
/// [FakeOfferInteractionRepository] com seed de confirmações e erro
/// forçável ([FakeOfferInteractionRepository.addConfirmationError]).
void main() {
  // Bombeia alguns frames discretos (evita pumpAndSettle, que nunca
  // terminaria com spinners/SnackBars na árvore).
  Future<void> pumpFrames(WidgetTester tester, [int frames = 3]) async {
    for (int i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  OfferModel offer({
    required String id,
    String productName = 'Café torrado 500 g',
    double price = 9.90,
    int confirmCount = 0,
    OfferStatus status = OfferStatus.active,
  }) => OfferModel(
    id: id,
    productName: productName,
    price: price,
    storeId: 'store-$id',
    storeName: 'Bom Preço',
    authorUid: 'autor-$id',
    authorName: 'Maria Silva',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    confirmCount: confirmCount,
    status: status,
  );

  group('OfferDetailScreen — Validação da comunidade', () {
    Future<void> pumpDetail(
      WidgetTester tester,
      Phase3TestHarness harness,
      String offerId,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        harness.buildTestApp(home: OfferDetailScreen(offerId: offerId)),
      );
      await pumpFrames(tester);
    }

    testWidgets(
      'contador plural + botão habilitado; ao tocar registra confirmação, '
      'mostra agradecimento e desabilita como "Você confirmou esta oferta"',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        harness.offersRepository.offersById = <String, OfferModel>{
          'of1': offer(id: 'of1'),
        };
        harness.interactionsRepository.seed(
          offerId: 'of1',
          confirmCount: 2,
        );
        await pumpDetail(tester, harness, 'of1');

        // Contador em tempo real do fake (plural).
        expect(find.text('Validação da comunidade'), findsOneWidget);
        expect(find.text('2 confirmações'), findsOneWidget);

        // Botão inicial: habilitado com call-to-action.
        final Key buttonKey = const Key('offer_detail_confirm_button');
        FilledButton button = tester.widget<FilledButton>(
          find.byKey(buttonKey),
        );
        expect(button.onPressed, isNotNull);
        expect(find.text('Confirmei esse preço'), findsOneWidget);

        // --- Confirma o preço. ---
        await tester.tap(find.byKey(buttonKey));
        await pumpFrames(tester, 4);

        // Repositório recebeu exatamente UMA chamada para a oferta certa.
        expect(harness.interactionsRepository.addConfirmationCalls, <String>[
          'of1',
        ]);

        // Feedback imediato: botão desabilita e muda de rótulo.
        button = tester.widget<FilledButton>(find.byKey(buttonKey));
        expect(button.onPressed, isNull);
        expect(find.text('Você confirmou esta oferta'), findsOneWidget);
        expect(find.text('Confirmei esse preço'), findsNothing);

        // Snackbar de agradecimento + contagem atualizada pelo stream.
        expect(find.text('Obrigado por validar!'), findsOneWidget);
        expect(find.text('3 confirmações'), findsOneWidget);
      },
    );

    testWidgets(
      'singular ("1 confirmação") quando já há uma; usuário que confirmou '
      'vê botão desabilitado e nenhuma nova chamada',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        harness.offersRepository.offersById = <String, OfferModel>{
          'of2': offer(id: 'of2'),
        };
        harness.interactionsRepository.seed(
          offerId: 'of2',
          confirmCount: 1,
          confirmedByCurrentUser: true,
        );
        await pumpDetail(tester, harness, 'of2');

        expect(find.text('1 confirmação'), findsOneWidget);
        expect(find.text('Você confirmou esta oferta'), findsOneWidget);

        final Key buttonKey = const Key('offer_detail_confirm_button');
        final FilledButton button = tester.widget<FilledButton>(
          find.byKey(buttonKey),
        );
        expect(button.onPressed, isNull);

        // Nenhuma confirmação registrada (usuário já tinha confirmado).
        expect(
          harness.interactionsRepository.addConfirmationCalls,
          isEmpty,
        );
      },
    );

    testWidgets(
      'oferta expirada: botão desabilitado com hint e sem chamadas',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        harness.offersRepository.offersById = <String, OfferModel>{
          'of3': offer(id: 'of3', status: OfferStatus.expired),
        };
        harness.interactionsRepository.seed(offerId: 'of3');
        await pumpDetail(tester, harness, 'of3');

        expect(find.text('Seja o primeiro a confirmar'), findsOneWidget);
        expect(find.text('Confirmei esse preço'), findsOneWidget);
        expect(
          find.text('Esta oferta expirou e não aceita novas confirmações.'),
          findsOneWidget,
        );

        final Key buttonKey = const Key('offer_detail_confirm_button');
        final FilledButton button = tester.widget<FilledButton>(
          find.byKey(buttonKey),
        );
        expect(button.onPressed, isNull);
        expect(
          harness.interactionsRepository.addConfirmationCalls,
          isEmpty,
        );
      },
    );

    testWidgets(
      'erro do repositório: SnackBar amigável, estado reverte e nada crasha',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        harness.offersRepository.offersById = <String, OfferModel>{
          'of4': offer(id: 'of4'),
        };
        harness.interactionsRepository.seed(offerId: 'of4');
        harness.interactionsRepository.addConfirmationError = Exception(
          'firestore down',
        );
        await pumpDetail(tester, harness, 'of4');

        expect(find.text('Seja o primeiro a confirmar'), findsOneWidget);

        final Key buttonKey = const Key('offer_detail_confirm_button');
        await tester.tap(find.byKey(buttonKey));
        await pumpFrames(tester, 4);

        // A tentativa foi registrada antes do throw.
        expect(harness.interactionsRepository.addConfirmationCalls, <String>[
          'of4',
        ]);

        // SnackBar de erro amigável.
        expect(
          find.text(
            'Não foi possível registrar sua confirmação. Tente novamente.',
          ),
          findsOneWidget,
        );
        expect(find.text('Obrigado por validar!'), findsNothing);

        // Estado revertido: botão volta habilitado e contagem intacta.
        final FilledButton button = tester.widget<FilledButton>(
          find.byKey(buttonKey),
        );
        expect(button.onPressed, isNotNull);
        expect(find.text('Confirmei esse preço'), findsOneWidget);
        expect(find.text('Você confirmou esta oferta'), findsNothing);
        expect(find.text('Seja o primeiro a confirmar'), findsOneWidget);
      },
    );

    testWidgets(
      'oferta verified exibe badge verde no header e mantém seção ativa',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        harness.offersRepository.offersById = <String, OfferModel>{
          'of5': offer(id: 'of5', status: OfferStatus.verified),
        };
        harness.interactionsRepository.seed(offerId: 'of5');
        await pumpDetail(tester, harness, 'of5');

        expect(find.text('Verificada pela comunidade'), findsOneWidget);
        expect(find.byKey(const Key('offer_verified_chip')), findsOneWidget);
        expect(find.byKey(const Key('offer_expired_chip')), findsNothing);
        expect(find.byIcon(Icons.verified), findsOneWidget);

        // Sem confirmações ainda: convite continua visível.
        expect(find.text('Seja o primeiro a confirmar'), findsOneWidget);
      },
    );
  });

  group('OffersFeedScreen — validação nos cards', () {
    testWidgets(
      'card mostra mini-indicador quando confirmCount > 0 e badges '
      'verificada/expirada conforme o status',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();

        harness.offersRepository.recentOffers = <OfferModel>[
          offer(id: 'ofA', productName: 'Café torrado 500 g', confirmCount: 3),
          offer(
            id: 'ofB',
            productName: 'Leite integral 1 L',
            price: 4.49,
            confirmCount: 2,
            status: OfferStatus.verified,
          ),
          offer(
            id: 'ofC',
            productName: 'Arroz tipo 1 5 kg',
            price: 19.99,
            status: OfferStatus.expired,
          ),
        ];

        await tester.binding.setSurfaceSize(const Size(1000, 2200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          harness.buildTestApp(
            home: const Scaffold(body: OffersFeedScreen()),
          ),
        );
        await pumpFrames(tester);

        expect(find.text('Café torrado 500 g'), findsOneWidget);
        expect(find.text('Leite integral 1 L'), findsOneWidget);
        expect(find.text('Arroz tipo 1 5 kg'), findsOneWidget);

        // Mini-indicador só nas ofertas com confirmações (A e B).
        expect(
          find.byKey(const Key('offer_card_confirm_indicator')),
          findsNWidgets(2),
        );
        expect(find.text('3'), findsOneWidget); // card A
        expect(find.text('2'), findsOneWidget); // card B

        // Badge verde somente na oferta verificada (B).
        expect(find.text('Verificada pela comunidade'), findsOneWidget);
        expect(find.byKey(const Key('offer_verified_chip')), findsOneWidget);

        // Chip 'Expirada' segue presente na oferta C.
        expect(find.text('Expirada'), findsOneWidget);
        expect(find.byKey(const Key('offer_expired_chip')), findsOneWidget);
      },
    );

    testWidgets(
      'cards sem confirmações e ativos não exibem indicador nem badge',
      (WidgetTester tester) async {
        final Phase3TestHarness harness = Phase3TestHarness();
        harness.offersRepository.recentOffers = <OfferModel>[
          offer(id: 'ofX', productName: 'Óleo de soja 900 ml', price: 6.49),
        ];

        await tester.pumpWidget(
          harness.buildTestApp(
            home: const Scaffold(body: OffersFeedScreen()),
          ),
        );
        await pumpFrames(tester);

        expect(
          find.byKey(const Key('offer_card_confirm_indicator')),
          findsNothing,
        );
        expect(find.text('Verificada pela comunidade'), findsNothing);
        expect(find.text('Expirada'), findsNothing);
      },
    );
  });
}
