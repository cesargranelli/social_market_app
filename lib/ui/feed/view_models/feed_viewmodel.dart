import 'package:flutter/material.dart';

import '../../../data/repositories/offers/offer_repository.dart';
import '../../../domain/models/offer/offer.dart';

class FeedViewModel extends ChangeNotifier {
  FeedViewModel({required OfferRepository offerRepository})
    : _offerRepository = offerRepository;

  final OfferRepository _offerRepository;

  Future<List<Offer>> getFeedOffers() async {
    try {
      final fetchOffers = await _offerRepository.fetchOffers();

      return fetchOffers;
    } finally {
      notifyListeners();
    }
  }
}
