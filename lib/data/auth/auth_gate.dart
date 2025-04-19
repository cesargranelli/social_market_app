import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';

import '../../ui/feed/xfeed_chatgpt_screen.dart';
import '../../ui/feed/xfeed_deepseek_screen.dart';
import '../../ui/feed/xfeed_gemini_screen.dart';
import '../../ui/login/widgets/login_screen.dart';
import '../../ui/instagram/instagram_timeline.dart';
import '../../ui/feed/feed_ofertas_page.dart';
import '../../ui/innovative/innovative_offer_timeline.dart';
import '../../ui/ofertas/ofertas_timeline.dart';
import '../../ui/offer/offer_timeline_screen.dart';
import '../../ui/timeline/widgets/timeline_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginScreen();
        }
        return XFeedChatGptScreen();
      },
    );
  }
}
