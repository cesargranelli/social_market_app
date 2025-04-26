import 'package:go_router/go_router.dart';
import 'package:social_market_app/data/auth/auth_gate.dart';
import 'package:social_market_app/ui/offer/view_models/offer_viewmodel.dart';
import 'package:social_market_app/ui/offer/widgets/offer_feed_screen.dart';

import '../data/repositories/offers/offer_repository_remote.dart';
import '../data/services/api/offer_api.dart';

GoRouter router(AuthGate authGate) => GoRouter(
  initialLocation: '/offer/feed',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/offer/feed',
      builder: (context, state) {
        final viewModel = OfferViewModel(
          offerRepository: OfferRepositoryRemote(offerApi: OfferApiFirebase()),
        );
        return OfferFeedScreen(viewModel: viewModel);
      },
    ),
  ],
);
