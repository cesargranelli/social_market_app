import 'package:flutter/material.dart';

import '../../../domain/models/offer/offer.dart';
import '../../../domain/models/offer/offer_rating.dart';
import 'sections/feed_item_header.dart';
import 'sections/feed_item_image.dart';
import 'sections/feed_item_reviews.dart';

class OfferItem extends StatelessWidget {
  const OfferItem({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          FeedItemHeader(
            imageProfile: offer.profileImageUrl,
            username: offer.username,
            createdAt: offer.createdAt,
            userHandle: offer.userHandle,
          ),
          const SizedBox(height: 8),
          FeedItemImage(text: offer.text, imageUrl: offer.images[0]),
          const SizedBox(height: 8),
          FeedItemReviews(offerRating: offer.ratings ?? OfferRating()),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
