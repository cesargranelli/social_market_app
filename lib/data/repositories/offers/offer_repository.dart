import 'package:social_market_app/domain/models/offer/offer.dart';

abstract class OfferRepository {
  Future<List<Offer>> fetchOffers();
  Future<Offer> getOfferById(String id);
  Future<void> createOffer(Offer offer);
  Future<void> updateOffer(Offer offer);
  Future<void> deleteOffer(String id);
}
