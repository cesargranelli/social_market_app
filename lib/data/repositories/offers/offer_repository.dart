import '../../../domain/models/offer/offer_rating.dart';

import '/domain/models/offer/offer.dart';

abstract class OfferRepository {
  Future<List<Offer>> fetchOffers();
  Future<void> createOffer(Offer offer);
  Future<void> updateOfferRating(String offerId, OfferRating offerRating);
}
