import 'package:flutter/material.dart';

import '../../../../domain/models/offer/offer.dart';
import '/domain/models/offer/offer_rating.dart';
import '/domain/models/offer/offer_who.dart';
import '../../view_models/feed_viewmodel.dart';
import '../components/interaction_button_reviews.dart';

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
              widget.offer.ratings.likes =
                  (widget.offer.ratings.likes ?? 0) - 1;
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
        // InteractionButtonReviews(
        //   icon:
        //       _isLiked(widget.offerRating) != "purchases"
        //           ? Icons.add_shopping_cart
        //           : Icons.shopping_cart,
        //   amount: widget.offerRating.purchases ?? 0,
        //   onTap: () {
        //     if (_isLiked(widget.offerRating) == "purchases") {
        //       widget.offerRating.who = null;
        //       widget.offerRating.purchases =
        //           (widget.offerRating.purchases ?? 0) - 1;
        //     } else {
        //       widget.offerRating.likes = null;
        //       widget.offerRating.replications = null;
        //       widget.offerRating.verifications = null;
        //       // widget.offerRating.shares = null;

        //       widget.offerRating.who = OfferWho(
        //         username: "_nameController.text",
        //         rating: "purchases",
        //         createdAt: "createdAt",
        //       );
        //       widget.offerRating.purchases =
        //           (widget.offerRating.purchases ?? 0) + 1;
        //     }
        //     setState(() {});
        //   },
        // ),
        // InteractionButtonReviews(
        //   icon:
        //       _isLiked(widget.offerRating) != "verifications"
        //           ? Icons.paid_outlined
        //           : Icons.paid,
        //   amount: widget.offerRating.verifications ?? 0,
        //   onTap: () {
        //     if (_isLiked(widget.offerRating) == "verifications") {
        //       widget.offerRating.who = null;
        //       widget.offerRating.verifications =
        //           (widget.offerRating.verifications ?? 0) - 1;
        //     } else {
        //       widget.offerRating.likes = null;
        //       widget.offerRating.replications = null;
        //       widget.offerRating.purchases = null;
        //       // widget.offerRating.shares = null;

        //       widget.offerRating.who = OfferWho(
        //         username: "_nameController.text",
        //         rating: "verifications",
        //         createdAt: "createdAt",
        //       );
        //       widget.offerRating.verifications =
        //           (widget.offerRating.verifications ?? 0) + 1;
        //     }
        //     setState(() {});
        //   },
        // ),
        // InteractionButtonReviews(
        //   icon:
        //       _isLiked(widget.offerRating) != "replications"
        //           ? Icons.near_me_outlined
        //           : Icons.near_me,
        //   amount: widget.offerRating.replications ?? 0,
        //   onTap: () {
        //     if (_isLiked(widget.offerRating) == "replications") {
        //       widget.offerRating.who = null;
        //       widget.offerRating.replications =
        //           (widget.offerRating.replications ?? 0) - 1;
        //     } else {
        //       widget.offerRating.likes = null;
        //       widget.offerRating.verifications = null;
        //       widget.offerRating.purchases = null;
        //       // widget.offerRating.shares = null;

        //       widget.offerRating.who = OfferWho(
        //         username: "_nameController.text",
        //         rating: "replications",
        //         createdAt: "createdAt",
        //       );
        //       widget.offerRating.replications =
        //           (widget.offerRating.replications ?? 0) + 1;
        //     }
        //     setState(() {});
        //   },
        // ),
        // InteractionButtonReviews(
        //   icon:
        //       widget.offerRating.shares == null
        //           ? Icons.share_outlined
        //           : Icons.share,
        //   amount: widget.offerRating.shares ?? 0,
        //   onTap: () {
        //     widget.offerRating.shares = (widget.offerRating.shares ?? 0) + 1;
        //     setState(() {});
        //   },
        // ),
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
