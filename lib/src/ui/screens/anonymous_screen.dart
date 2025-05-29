import 'package:flutter/material.dart';

import '../themes/colors_app.dart';

class AnonymousScreen extends StatelessWidget {
  const AnonymousScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Acesso Anônimo"),
        backgroundColor: ColorsApp.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
