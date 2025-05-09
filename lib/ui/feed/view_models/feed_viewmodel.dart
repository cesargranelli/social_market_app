import 'package:flutter/material.dart';
import 'package:social_market_app/domain/models/offer/offer_rating.dart';

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

  void updateOfferRating(String offerId, OfferRating offerRating) {
    _offerRepository.updateOfferRating(offerId, offerRating);
    notifyListeners();
  }
}
