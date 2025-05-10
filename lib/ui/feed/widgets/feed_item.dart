import 'package:flutter/material.dart';

import '/ui/feed/view_models/feed_viewmodel.dart';
import '../../../domain/models/offer/offer.dart';
import 'sections/feed_item_header.dart';
import 'sections/feed_item_image.dart';
import 'sections/feed_item_reviews.dart';

class FeedItem extends StatefulWidget {
  const FeedItem({super.key, required this.offer, required this.viewModel});

  final Offer offer;
  final FeedViewModel viewModel;

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
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
              imageProfile: widget.offer.profileImageUrl,
              username: widget.offer.username,
              createdAt: widget.offer.createdAt,
              userHandle: widget.offer.userHandle,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(widget.offer.text),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FeedItemImage(imageUrl: widget.offer.images[0]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FeedItemReviews(
              offer: widget.offer,
              viewModel: widget.viewModel,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
