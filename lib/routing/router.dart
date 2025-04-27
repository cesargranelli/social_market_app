import 'package:go_router/go_router.dart';

import '/data/auth/auth_gate.dart';
import '/data/repositories/offers/offer_repository_remote.dart';
import '/data/services/api/offer_api.dart';
import '/ui/offer/view_models/offer_viewmodel.dart';
import '/ui/offer/widgets/offer_feed_screen.dart';
import 'routes.dart';

GoRouter router(AuthGate authGate) => GoRouter(
  initialLocation: Routes.feed,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.feed,
      builder: (context, state) {
        final viewModel = OfferViewModel(
          offerRepository: OfferRepositoryRemote(offerApi: OfferApiFirebase()),
        );
        return OfferFeedScreen(viewModel: viewModel);
      },
    ),
  ],
);
