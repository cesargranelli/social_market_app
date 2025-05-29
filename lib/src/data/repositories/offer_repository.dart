import '../../models/offer.dart';
import '../../models/offer_rating.dart';

abstract class OfferRepository {
  Future<List<Offer>> fetchOffers();
  Future<void> createOffer(Offer offer);
  Future<void> updateOfferRating(String offerId, OfferRating offerRating);
}
