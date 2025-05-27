import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/offers/offer_repository_remote.dart';
import '../data/services/api/offer_api.dart';
import '../ui/widgets/transition_slide.dart';
import '../ui/widgets/feed_viewmodel.dart';
import '../ui/screens/feed_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/view_models/publish_viewmodel.dart';
import '../ui/screens/publish_screen.dart';
import '../ui/screens/first_access_decision_screen.dart';
import 'routes.dart';

// const String HAS_SEEN_WELCOME_SCREEN_KEY = 'hasSeenWelcomeScreen';

GoRouter router() => GoRouter(
  navigatorKey: GlobalKey<NavigatorState>(),
  initialLocation: "/",
  redirect: (context, state) async {
    // print("Current User: ${FirebaseAuth.instance.currentUser}");
    // final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    // final isTryingToAccessAuthRoute =
    //     state.fullPath == Routes.check ||
    //     state.fullPath == Routes.login ||
    //     state.fullPath == Routes.register ||
    //     state.fullPath == Routes.forgot;
    //
    print("Path: ${state.fullPath}");
    // print(!isLoggedIn && !isTryingToAccessAuthRoute);
    // print(isLoggedIn && isTryingToAccessAuthRoute);

    // if (!isLoggedIn && !isTryingToAccessAuthRoute) {
    //   return Routes.check;
    // }
    // if (isLoggedIn && isTryingToAccessAuthRoute) {
    //   return Routes.login;
    // }
    return null;
  },
  errorBuilder:
      (context, state) => Scaffold(
        appBar: AppBar(title: const Text("Erro")),
        body: Center(child: Text("Página não encontrada: ${state.error}")),
      ),
  routes: <RouteBase>[
    GoRoute(
      path: Routes.first,
      builder: (context, state) => const FirstAccessDecisionScreen(),
    ),
    GoRoute(
      path: Routes.signIn,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return TransitionSlide(
              animation: animation,
              direction: TransitionSlide.rightLeft,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: Routes.feed,
      pageBuilder: (context, state) {
        final viewModel = FeedViewModel(
          offerRepository: OfferRepositoryRemote(offerApi: OfferApiFirebase()),
        );
        return CustomTransitionPage(
          key: state.pageKey,
          child: FeedScreen(viewModel: viewModel),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return TransitionSlide(
              animation: animation,
              direction: TransitionSlide.rightLeft,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: Routes.publish,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: PublishScreen(
            viewModel: PublishViewModel(
              offerRepository: OfferRepositoryRemote(
                offerApi: OfferApiFirebase(),
              ),
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return TransitionSlide(
              animation: animation,
              direction: TransitionSlide.downUp,
              child: child,
            );
          },
        );
      },
    ),
  ],
);
