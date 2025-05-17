import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '/data/repositories/offers/offer_repository_remote.dart';
import '/data/services/api/offer_api.dart';
import '../commons/widgets/transition_slide.dart';
import '../presentation/feed/view_models/feed_viewmodel.dart';
import '../presentation/feed/widgets/feed_screen.dart';
import '../presentation/login/widgets/login_screen.dart';
import '../presentation/publish/view_models/publish_viewmodel.dart';
import '../presentation/publish/widgets/publish_screen.dart';
import 'routes.dart';

GoRouter router() => GoRouter(
  redirect: (context, state) {
    print("Current User: ${FirebaseAuth.instance.currentUser}");
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isTryingToAccessAuthRoute =
        state.fullPath == Routes.login ||
        state.fullPath == Routes.register ||
        state.fullPath == Routes.forgot;

    if (!isLoggedIn && !isTryingToAccessAuthRoute) {
      return Routes.login;
    }
    if (isLoggedIn && isTryingToAccessAuthRoute) {
      return Routes.feed;
    }
    return null;
  },
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: Routes.login,
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
