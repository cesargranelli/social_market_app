import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'helpers/fake_repositories.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/offers/presentation/new_offer_screen.dart';
import 'package:social_market_app/features/offers/presentation/offers_shell.dart';
import 'package:social_market_app/features/profile/domain/user_model.dart';
import 'package:social_market_app/features/stores/domain/store_model.dart';

const StoreModel kSeedStore = StoreModel(
  id: 'store-1',
  name: 'Bom Preço',
  city: 'Campinas',
  neighborhood: 'Centro',
  createdBy: 'seed-user',
);

/// Bombeia alguns frames discretos (evita pumpAndSettle, que nunca
/// terminaria com spinners/SnackBars na árvore).
Future<void> _pumpFrames(WidgetTester tester, [int frames = 2]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pumpShell(WidgetTester tester, Phase3TestHarness harness) async {
  await tester.pumpWidget(harness.buildTestApp(home: const OffersShell()));
  await _pumpFrames(tester);
}

void main() {
  testWidgets('OffersShell renderiza as 3 abas e o conteúdo inicial da aba Ofertas', (
    tester,
  ) async {
    final Phase3TestHarness harness = Phase3TestHarness(
      seedStores: <StoreModel>[kSeedStore],
    );

    await _pumpShell(tester, harness);

    // Navegação inferior com três abas.
    final BottomNavigationBar navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.items, hasLength(3));
    expect(
      navBar.items.map((BottomNavigationBarItem item) => item.label),
      <String?>['Ofertas', 'Nova Oferta', 'Perfil'],
    );

    // Conteúdo inicial: feed real com empty state (o fake não tem ofertas).
    expect(find.text('Nenhuma oferta publicada ainda.'), findsOneWidget);
    expect(
      find.text('Seja o primeiro a compartilhar uma promoção!'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.storefront), findsAtLeastNWidgets(1));

    // Rótulos das abas presentes.
    expect(find.text('Ofertas'), findsWidgets);
    expect(find.text('Nova Oferta'), findsWidgets);
    expect(find.text('Perfil'), findsWidgets);
  });

  testWidgets('Aba Perfil exibe nome do usuário mockado e pontos do stream fake', (
    tester,
  ) async {
    final Phase3TestHarness harness = Phase3TestHarness(
      profile: UserModel(
        uid: 'uid-1',
        displayName: 'Maria Silva',
        points: 42,
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    await _pumpShell(tester, harness);

    // Vai para a aba Perfil.
    await tester.tap(find.text('Perfil'));
    await _pumpFrames(tester);

    // Dados de autenticação (nome aparece no cabeçalho e na linha do
    // usuário logado no ranking).
    expect(find.text('Maria Silva'), findsNWidgets(2));
    expect(find.text('maria@exemplo.com'), findsOneWidget);

    // Pontos vindos do stream do UserRepository fake.
    expect(find.byIcon(Icons.stars), findsOneWidget);
    expect(find.text('42 pontos'), findsOneWidget);
    expect(
      find.text('Ganhe pontos publicando e confirmando ofertas.'),
      findsOneWidget,
    );

    // Seções novas de gamificação presentes.
    expect(find.text('Ranking da comunidade'), findsOneWidget);
    expect(find.byIcon(Icons.leaderboard), findsOneWidget);
    expect(find.text('42 pts'), findsOneWidget);
    expect(find.text('Publique ofertas para ganhar badges!'), findsOneWidget);

    // Logout permanece acessível na aba.
    expect(find.byType(SignOutButton), findsOneWidget);
  });

  testWidgets('Nova Oferta valida campos vazios e publica oferta válida', (
    tester,
  ) async {
    final Phase3TestHarness harness = Phase3TestHarness(
      seedStores: <StoreModel>[kSeedStore],
    );
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // A tela vive dentro do Scaffold do shell na app real; reproduzimos
    // esse contexto para ter o ancestral Material exigido pelos campos.
    await tester.pumpWidget(
      harness.buildTestApp(
        home: Scaffold(body: SingleChildScrollView(child: const NewOfferScreen())),
      ),
    );
    await tester.pump();

    // 1) Submissão vazia -> erros de validação e nenhuma oferta criada.
    await tester.tap(find.byKey(const Key('new_offer_publish_button')));
    await tester.pump();

    expect(find.text('Informe o nome do produto.'), findsOneWidget);
    expect(find.text('Informe o preço atual.'), findsOneWidget);
    expect(harness.offersRepository.createdOffers, isEmpty);

    // 2) Campos válidos, porém sem mercado -> SnackBar pedindo mercado.
    await tester.enterText(
      find.byKey(const Key('new_offer_product_name_field')),
      'Café torrado 500 g',
    );
    await tester.enterText(
      find.byKey(const Key('new_offer_price_field')),
      '9,90',
    );
    await tester.tap(find.byKey(const Key('new_offer_publish_button')));
    await tester.pump();

    expect(
      find.text('Selecione ou cadastre um mercado antes de publicar.'),
      findsOneWidget,
    );
    expect(harness.offersRepository.createdOffers, isEmpty);

    // 3) Busca o mercado informando cidade + termo e seleciona o resultado.
    await tester.enterText(
      find.byKey(const Key('new_offer_city_field')),
      'Campinas',
    );
    await tester.enterText(
      find.byKey(const Key('new_offer_store_search_field')),
      'bom',
    );
    await tester.tap(find.byKey(const Key('new_offer_search_stores_button')));
    await _pumpFrames(tester);

    expect(find.text('Bom Preço'), findsOneWidget);
    await tester.tap(find.text('Bom Preço'));
    await tester.pump();

    // Mercado selecionado aparece como card confirmado.
    expect(find.text('Centro • Campinas'), findsOneWidget);

    // 4) Publica a oferta -> createOffer chamado + SnackBar de sucesso.
    await tester.tap(find.byKey(const Key('new_offer_publish_button')));
    await _pumpFrames(tester, 4);

    expect(find.text('Oferta publicada com sucesso!'), findsOneWidget);

    final OfferModel saved = harness.offersRepository.createdOffers.single;
    expect(saved.productName, 'Café torrado 500 g');
    expect(saved.price, 9.9);
    expect(saved.regularPrice, isNull);
    expect(saved.unit, 'un');
    expect(saved.storeId, 'store-1');
    expect(saved.authorUid, 'uid-1');
    expect(saved.imageUrl, isNull);
    expect(saved.confirmCount, 0);
    expect(saved.status, OfferStatus.active);

    // Formulário resetado após publicar.
    expect(find.text('Café torrado 500 g'), findsNothing);

    // Drena o timer do SnackBar para não vazar timer no fim do teste.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('+ Cadastrar novo mercado cria loja e já seleciona', (
    tester,
  ) async {
    final Phase3TestHarness harness = Phase3TestHarness();
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      harness.buildTestApp(
        home: Scaffold(body: SingleChildScrollView(child: const NewOfferScreen())),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('new_offer_open_create_store_button')),
    );
    await _pumpFrames(tester);

    await tester.enterText(
      find.byKey(const Key('create_store_name_field')),
      'Mercado Novo',
    );
    await tester.enterText(
      find.byKey(const Key('create_store_city_field')),
      'Campinas',
    );
    await tester.enterText(
      find.byKey(const Key('create_store_neighborhood_field')),
      'Jardim das Flores',
    );
    await tester.tap(find.byKey(const Key('create_store_save_button')));
    await _pumpFrames(tester, 4);

    // Repositório fake recebeu a loja com createdBy do usuário logado.
    expect(harness.storesRepository.createdStores, hasLength(1));
    expect(harness.storesRepository.createdStores.first.name, 'Mercado Novo');
    expect(harness.storesRepository.createdStores.first.createdBy, 'uid-1');

    // Loja criada já aparece selecionada no formulário.
    expect(find.text('Mercado Novo'), findsOneWidget);
    expect(find.text('Jardim das Flores • Campinas'), findsOneWidget);
    expect(
      find.text('Mercado "Mercado Novo" cadastrado e selecionado!'),
      findsOneWidget,
    );

    // Drena o timer do SnackBar.
    await tester.pump(const Duration(seconds: 5));
  });
}
