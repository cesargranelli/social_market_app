import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/fake_repositories.dart';
import 'package:social_market_app/core/router/app_router.dart';
import 'package:social_market_app/core/theme.dart';
import 'package:social_market_app/features/offers/presentation/offers_shell.dart';

void main() {
  testWidgets('OffersShell exibe três abas e o conteúdo inicial da aba Ofertas', (
    tester,
  ) async {
    final Phase3TestHarness harness = Phase3TestHarness();

    await tester.pumpWidget(harness.buildTestApp(home: const OffersShell()));
    await tester.pump();
    await tester.pump();

    // Navegação inferior com três abas.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    final BottomNavigationBar navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.items, hasLength(3));

    // Placeholder elegante no lugar do antigo HomeScreen.
    expect(find.text('Feed de ofertas em breve!'), findsOneWidget);
    expect(find.byIcon(Icons.storefront), findsAtLeastNWidgets(1));
  });

  testWidgets('SocialMarketApp usa appTheme como tema', (tester) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // O tema aplicado no contexto deve ser o mesmo esquema de cores
    // configurado em core/theme.dart.
    expect(Theme.of(capturedContext).colorScheme, appTheme.colorScheme);
  });

  test('routerProvider expõe GoRouter com rota raiz "/"', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = container.read(routerProvider);

    final firstRoute = router.configuration.routes.first;

    expect(firstRoute, isA<GoRoute>());
    expect((firstRoute as GoRoute).path, '/');
  });
}
