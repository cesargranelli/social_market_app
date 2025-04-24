import 'package:flutter/material.dart';

// import '../../../data/repositories/offers/offer_repository.dart';
import '../../../domain/models/feed/feed_offer.dart';

class FeedOfferTimelineViewModel extends ChangeNotifier {
  // FeedOfferTimelineViewModel({required OfferRepository offerRepository})
  //   : _offerRepository = offerRepository;

  // final OfferRepository _offerRepository;

  final List<FeedOffer> _feedOffers = [];
  List<FeedOffer> get offers => _feedOffers;

  void addFeedOffer(FeedOffer feedOffer) {
    _feedOffers.add(feedOffer);
    notifyListeners();
  }
}
