import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../domain/models/offer/offer.dart';

class OfferItem extends StatelessWidget {
  const OfferItem({super.key, required this.item});

  final Offer item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: CachedNetworkImageProvider(
                    item.profileImageUrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Spacer(),
                          Text(
                            timeago.format(item.createdAt, locale: 'pt_BR'),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            item.userHandle,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(item.text),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: item.images[0],
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInteractionButton(
                        icon: Icons.emoji_emotions_outlined,
                        // icon: Icons.emoji_emotions,
                        count: item.likes ?? 0,
                        onTap: () {
                          // Handle like action
                        },
                      ),
                      _buildInteractionButton(
                        icon: Icons.add_shopping_cart,
                        // icon: Icons.shopping_cart,
                        count: item.retweets ?? 0,
                        onTap: () {
                          // Handle retweet action
                        },
                      ),
                      _buildInteractionButton(
                        icon: Icons.mode_comment_outlined,
                        // icon: Icons.mode_comment,
                        count: item.comments ?? 0,
                        onTap: () {
                          // Handle comment action
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.near_me_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        // icon: const Icon(Icons.cloud, size: 20),
                        onPressed: () {
                          // Handle share action
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        // icon: const Icon(Icons.cloud, size: 20),
                        onPressed: () {
                          // Handle share action
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            Text(
              '$count',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
