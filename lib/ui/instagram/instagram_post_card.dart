import 'package:flutter/material.dart';

import 'instagram_post.dart';

class InstagramPostCard extends StatelessWidget {
  final InstagramPost post;

  const InstagramPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho (usuário + tempo)
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.userImage),
                  radius: 16,
                ),
                SizedBox(width: 8),
                Text(
                  post.username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(post.timeAgo, style: TextStyle(color: Colors.grey)),
                IconButton(
                  icon: Icon(Icons.more_vert, size: 16),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Imagem do post
          Image.network(
            post.postImage,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
          // Ícones de interação (curtir, comentar, compartilhar)
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline),
                  onPressed: () {},
                ),
                IconButton(icon: Icon(Icons.send), onPressed: () {}),
                Spacer(),
                IconButton(icon: Icon(Icons.bookmark_border), onPressed: () {}),
              ],
            ),
          ),
          // Curtidas
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "${post.likes} curtidas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Legenda (usuário + descrição)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: post.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " ${post.caption}"),
                ],
              ),
            ),
          ),
          // Comentários
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "Ver todos os ${post.comments} comentários",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
