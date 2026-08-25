import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_gate.dart';
import '../../features/offers/presentation/offer_detail_screen.dart';

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AuthGate()),
      GoRoute(
        path: '/oferta/:id',
        builder: (context, state) =>
            OfferDetailScreen(offerId: state.pathParameters['id']!),
      ),
    ],
  ),
);
