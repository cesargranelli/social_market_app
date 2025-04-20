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
        cardTheme: CardTheme(
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          bodySmall: TextStyle(color: Colors.grey),
        ),
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      home: const AuthGate(),
    );
  }
}
