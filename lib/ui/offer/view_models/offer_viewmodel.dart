import '../../../data/repositories/offers/offer_repository.dart';
import '../../../domain/models/offer/offer.dart';

class OfferViewModel {
  OfferViewModel({required OfferRepository offerRepository})
    : _offerRepository = offerRepository;

  final OfferRepository _offerRepository;

  final List<Offer> _feedOffers = [];
  List<Offer> get offers => _feedOffers;

  void addOffer(Offer offer) {
    _offerRepository.createOffer(offer);
  }

  Future<List<Offer>> getFeedOffers() {
    return _offerRepository.fetchOffers();
  }
}
