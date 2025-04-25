import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiOfferProvider {
  final String baseUrl;

  ApiOfferProvider({required this.baseUrl});

  Future<List<dynamic>> fetchOffers() async {
    final url = Uri.parse('$baseUrl/offers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load offers');
    }
  }

  Future<Map<String, dynamic>> createOffer(
    Map<String, dynamic> offerData,
  ) async {
    final url = Uri.parse('$baseUrl/offers');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(offerData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create offer');
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
