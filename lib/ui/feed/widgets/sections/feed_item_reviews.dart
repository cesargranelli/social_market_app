import 'package:flutter/material.dart';
import 'package:social_market_app/domain/models/offer/offer_who.dart';

import '/domain/models/offer/offer_rating.dart';

class FeedItemReviews extends StatefulWidget {
  const FeedItemReviews({super.key, required this.offerRating});

  final OfferRating offerRating;

  @override
  State<FeedItemReviews> createState() => _FeedItemReviewsState();
}

class _FeedItemReviewsState extends State<FeedItemReviews> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInteractionButton(
                  icon:
                      _isLiked(widget.offerRating)
                          ? Icons.emoji_emotions_outlined
                          : Icons.emoji_emotions,
                  amount: widget.offerRating.likes ?? 0,
                  onTap: () {
                    if (widget.offerRating.who == null) {
                      widget.offerRating.who = OfferWho(
                        username: "username",
                        rating: "rating",
                        createdAt: "createdAt",
                      );
                      widget.offerRating.likes =
                          (widget.offerRating.likes ?? 0) + 1;
                    } else {
                      widget.offerRating.who = null;
                      widget.offerRating.likes =
                          (widget.offerRating.likes ?? 0) - 1;
                    }
                    setState(() {});
                  },
                ),
                // _buildInteractionButton(
                //   icon: Icons.add_shopping_cart,
                //   // icon: Icons.shopping_cart,
                //   amount: widget.purchases,
                //   onTap: () {
                //     // Handle retweet action
                //   },
                // ),
                // _buildInteractionButton(
                //   icon: Icons.attach_money_rounded,
                //   // icon: Icons.mode_comment,
                //   amount: widget.verifications,
                //   onTap: () {
                //     // Handle comment action
                //   },
                // ),
                // _buildInteractionButton(
                //   icon: Icons.near_me_outlined,
                //   // icon: Icons.mode_comment,
                //   amount: widget.replications,
                //   onTap: () {
                //     // Handle comment action
                //   },
                // ),
                // _buildInteractionButton(
                //   icon: Icons.share,
                //   // icon: Icons.mode_comment,
                //   amount: widget.shares,
                //   onTap: () {
                //     // Handle comment action
                //   },
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildInteractionButton({
  required IconData icon,
  required int amount,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          Text(
            (amount < 1000)
                ? "$amount"
                : "${(amount / 1000).toStringAsFixed(1)}k",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

bool _isLiked(OfferRating offerRating) {
  return offerRating.who?.username.contains("_nameController.text") ?? true;
}
