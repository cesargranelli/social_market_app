import 'package:flutter/material.dart';

import '../../../domain/models/offer/offer.dart';
import '../../../domain/models/offer/offer_rating.dart';
import 'sections/feed_item_header.dart';
import 'sections/feed_item_image.dart';
import 'sections/feed_item_reviews.dart';

class FeedItem extends StatelessWidget {
  const FeedItem({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FeedItemHeader(
              imageProfile: offer.profileImageUrl,
              username: offer.username,
              createdAt: offer.createdAt,
              userHandle: offer.userHandle,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(offer.text),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FeedItemImage(imageUrl: offer.images[0]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FeedItemReviews(offerRating: offer.ratings ?? OfferRating()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
