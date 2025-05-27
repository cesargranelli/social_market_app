import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../themes/colors_app.dart';
import '../../routing/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child:
              action == AuthAction.signIn
                  ? const Text("Welcome to FlutterFire, please sign in!")
                  : const Text("Welcome to Flutterfire, please sign up!"),
        );
      },
      footerBuilder: (context, action) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(50),
              child: Ink(
                height: 50,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: ColorsApp.colorScheme.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.arrow_back, size: 30, color: Colors.white),
                    Text(
                      "Voltar",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
              onTap: () {
                context.pop(Routes.first);
              },
            ),
          ],
        );
      },
    );
  }
}
