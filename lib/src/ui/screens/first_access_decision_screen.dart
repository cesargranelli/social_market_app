import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';

class FirstAccessDecisionScreen extends StatelessWidget {
  const FirstAccessDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.person_add_alt_1,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8.0),
              Text(
                "Bem vindo ao Rede de Ofertas!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  context.push(Routes.signIn);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                ),
                child: const Text(
                  "Me Cadastrar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16.0),
              OutlinedButton(
                onPressed: () {
                  try {
                    FirebaseAuth.instance.signInAnonymously();
                    context.push(Routes.anonymous);
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Erro ao entrar como anônimo: ${e.message}",
                        ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
                child: const Text(
                  "Continuar como Anônimo",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  context.go(Routes.feed);
                },
                child: const Text(
                  "Explorar como Visitante",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
