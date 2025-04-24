import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/feed/feed_offer.dart';

class FeedOfferMockRepository extends ChangeNotifier {
  // This is a mock repository. In a real application, this would interact with a database or API.
  Future<List<FeedOffer>> getAllOffers() async {
    return offers;
  }

  void addOffer(FeedOffer offer) async {
    // In a real application, this would save the offer to a database or API.
    offers.add(offer);
    notifyListeners();
  }
}

List<FeedOffer> offers = [
  FeedOffer(
    id: Uuid().v4(),
    username: "John Doe",
    userHandle: "@FlutterDev",
    profileImageUrl: "https://picsum.photos/seed/1/600/300",
    text:
        "Check out the latest Flutter release! 🎉 New widgets, performance improvements, and more. #Flutter #MobileDev",
    images: ["https://picsum.photos/500/300?random=1"],
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    likes: 125,
    retweets: 35,
    comments: 10,
  ),
  FeedOffer(
    id: Uuid().v4(),
    username: "Google",
    userHandle: "@Google",
    profileImageUrl: "https://picsum.photos/seed/2/600/300",
    text:
        "Exciting news in AI research! 🧠 We\'re pushing the boundaries of what\'s possible. Learn more here: link.google/ai",
    images: ["https://picsum.photos/500/300?random=2"],
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    likes: 348,
    retweets: 92,
    comments: 28,
  ),
  FeedOffer(
    id: Uuid().v4(),
    username: "Jane Smith",
    userHandle: "@elonmusk",
    profileImageUrl: "https://picsum.photos/500/300?random=3",
    text: "Working on something cool... 🚀",
    images: ["https://picsum.photos/500/300?random=3"],
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    likes: 1500,
    retweets: 250,
    comments: 450,
  ),
];
