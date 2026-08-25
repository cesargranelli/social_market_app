import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config.dart';
import '../../../core/providers/firebase_providers.dart';
import 'home_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading:
          () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
      // Em caso de erro no stream, trata como usuário ausente.
      error: (_, _) => _buildSignInScreen(context),
      data: (user) {
        if (user == null) {
          return _buildSignInScreen(context);
        }

        return const HomeScreen();
      },
    );
  }

  Widget _buildSignInScreen(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
        GoogleProvider(clientId: googleClientId),
      ],
      headerBuilder: (context, constraints, shrinkOffset) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_offer, size: 96),
              Text(
                'Social Market',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        );
      },
      subtitleBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child:
              action == AuthAction.signIn
                  ? const Text(
                    'Bem-vindo ao Social Market! Entre para economizar.',
                  )
                  : const Text('Crie sua conta no Social Market!'),
        );
      },
      footerBuilder: (context, action) {
        return const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Ao entrar, você concorda com nossos termos de uso.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
      sideBuilder: (context, shrinkOffset) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_offer, size: 96),
              Text(
                'Social Market',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
