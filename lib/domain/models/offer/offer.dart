class Offer {
  final String id;
  final String username;
  final String userHandle;
  final String profileImageUrl;
  final String text;
  final List<String> images;
  final DateTime createdAt;
  final String? category;
  final String? store;
  final String? address;
  final int? likes;
  final int? retweets;
  final int? comments;
  final int? truth;
  final int? bought;

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
    this.likes,
    this.retweets,
    this.comments,
    this.truth,
    this.bought,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userHandle': userHandle,
      'profileImageUrl': profileImageUrl,
      'text': text,
      'images': images,
      // 'createdAt': createdAt.toIso8601String(),
      'createdAt': '',
      'category': category,
      'store': store,
      'address': address,
      'likes': likes,
      'retweets': retweets,
      'comments': comments,
      'truth': truth,
      'bought': bought,
    };
  }
}
