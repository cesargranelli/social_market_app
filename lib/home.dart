import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder:
                      (context) => ProfileScreen(
                        appBar: AppBar(title: const Text('Perfil')),
                        actions: [
                          SignedOutAction((context) {
                            Navigator.of(context).pop();
                          }),
                        ],
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_offer),
                                Text('Social Market'),
                              ],
                            ),
                          ),
                        ],
                      ),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_offer),
            const Text('Social Market'),
            Text('Bem-vindo!', style: Theme.of(context).textTheme.displaySmall),
            const SignOutButton(),
          ],
        ),
      ),
    );
  }
}
