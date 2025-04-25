import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';

import '../../ui/offer/view_models/offer_viewmodel.dart';
import '../../ui/offer/widgets/offer_feed_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.viewModel});

  final OfferViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // return LoginScreen();
          return OfferFeedScreen(viewModel: viewModel);
        }
        return OfferFeedScreen(viewModel: viewModel);
      },
    );
  }
}
