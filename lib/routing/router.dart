import 'package:go_router/go_router.dart';

import '/data/auth/auth_gate.dart';
import '/data/repositories/offers/offer_repository_remote.dart';
import '/data/services/api/offer_api.dart';
import '../ui/core/ui/transition_slide.dart';
import '../ui/feed/view_models/feed_viewmodel.dart';
import '../ui/feed/widgets/feed_screen.dart';
import '../ui/publish/view_models/publish_viewmodel.dart';
import '../ui/publish/widgets/publish_screen.dart';
import 'routes.dart';

GoRouter router(AuthGate authGate) => GoRouter(
  initialLocation: Routes.feed,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
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
