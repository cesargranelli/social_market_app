import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';

import '../../ui/feed/widgets/feed_offer_timeline_screen.dart'; // Social Market - Ofertas
import '../../ui/feed/xfeed_chatgpt_screen.dart'; // ChatGPT - Distância e Tempo
import '../../ui/feed/xfeed_deepseek_screen.dart'; // DeepSeek - Ação de seleção para ver menos, etc
import '../../ui/feed/xfeed_gemini_screen.dart'; // Gemini - Conveito de tela principal
import '../../ui/login/widgets/login_screen.dart';
import '../../ui/instagram/instagram_timeline.dart'; // DeepSeek - Conceito dos botões de compartilhamento etc
import '../../ui/feed/feed_ofertas_page.dart'; // ChatGPT - Pontos e marcações de vi essa oferta
import '../../ui/innovative/innovative_offer_timeline.dart'; // Gemini - Filtros de Ofertas superior e marcação de destaque
import '../../ui/ofertas/ofertas_timeline.dart'; // DeepSeek - Filtro de Ofertas e botão de coleta
import '../../ui/offer/offer_timeline_screen.dart'; // Gemini - Descartar
import '../../ui/feed/feed_timeline_screen.dart'; // Widget de timeline

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // return LoginScreen();
          return FeedOfferTimelineScreen();
        }
        return FeedTimelineScreen();
      },
    );
  }
}
