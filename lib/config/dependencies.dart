import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_market_app/data/auth/auth_gate.dart';

import '../data/repositories/offers/offer_repository.dart';
import '../data/repositories/offers/offer_repository_remote.dart';
import '../data/services/api/offer_api.dart';

List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => OfferApiFirebase()),
    Provider(create: (context) => AuthGate()),
    Provider(
      create:
          (context) =>
              OfferRepositoryRemote(offerApi: context.read())
                  as OfferRepository,
    ),
  ];
}
