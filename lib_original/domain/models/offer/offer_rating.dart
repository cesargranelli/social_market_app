import 'offer_who.dart';

class OfferRating {
  late int? likes;
  late int? purchases;
  late int? verifications;
  late int? replications;
  late int? shares;
  late OfferWho? who;

  OfferRating({
    this.likes,
    this.purchases,
    this.verifications,
    this.replications,
    this.shares,
    this.who,
  });

  Map<String, dynamic> toJson() {
    return {
      "likes": likes,
      "purchases": purchases,
      "verifications": verifications,
      "replications": replications,
      "shares": shares,
      "who": who?.toJson(),
    };
  }

  factory OfferRating.fromJson(Map<String, dynamic> json) {
    return OfferRating(
      likes: json['likes'] as int?,
      purchases: json['purchases'] as int?,
      verifications: json['verifications'] as int?,
      replications: json['replications'] as int?,
      shares: json['shares'] as int?,
      who: json['who'],
    );
  }
}
