import 'offer_rating.dart';

class Offer {
  final String id;
  final String username;
  final String userHandle;
  final String profileImageUrl;
  final String text;
  final List<dynamic> images;
  final DateTime createdAt;
  final String? category;
  final String? store;
  final String? address;
  final OfferRating? ratings;

  Offer({
    required this.id,
    required this.username,
    required this.userHandle,
    required this.profileImageUrl,
    required this.text,
    required this.images,
    required this.createdAt,
    this.category,
    this.store,
    this.address,
    this.ratings,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "userHandle": userHandle,
      "profileImageUrl": profileImageUrl,
      "text": text,
      "images": images,
      "createdAt": createdAt.toString(),
      "category": category,
      "store": store,
      "address": address,
      "ratings": ratings,
    };
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json["id"],
      username: json["username"] as String? ?? "@Anonymous",
      userHandle: json["userHandle"] as String? ?? "Anonymous",
      profileImageUrl: json["profileImageUrl"],
      text: json["text"],
      images: json["images"],
      createdAt: DateTime.parse(json["createdAt"]),
      category: json["category"] as String? ?? "default",
      address: json["address"] as String? ?? "default",
      ratings:
          json["ratings"] != null
              ? OfferRating.fromJson(json["ratings"] as Map<String, dynamic>)
              : null,
      store: json["store"] as String? ?? "default",
    );
  }
}
