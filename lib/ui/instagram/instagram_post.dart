class InstagramPost {
  final String username;
  final String userImage;
  final String postImage;
  final String caption;
  final int likes;
  final int comments;
  final String timeAgo;

  InstagramPost({
    required this.username,
    required this.userImage,
    required this.postImage,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.timeAgo,
  });
}
