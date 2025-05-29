import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';
import '../themes/colors_app.dart';

class SignInAppScreen extends StatelessWidget {
  const SignInAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro"),
        backgroundColor: ColorsApp.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SignInScreen(
        providers: [
          EmailAuthProvider(),
          GoogleProvider(
            clientId:
                "183973726892-7q9f4gbqi97mic6bm0udvmgpo8qe81g4.apps.googleusercontent.com",
          ),
        ],
        actions: [
          AuthStateChangeAction<SignedIn>((context, _) {
            context.pushReplacement(Routes.feed);
          }),
        ],
        styles: const {
          EmailFormStyle(
            signInButtonVariant: ButtonVariant.filled,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(color: Colors.green),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(color: Colors.green),
              ),
              outlineBorder: BorderSide(color: Colors.green),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
          ),
        },
        headerBuilder: (context, constraints, shrinkOffset) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset("assets/flutterfire_300x.png"),
            ),
          );
        },
        subtitleBuilder: (context, action) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child:
                action == AuthAction.signIn
                    ? const Text("Bem vindo, faça seu login!")
                    : const Text("Bem vindo, faça seu cadastro!"),
          );
        },
      ),
    );
  }
}
