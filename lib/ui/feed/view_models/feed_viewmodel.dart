import 'package:flutter/material.dart';

import '../../../data/repositories/offers/offer_repository.dart';
import '../../../domain/models/offer/offer.dart';

class FeedViewModel extends ChangeNotifier {
  FeedViewModel({required OfferRepository offerRepository})
    : _offerRepository = offerRepository;

  final OfferRepository _offerRepository;

  Future<List<Offer>> getFeedOffers() async {
    try {
      var fetchOffers = await _offerRepository.fetchOffers();
      fetchOffers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return fetchOffers;
    } finally {
      notifyListeners();
    }
  }
}
