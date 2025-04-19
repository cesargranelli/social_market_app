import 'package:flutter/material.dart';

import 'data/auth/auth_gate.dart';

class SocialMarketApp extends StatelessWidget {
  const SocialMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Social Market",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
    );
  }
}
