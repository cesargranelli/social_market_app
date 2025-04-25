import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:social_market_app/domain/models/offer/offer.dart';

class OfferApiFirebase {
  final String baseUrl;

  OfferApiFirebase({required this.baseUrl});

  Future<void> createOffer(Offer offer) async {
    Map<String, dynamic> offerData = offer.toJson();
    print(offerData);
    await FirebaseFirestore.instance.collection("offers").add(offerData);
  }

  Future<List<dynamic>> fetchOffers() async {
    final url = Uri.parse('$baseUrl/offers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load offers');
    }
  }

  Future<Map<String, dynamic>> updateOffer(
    String id,
    Map<String, dynamic> offerData,
  ) async {
    final url = Uri.parse('$baseUrl/offers/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(offerData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update offer');
    }
  }

  Future<void> deleteOffer(String id) async {
    final url = Uri.parse('$baseUrl/offers/$id');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete offer');
    }
  }
}
