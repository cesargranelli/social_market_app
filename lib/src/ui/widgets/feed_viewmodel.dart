import 'package:flutter/material.dart';

import '../../data/repositories/offer_repository.dart';
import '../../models/offer.dart';
import '../../models/offer_rating.dart';

class FeedViewModel extends ChangeNotifier {
  FeedViewModel({required OfferRepository offerRepository})
    : _offerRepository = offerRepository;

  final OfferRepository _offerRepository;

  Future<List<Offer>> getFeedOffers() async {
    try {
      final fetchOffers = await _offerRepository.fetchOffers();

      fetchOffers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
