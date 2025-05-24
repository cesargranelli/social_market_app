import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstAccessDecisionScreen extends StatelessWidget {
  const FirstAccessDecisionScreen({super.key});

  Future<void> _setHasSeenWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcomeScreen', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF4B4B), Color(0xFFFF6464)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // spacing: 8.0,
            children: [
              const Spacer(),
              Icon(Icons.person_add_alt_1, size: 100, color: Colors.white),
              const SizedBox(height: 8.0),
              Text(
                "Bem vindo ao Rede de Ofertas!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Escolha como você quer prosseguir:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                child: Ink(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text("Me Cadastrar", style: TextStyle(fontSize: 20)),
                  ),
                ),
                onTap: () {
                  _setHasSeenWelcomeScreen();
                  // context.go(Routes.signIn);
                },
              ),
              const SizedBox(height: 8.0),
              OutlinedButton(
                onPressed: () {
                  try {
                    FirebaseAuth.instance.signInAnonymously();
                    _setHasSeenWelcomeScreen();
                    // context.go('/anonymous-home');
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
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
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
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  _setHasSeenWelcomeScreen();
                  // context.go("/guest-dashboard");
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
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
