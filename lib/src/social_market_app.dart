import 'package:flutter/material.dart';

import '../config/themes/colors_app.dart';
import 'routing/router.dart';

class SocialMarketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Social Market",
      theme: ThemeData(
        colorScheme: ColorsApp.colorScheme,
        cardTheme: CardThemeData(
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
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white70,
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      routerConfig: router(),
    );
  }
}
