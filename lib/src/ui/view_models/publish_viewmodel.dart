import 'package:flutter/material.dart';

import '../../data/repositories/offer_repository.dart';
import '../../models/offer.dart';

class PublishViewModel extends ChangeNotifier {
  PublishViewModel({required OfferRepository offerRepository})
    : _offerRepository = offerRepository;

  final OfferRepository _offerRepository;

  void addOffer(Offer offer) async {
    try {
      await _offerRepository.createOffer(offer);
    } finally {
      notifyListeners();
    }
  }
}
