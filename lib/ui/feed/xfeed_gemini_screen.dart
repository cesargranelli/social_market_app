import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class Tweet {
  final String userName;
  final String userHandle;
  final String profileImageUrl;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final int likes;
  final int retweets;
  final int comments;

  Tweet({
    required this.userName,
    required this.userHandle,
    required this.profileImageUrl,
    required this.text,
    this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.retweets,
    required this.comments,
  });
}

class XFeedGeminiScreen extends StatelessWidget {
  XFeedGeminiScreen({super.key});

  final List<Tweet> tweets = [
    Tweet(
      userName: 'FlutterDev',
      userHandle: '@FlutterDev',
      profileImageUrl:
          'https://pbs.twimg.com/profile_images/1488797002934433793/Ku_59Y9R_400x400.jpg',
      text:
          'Check out the latest Flutter release! 🎉 New widgets, performance improvements, and more. #Flutter #MobileDev',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      likes: 125,
      retweets: 35,
      comments: 10,
    ),
    Tweet(
      userName: 'Google',
      userHandle: '@Google',
      profileImageUrl:
          'https://pbs.twimg.com/profile_images/1323248585333929984/m6y_j-1H_400x400.png',
      text:
          'Exciting news in AI research! 🧠 We\'re pushing the boundaries of what\'s possible. Learn more here: link.google/ai',
      imageUrl:
          'https://via.placeholder.com/400x200/4285F4/FFFFFF?Text=Google+AI',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likes: 348,
      retweets: 92,
      comments: 28,
    ),
    Tweet(
      userName: 'Elon Musk',
      userHandle: '@elonmusk',
      profileImageUrl:
          'https://pbs.twimg.com/profile_images/1595909687677460480/WzQW19EF_400x400.jpg',
      text: 'Working on something cool... 🚀',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 1500,
      retweets: 250,
      comments: 450,
    ),
    // Add more tweets here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('X Feed')),
      body: ListView.separated(
        itemCount: tweets.length,
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final tweet = tweets[index];
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
                        tweet.profileImageUrl,
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
                                tweet.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tweet.userHandle,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Spacer(),
                              Text(
                                timeago.format(
                                  tweet.createdAt,
                                  locale: 'pt_BR',
                                ),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(tweet.text),
                          if (tweet.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: CachedNetworkImage(
                                  imageUrl: tweet.imageUrl!,
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
                                  count: tweet.likes,
                                  onTap: () {
                                    // Handle like action
                                  },
                                ),
                                _buildInteractionButton(
                                  icon: Icons.reply_outlined,
                                  count: tweet.comments,
                                  onTap: () {
                                    // Handle comment action
                                  },
                                ),
                                _buildInteractionButton(
                                  icon: Icons.repeat_outlined,
                                  count: tweet.retweets,
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
