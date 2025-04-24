import 'package:social_market_app/data/repositories/offers/offers_mock.dart';
// import 'package:social_market_app/data/services/api/api_offer_provider.dart';

import '../../../domain/models/feed/feed_offer.dart';
import 'offer_repository.dart';

class OfferRepositoryRemote implements OfferRepository {
  // final ApiOfferProvider _apiOfferProvider;

  // OfferRepositoryRemote(this._apiOfferProvider);

  @override
  Future<List<FeedOffer>> fetchOffers() async {
    // final response = await _apiOfferProvider.get('/offers');
    // if (response.statusCode == 200) {
    //   final List<dynamic> data = response.data;
    //   return data.map((json) => FeedOffer.fromJson(json)).toList();
    // } else {
    //   throw Exception('Failed to load offers');
    // }
    return offers;
  }

  @override
  Future<FeedOffer> getOfferById(String id) async {
    // final response = await _apiOfferProvider.get('/offers/$id');
    // if (response.statusCode == 200) {
    //   return Offer.fromJson(response.data);
    // } else {
    //   throw Exception('Failed to load offer');
    // }
    return offers.singleWhere((offer) => offer.id == id);
  }

  @override
  Future<void> createOffer(FeedOffer feedOffer) async {
    // final response = await _apiOfferProvider.post(
    //   '/offers',
    //   data: offer.toJson(),
    // );
    // if (response.statusCode != 201) {
    //   throw Exception('Failed to create offer');
    // }
    offers.add(feedOffer);
  }

  @override
  Future<void> updateOffer(FeedOffer feedOffer) async {
    // final response = await _apiOfferProvider.put(
    //   '/offers/$id',
    //   data: offer.toJson(),
    // );
    // if (response.statusCode != 200) {
    //   throw Exception('Failed to update offer');
    // }
  }

  @override
  Future<void> deleteOffer(String id) async {
    // final response = await _apiOfferProvider.delete('/offers/$id');
    // if (response.statusCode != 200) {
    //   throw Exception('Failed to delete offer');
    // }
    offers.removeWhere((offer) => offer.id == id);
  }
}
