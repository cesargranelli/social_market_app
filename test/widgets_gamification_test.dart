import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_repositories.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/offers/presentation/offers_shell.dart';
import 'package:social_market_app/features/profile/domain/user_model.dart';

/// Widget tests da gamificação (Fase 4): ranking da comunidade, badges do
/// perfil e mini-badge de autor com oferta verificada no feed.
///
/// Usa o harness padrão com os fakes da Fase 3 (sem Firebase real).

/// Bombeia alguns frames discretos (evita pumpAndSettle com streams abertos).
Future<void> _pumpFrames(WidgetTester tester, [int frames = 2]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Abre o shell e navega para a aba Perfil.
Future<void> _pumpProfileTab(WidgetTester tester, Phase3TestHarness harness) async {
  await tester.pumpWidget(harness.buildTestApp(home: const OffersShell()));
  await _pumpFrames(tester);

  await tester.tap(find.text('Perfil'));
  await _pumpFrames(tester);
}

OfferModel _offer({
  String id = 'of-1',
  String productName = 'Café torrado 500 g',
  double price = 9.9,
  String authorUid = 'uid-1',
  String authorName = 'Maria Silva',
  OfferStatus status = OfferStatus.active,
}) {
  return OfferModel(
    id: id,
    productName: productName,
    price: price,
    storeId: 'store-1',
    storeName: 'Bom Preço',
    authorUid: authorUid,
    authorName: authorName,
    createdAt: DateTime(2026, 8, 20),
    status: status,
  );
}

UserModel _user(String uid, String name, int points) {
  return UserModel(
    uid: uid,
    displayName: name,
    points: points,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  testWidgets(
    'Perfil exibe seção Ranking com usuários fake ordenados por pontos '
    'e destaca a linha do usuário logado',
    (tester) async {
      final Phase3TestHarness harness = Phase3TestHarness(
        profile: _user('uid-1', 'Maria Silva', 42),
        topUsers: <UserModel>[
          _user('uid-top', 'Bruno Top', 300),
          _user('uid-prata', 'Ana Prata', 150),
          _user('uid-bronze', 'Carlos Bronze', 90),
          _user('uid-1', 'Maria Silva', 42), // Usuário logado em 4º.
          _user('uid-final', 'Diego Final', 10),
        ],
      );
      await tester.binding.setSurfaceSize(const Size(1000, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpProfileTab(tester, harness);

      // Cabeçalho da seção.
      expect(find.text('Ranking da comunidade'), findsOneWidget);
      expect(find.byIcon(Icons.leaderboard), findsOneWidget);

      // Todas as linhas presentes.
      Key rowKey(String uid) => Key('ranking_row_$uid');
      for (final String uid in <String>[
        'uid-top',
        'uid-prata',
        'uid-bronze',
        'uid-1',
        'uid-final',
      ]) {
        expect(find.byKey(rowKey(uid)), findsOneWidget);
      }

      // Ordenação: posição Y cresce conforme os pontos diminuem.
      double dyOf(String uid) =>
          tester.getTopLeft(find.byKey(rowKey(uid))).dy;
      expect(dyOf('uid-top'), lessThan(dyOf('uid-prata')));
      expect(dyOf('uid-prata'), lessThan(dyOf('uid-bronze')));
      expect(dyOf('uid-bronze'), lessThan(dyOf('uid-1')));
      expect(dyOf('uid-1'), lessThan(dyOf('uid-final')));

      // Medalhas para o top 3 e numeração a partir do 4º.
      expect(find.byIcon(Icons.emoji_events), findsNWidgets(3));
      expect(find.text('4º'), findsOneWidget);
      expect(find.text('5º'), findsOneWidget);

      // Pontos à direita no formato 'X pts'.
      expect(find.text('300 pts'), findsOneWidget);
      expect(find.text('42 pts'), findsOneWidget);

      // Linha do usuário logado destacada com primaryContainer; as demais
      // sem cor de fundo.
      final BuildContext context = tester.element(
        find.byKey(rowKey('uid-1')),
      );
      final Color highlight = Theme.of(context).colorScheme.primaryContainer;

      final Container loggedRow = tester.widget<Container>(
        find.byKey(rowKey('uid-1')),
      );
      expect(
        (loggedRow.decoration! as BoxDecoration).color,
        highlight,
      );

      final Container otherRow = tester.widget<Container>(
        find.byKey(rowKey('uid-top')),
      );
      expect((otherRow.decoration! as BoxDecoration).color, isNull);
    },
  );

  testWidgets(
    'Badges do perfil aparecem conforme contadores dos fakes '
    '(2 conquistas: primeira oferta + oferta verificada)',
    (tester) async {
      final Phase3TestHarness harness = Phase3TestHarness();
      // 2 ofertas do usuário logado, sendo 1 verificada e nenhuma comentada
      // -> computeBadges deve gerar exatamente [first_offer, trusted].
      harness.offersRepository.recentOffers = <OfferModel>[
        _offer(id: 'of-1', status: OfferStatus.active),
        _offer(id: 'of-2', productName: 'Leite integral 1 L', price: 4.99,
            status: OfferStatus.verified),
      ];

      await _pumpProfileTab(tester, harness);

      // As duas badges esperadas.
      expect(find.text('Primeira oferta publicada'), findsOneWidget);
      expect(find.text('Oferta verificada'), findsOneWidget);

      // Nenhuma das outras.
      expect(find.text('10+ ofertas'), findsNothing);
      expect(find.text('Comentarista ativo'), findsNothing);

      // Estado vazio não aparece quando há badges.
      expect(find.text('Publique ofertas para ganhar badges!'), findsNothing);
    },
  );

  testWidgets('Estado vazio do ranking quando nenhum usuário pontuou', (
    tester,
  ) async {
    final Phase3TestHarness harness = Phase3TestHarness(
      topUsers: const <UserModel>[], // Ranking explicitamente vazio.
    );

    await _pumpProfileTab(tester, harness);

    expect(find.text('Ranking da comunidade'), findsOneWidget);
    expect(find.text('Ninguém pontuou ainda.'), findsOneWidget);
    expect(find.byKey(Key('ranking_row_uid-1')), findsNothing);
  });

  testWidgets(
    'Feed card exibe ícone premium ao lado do autor somente em oferta '
    'verified, com tooltip acessível',
    (tester) async {
      final Phase3TestHarness harness = Phase3TestHarness();
      harness.offersRepository.recentOffers = <OfferModel>[
        _offer(id: 'of-verificada', status: OfferStatus.verified),
        _offer(
          id: 'of-ativa',
          productName: 'Arroz tipo 1 5 kg',
          price: 19.99,
        ),
      ];
      await tester.binding.setSurfaceSize(const Size(1000, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(harness.buildTestApp(home: const OffersShell()));
      await _pumpFrames(tester);

      // Ícone premium apenas na oferta verificada.
      expect(find.byIcon(Icons.workspace_premium), findsNWidgets(1));

      // Tooltip configurado com a mensagem amigável.
      final Tooltip tooltip = tester.widget<Tooltip>(
        find.byKey(const Key('offer_card_author_premium_badge')),
      );
      expect(tooltip.message, 'Autor com oferta verificada');
    },
  );

  testWidgets('Erro no stream do ranking exibe mensagem amigável', (
    tester,
  ) async {
    final Phase3TestHarness harness = Phase3TestHarness();
    harness.userRepository.watchTopUsersError = Exception('falha de rede');

    await _pumpProfileTab(tester, harness);

    expect(find.text('Ranking da comunidade'), findsOneWidget);
    expect(
      find.textContaining('Não foi possível carregar o ranking'),
      findsOneWidget,
    );
    expect(find.text('Ninguém pontuou ainda.'), findsNothing);
  });
}
