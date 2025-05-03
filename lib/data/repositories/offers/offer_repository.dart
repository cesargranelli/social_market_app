import '/domain/models/offer/offer.dart';

abstract class OfferRepository {
  Future<List<Offer>> fetchOffers();
  Future<void> createOffer(Offer offer);
}
