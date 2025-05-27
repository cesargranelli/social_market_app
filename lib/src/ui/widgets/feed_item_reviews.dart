import 'package:flutter/material.dart';

import '../../domain/models/offer/offer_rating.dart';
import '../../domain/models/offer/offer_who.dart';
import '../../domain/models/offer/offer.dart';
import 'feed_viewmodel.dart';
import 'interaction_button_reviews.dart';

class FeedItemReviews extends StatefulWidget {
  const FeedItemReviews({
    super.key,
    required this.offer,
    required this.viewModel,
  });

  final Offer offer;
  final FeedViewModel viewModel;

  @override
  State<FeedItemReviews> createState() => _FeedItemReviewsState();
}

class _FeedItemReviewsState extends State<FeedItemReviews> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InteractionButtonReviews(
          icon:
              _isLiked(widget.offer.ratings) != "likes"
                  ? Icons.emoji_emotions_outlined
                  : Icons.emoji_emotions,
          amount: widget.offer.ratings.likes ?? 0,
          onTap: () {
            if (_isLiked(widget.offer.ratings) == "likes") {
              widget.offer.ratings.who = null;
              widget.offer.ratings.likes = null;
            } else {
              widget.offer.ratings.purchases = null;
              widget.offer.ratings.replications = null;
              widget.offer.ratings.verifications = null;

              widget.offer.ratings.who = OfferWho(
                username: "_nameController.text",
                rating: "likes",
                createdAt: "createdAt",
              );
              widget.offer.ratings.likes =
                  (widget.offer.ratings.likes ?? 0) + 1;
            }

            widget.viewModel.updateOfferRating(
              widget.offer.id,
              widget.offer.ratings,
            );
            setState(() {});
          },
        ),
        InteractionButtonReviews(
          icon:
              _isLiked(widget.offer.ratings) != "purchases"
                  ? Icons.add_shopping_cart
                  : Icons.shopping_cart,
          amount: widget.offer.ratings.purchases ?? 0,
          onTap: () {
            if (_isLiked(widget.offer.ratings) == "purchases") {
              widget.offer.ratings.who = null;
              widget.offer.ratings.purchases = null;
            } else {
              widget.offer.ratings.likes = null;
              widget.offer.ratings.replications = null;
              widget.offer.ratings.verifications = null;

              widget.offer.ratings.who = OfferWho(
                username: "_nameController.text",
                rating: "purchases",
                createdAt: "createdAt",
              );
              widget.offer.ratings.purchases =
                  (widget.offer.ratings.purchases ?? 0) + 1;
            }

            widget.viewModel.updateOfferRating(
              widget.offer.id,
              widget.offer.ratings,
            );
            setState(() {});
          },
        ),
        InteractionButtonReviews(
          icon:
              _isLiked(widget.offer.ratings) != "verifications"
                  ? Icons.paid_outlined
                  : Icons.paid,
          amount: widget.offer.ratings.verifications ?? 0,
          onTap: () {
            if (_isLiked(widget.offer.ratings) == "verifications") {
              widget.offer.ratings.who = null;
              widget.offer.ratings.verifications = null;
            } else {
              widget.offer.ratings.likes = null;
              widget.offer.ratings.replications = null;
              widget.offer.ratings.purchases = null;

              widget.offer.ratings.who = OfferWho(
                username: "_nameController.text",
                rating: "verifications",
                createdAt: "createdAt",
              );
              widget.offer.ratings.verifications =
                  (widget.offer.ratings.verifications ?? 0) + 1;
            }

            widget.viewModel.updateOfferRating(
              widget.offer.id,
              widget.offer.ratings,
            );
            setState(() {});
          },
        ),
        InteractionButtonReviews(
          icon:
              _isLiked(widget.offer.ratings) != "replications"
                  ? Icons.near_me_outlined
                  : Icons.near_me,
          amount: widget.offer.ratings.replications ?? 0,
          onTap: () {
            if (_isLiked(widget.offer.ratings) == "replications") {
              widget.offer.ratings.who = null;
              widget.offer.ratings.replications = null;
            } else {
              widget.offer.ratings.likes = null;
              widget.offer.ratings.verifications = null;
              widget.offer.ratings.purchases = null;

              widget.offer.ratings.who = OfferWho(
                username: "_nameController.text",
                rating: "replications",
                createdAt: "createdAt",
              );
              widget.offer.ratings.replications =
                  (widget.offer.ratings.replications ?? 0) + 1;
            }

            widget.viewModel.updateOfferRating(
              widget.offer.id,
              widget.offer.ratings,
            );
            setState(() {});
          },
        ),
        InteractionButtonReviews(
          icon:
              widget.offer.ratings.shares == null
                  ? Icons.share_outlined
                  : Icons.share,
          amount: widget.offer.ratings.shares ?? 0,
          onTap: () {
            widget.offer.ratings.shares =
                (widget.offer.ratings.shares ?? 0) + 1;
            setState(() {});
          },
        ),
      ],
    );
  }
}

String _isLiked(OfferRating offerRating) {
  if (offerRating.who?.username.contains("_nameController.text") ?? false) {
    return offerRating.who!.rating;
  } else {
    return "";
  }
}
