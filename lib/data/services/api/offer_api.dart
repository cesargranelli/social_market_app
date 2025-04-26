import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/models/offer/offer.dart';

class OfferApiFirebase {
  OfferApiFirebase();

  Future<void> createOffer(Offer offer) async {
    Map<String, dynamic> offerData = offer.toJson();
    await FirebaseFirestore.instance.collection("offers").add(offerData);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchOffers() async {
    return await FirebaseFirestore.instance.collection("offers").get();
  }
}
