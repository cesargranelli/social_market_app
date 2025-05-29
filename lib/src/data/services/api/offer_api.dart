import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../models/offer.dart';
import '../../../models/offer_rating.dart';

class OfferApiFirebase extends ChangeNotifier {
  OfferApiFirebase();

  Future<void> createOffer(Offer offer) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imagesRef = storageRef.child('images/${offer.images[0].hashCode}');

    await imagesRef.putFile(offer.images[0]);

    String downloadURL = await imagesRef.getDownloadURL();
    offer.images[0] = downloadURL;

    Map<String, dynamic> offerData = offer.toJson();
    await FirebaseFirestore.instance
        .collection("offers")
        .doc(offer.id)
        .set(offerData);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchOffers() async {
    return await FirebaseFirestore.instance.collection("offers").get();
  }

  Future<void> updateOfferRating(String offerId, OfferRating rating) async {
    await FirebaseFirestore.instance.collection("offers").doc(offerId).update({
      "ratings": rating.toJson(),
    });
  }
}
