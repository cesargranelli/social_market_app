import 'package:go_router/go_router.dart';
import 'package:social_market_app/ui/publish/widgets/publish_screen.dart';

import '/data/auth/auth_gate.dart';
import '/data/repositories/offers/offer_repository_remote.dart';
import '/data/services/api/offer_api.dart';
import '../ui/feed/view_models/feed_viewmodel.dart';
import '../ui/feed/widgets/feed_screen.dart';
import 'routes.dart';

GoRouter router(AuthGate authGate) => GoRouter(
  initialLocation: Routes.feed,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.feed,
      builder: (context, state) {
        final viewModel = FeedViewModel(
          offerRepository: OfferRepositoryRemote(offerApi: OfferApiFirebase()),
        );
        return FeedScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.publish,
      builder: (context, state) => const PublishScreen(),
    ),
  ],
);
