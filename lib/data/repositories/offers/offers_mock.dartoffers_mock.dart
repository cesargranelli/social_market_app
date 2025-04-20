import '../../../domain/models/feed/feed_offer.dart';

final List<FeedOffer> offers = [
  FeedOffer(
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
  FeedOffer(
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
  FeedOffer(
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
