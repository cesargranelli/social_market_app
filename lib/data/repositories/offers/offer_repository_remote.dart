import '../../../domain/models/offer/offer_rating.dart';

import '../../../domain/models/offer/offer.dart';
import '../../services/api/offer_api.dart';
import 'offer_repository.dart';

class OfferRepositoryRemote implements OfferRepository {
  OfferRepositoryRemote({required OfferApiFirebase offerApi})
    : _offerApi = offerApi;

  final OfferApiFirebase _offerApi;

  @override
  Future<void> createOffer(Offer offer) async {
    // final response = await _apiOfferProvider.post(
    //   '/offers',
    //   data: offer.toJson(),
    // );
    // if (response.statusCode != 201) {
    //   throw Exception('Failed to create offer');
    // }
    _offerApi.createOffer(offer);
  }

  @override
  Future<List<Offer>> fetchOffers() async {
    final querySnapshot = await _offerApi.fetchOffers();
    return querySnapshot.docs.map((doc) => Offer.fromJson(doc.data())).toList();
  }

  @override
  Future<void> updateOfferRating(
    String offerId,
    OfferRating offerRating,
  ) async {
    // final response = await _apiOfferProvider.put(
    //   '/offers/$offerId/rating',
    //   data: rating.toJson(),
    // );
    // if (response.statusCode != 200) {
    //   throw Exception('Failed to update offer rating');
    // }
    return _offerApi.updateOfferRating(offerId, offerRating);
  }
}
