import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_market_app/data/repositories/offers/offer_repository_remote.dart';

import 'data/repositories/offers/offer_repository.dart';
import 'data/services/api/offer_api.dart';
import 'firebase_options.dart';
import 'social_market_app.dart';
import 'ui/offer/view_models/offer_viewmodel.dart';

void main() async {
  final OfferApiFirebase offerApi = OfferApiFirebase(baseUrl: '');
  final OfferRepository offerRepository = OfferRepositoryRemote(
    offerApi: offerApi,
  );
  final OfferViewModel viewModel = OfferViewModel(
    offerRepository: offerRepository,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SocialMarketApp(viewModel: viewModel));
}
