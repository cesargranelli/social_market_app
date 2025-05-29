import '../../../models/offer.dart';
import '../../services/api/offer_api.dart';
import '../anonymous_repository.dart';

class AnonymousRepositoryRemote implements AnonymousRepository {
  AnonymousRepositoryRemote({required OfferApiFirebase offerApi})
    : _offerApi = offerApi;

  final OfferApiFirebase _offerApi;

  Future<List<Offer>> fetchOffers() async {
    final querySnapshot = await _offerApi.fetchOffers();
    return querySnapshot.docs.map((doc) => Offer.fromJson(doc.data())).toList();
  }

  @override
  Future<void> register() async {}
}
