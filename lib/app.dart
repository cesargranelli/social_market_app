import 'package:flutter/material.dart';

import 'auth_gate.dart';
import 'core/theme.dart';

class SocialMarketApp extends StatelessWidget {
  const SocialMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Market',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const AuthGate(),
    );
  }
}
