// Gemini
import 'package:flutter/material.dart';

class Post {
  final String userName;
  final String userHandle;
  final String profileImageUrl;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final int likes;
  final int comments;

  Post({
    required this.userName,
    required this.userHandle,
    required this.profileImageUrl,
    required this.text,
    this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.comments,
  });
}

class GooglePlusTimelineScreen extends StatelessWidget {
  GooglePlusTimelineScreen({super.key});

  final List<Post> posts = [
    Post(
      userName: 'Flutter Enthusiast',
      userHandle: '+FlutterDev',
      profileImageUrl: 'https://via.placeholder.com/40/007AFF/FFFFFF?Text=F',
      text:
          'Just finished building a beautiful UI in Flutter! The flexibility of this framework is amazing. #Flutter #UI #MobileDev',
      createdAt: DateTime(2025, 4, 19, 23, 40),
      likes: 25,
      comments: 5,
    ),
    Post(
      userName: 'Material Design Updates',
      userHandle: '+MaterialDesign',
      profileImageUrl: 'https://via.placeholder.com/40/673AB7/FFFFFF?Text=M',
      text:
          'Exploring the new color palettes in Material Design 3. The dynamic color feature is a game-changer!',
      imageUrl:
          'https://via.placeholder.com/400x200/673AB7/FFFFFF?Text=Material+Design+3',
      createdAt: DateTime(2025, 4, 19, 23, 30),
      likes: 42,
      comments: 12,
    ),
    Post(
      userName: 'Coding Adventures',
      userHandle: '+CodeNinja',
      profileImageUrl: 'https://via.placeholder.com/40/2E7D32/FFFFFF?Text=C',
      text:
          'Struggling with a tricky algorithm but determined to solve it! Wish me luck. 💻 #CodingLife #Algorithms',
      createdAt: DateTime(2025, 4, 19, 23, 20),
      likes: 18,
      comments: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google+ Inspired')),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(post.profileImageUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.userName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              post.userHandle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (post.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(post.imageUrl!),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.comment_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.comments}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
