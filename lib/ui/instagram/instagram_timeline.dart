// DeepSeek
import 'package:flutter/material.dart';

import 'instagram_post.dart';
import 'instagram_post_card.dart';

class InstagramTimeline extends StatelessWidget {
  // Lista de posts fictícios (simulando dados do Instagram)
  final List<InstagramPost> posts = [
    InstagramPost(
      username: "flutter_dev",
      userImage: "https://randomuser.me/api/portraits/women/44.jpg",
      postImage: "https://picsum.photos/500/500?random=1",
      caption: "Aprendendo Flutter! ❤️ #coding #flutter",
      likes: 342,
      comments: 28,
      timeAgo: "2 horas atrás",
    ),
    InstagramPost(
      username: "travel_lover",
      userImage: "https://randomuser.me/api/portraits/men/32.jpg",
      postImage: "https://picsum.photos/500/500?random=2",
      caption: "Praia paradisíaca hoje! 🏖️ #travel #beach",
      likes: 1024,
      comments: 86,
      timeAgo: "5 horas atrás",
    ),
    InstagramPost(
      username: "foodie_gram",
      userImage: "https://randomuser.me/api/portraits/women/68.jpg",
      postImage: "https://picsum.photos/500/500?random=3",
      caption: "Pizza caseira deliciosa! 🍕 #food #homemade",
      likes: 876,
      comments: 45,
      timeAgo: "1 dia atrás",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Instagram",
          style: TextStyle(fontFamily: 'Billabong', fontSize: 28),
        ),
        actions: [
          IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: Icon(Icons.send), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return InstagramPostCard(post: posts[index]);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            IconButton(icon: Icon(Icons.add_box_outlined), onPressed: () {}),
            IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
            IconButton(icon: Icon(Icons.person_outline), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
