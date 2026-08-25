import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:social_market_app/core/theme.dart';
import 'package:social_market_app/home.dart';

void main() {
  testWidgets('HomeScreen exibe marca, boas-vindas e ações principais', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: appTheme, home: const HomeScreen()),
    );

    // Marca (ícone + nome).
    expect(find.byIcon(Icons.local_offer), findsOneWidget);
    expect(find.text('Social Market'), findsOneWidget);

    // Mensagem de boas-vindas.
    expect(find.text('Bem-vindo!'), findsOneWidget);

    // Ações da tela: botão de sair no corpo e atalho de perfil na AppBar.
    expect(find.byType(SignOutButton), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.person), findsOneWidget);
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
}
