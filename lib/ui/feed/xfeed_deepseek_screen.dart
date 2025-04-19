import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ======== MODELO DO POST ========
class XPost {
  final String id;
  final String username;
  final String userHandle;
  final String userImage;
  final String content;
  final String? imageUrl;
  late final int likes;
  late final int retweets;
  final int comments;
  final String timeAgo;
  bool isLiked;
  bool isRetweeted;

  XPost({
    required this.id,
    required this.username,
    required this.userHandle,
    required this.userImage,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.retweets,
    required this.comments,
    required this.timeAgo,
    this.isLiked = false,
    this.isRetweeted = false,
  });
}

// ======== TELA PRINCIPAL ========
class XFeedDeepSeekScreen extends StatefulWidget {
  @override
  _XFeedDeepSeekScreenState createState() => _XFeedDeepSeekScreenState();
}

class _XFeedDeepSeekScreenState extends State<XFeedDeepSeekScreen> {
  List<XPost> _posts = [];
  List<String> _trendingTopics = [
    "#FlutterDev",
    "#CopaDoMundo",
    "#BlackFriday",
    "#TikTok",
    "#Bitcoin",
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _posts = [
      XPost(
        id: "1",
        username: "Flutter",
        userHandle: "@FlutterDev",
        userImage: "https://randomuser.me/api/portraits/men/1.jpg",
        content: "Flutter 3.0 is out! Check out the new features 🚀",
        imageUrl: "https://picsum.photos/500/300?random=1",
        likes: 1243,
        retweets: 542,
        comments: 89,
        timeAgo: "2h",
      ),
      XPost(
        id: "2",
        username: "Elon Musk",
        userHandle: "@elonmusk",
        userImage: "https://randomuser.me/api/portraits/men/2.jpg",
        content:
            "The future of AI is exciting and scary at the same time. What do you think?",
        likes: 45231,
        retweets: 12453,
        comments: 3421,
        timeAgo: "5h",
      ),
      XPost(
        id: "3",
        username: "Tech News",
        userHandle: "@TechUpdates",
        userImage: "https://randomuser.me/api/portraits/women/1.jpg",
        content: "Apple announces new MacBook Pro with M2 chip.",
        imageUrl: "https://picsum.photos/500/300?random=3",
        likes: 8921,
        retweets: 2314,
        comments: 543,
        timeAgo: "1d",
      ),
    ];
  }

  void _likePost(String postId) {
    setState(() {
      XPost post = _posts.firstWhere((p) => p.id == postId);
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
    });
  }

  void _retweetPost(String postId) {
    setState(() {
      XPost post = _posts.firstWhere((p) => p.id == postId);
      post.isRetweeted = !post.isRetweeted;
      post.retweets += post.isRetweeted ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Icon(FontAwesomeIcons.twitter, color: Colors.blue),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.star_border),
            onPressed: () {},
          ), // Ícone de favoritos
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Stories (Destaques)
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        "https://randomuser.me/api/portraits/${index % 2 == 0 ? 'men' : 'women'}/$index.jpg",
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Trending Topics
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Trending in Brazil",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _trendingTopics.map((topic) {
                          return Chip(
                            label: Text(
                              topic,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.grey[900],
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Posts
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return XPostCard(
                post: _posts[index],
                onLike: _likePost,
                onRetweet: _retweetPost,
              );
            }, childCount: _posts.length),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit, color: Colors.white),
        backgroundColor: Colors.blue,
        onPressed: () {}, // Postar novo tweet
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Messages"),
        ],
      ),
    );
  }
}

// ======== CARD DO POST (ESTILO X) ========
class XPostCard extends StatelessWidget {
  final XPost post;
  final Function(String) onLike;
  final Function(String) onRetweet;

  const XPostCard({
    required this.post,
    required this.onLike,
    required this.onRetweet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey[900],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho (usuário + tempo)
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.userImage),
                  radius: 20,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(post.userHandle, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Spacer(),
                Text(post.timeAgo, style: TextStyle(color: Colors.grey)),
                IconButton(
                  icon: Icon(Icons.more_vert, size: 16, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
            // Conteúdo do post
            SizedBox(height: 8),
            Text(
              post.content,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            // Imagem (se houver)
            if (post.imageUrl != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Interações (like, retweet, etc.)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    post.isRetweeted
                        ? FontAwesomeIcons.retweet
                        : FontAwesomeIcons.retweet,
                    color: post.isRetweeted ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => onRetweet(post.id),
                ),
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => onLike(post.id),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
            // Contadores (likes, retweets)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "${post.comments}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "${post.retweets}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Text("${post.likes}", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
