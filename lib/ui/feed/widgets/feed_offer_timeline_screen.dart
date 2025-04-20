import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/repositories/offers/offers_mock.dartoffers_mock.dart';

class FeedOfferTimelineScreen extends StatelessWidget {
  const FeedOfferTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('X Feed')),
      body: ListView.separated(
        itemCount: offers.length,
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: CachedNetworkImageProvider(
                        offer.profileImageUrl,
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
                                offer.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                offer.userHandle,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Spacer(),
                              Text(
                                timeago.format(
                                  offer.createdAt,
                                  locale: 'pt_BR',
                                ),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          Text(offer.text),
                          if (offer.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: CachedNetworkImage(
                                  imageUrl: offer.imageUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.error),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInteractionButton(
                                  icon: Icons.favorite_border,
                                  count: offer.likes,
                                  onTap: () {
                                    // Handle like action
                                  },
                                ),
                                _buildInteractionButton(
                                  icon: Icons.reply_outlined,
                                  count: offer.comments,
                                  onTap: () {
                                    // Handle comment action
                                  },
                                ),
                                _buildInteractionButton(
                                  icon: Icons.repeat_outlined,
                                  count: offer.retweets,
                                  onTap: () {
                                    // Handle retweet action
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share_outlined),
                                  onPressed: () {
                                    // Handle share action
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 4),
          Text('$count', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
