import 'package:social_market_app/domain/models/feed/feed_offer.dart';

abstract class OfferRepository {
  Future<List<FeedOffer>> fetchOffers();
  Future<FeedOffer> getOfferById(String id);
  Future<void> createOffer(FeedOffer feedOffer);
  Future<void> updateOffer(FeedOffer feedOffer);
  Future<void> deleteOffer(String id);
}
