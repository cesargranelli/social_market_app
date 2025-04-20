class FeedOffer {
  final String username; // usuario // username
  final String userHandle;
  final String profileImageUrl; // userImage
  final String text; // texto // descricao // content
  final String? imageUrl; // postImage // imagem
  final DateTime createdAt; // tempo // timeAgo
  final int likes; // isLiked // isFavorita
  final int retweets; // isRetweeted
  final int comments;
  //
  // final String local; // address
  // final String mercado; // estabelecimento // supermarketName // loja
  // final double distanciaKm;
  // final int reputacao;
  // final String id; // uuid
  // final String productName; // caption
  // final bool isTrending; // Novo campo para ofertas em destaque
  // final String categoria;
  //

  FeedOffer({
    required this.username,
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
