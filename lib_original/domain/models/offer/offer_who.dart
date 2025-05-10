class OfferWho {
  late String username;
  late String rating;
  late String createdAt;

  OfferWho({
    required this.username,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {"username": username, "rating": rating, "createdAt": createdAt};
  }

  factory OfferWho.fromJson(Map<String, dynamic> json) {
    return OfferWho(
      username: json['username'] as String,
      rating: json['rating'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
