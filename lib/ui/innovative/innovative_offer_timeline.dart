// Gemini
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Para carregamento eficiente de imagens

class Offer {
  final String supermarketName;
  final String productName;
  final String imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final String discountPercentage;
  final String timeAgo;
  final int likes;
  final int comments;
  final bool isTrending; // Novo campo para ofertas em destaque

  Offer({
    required this.supermarketName,
    required this.productName,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.timeAgo,
    required this.likes,
    required this.comments,
    this.isTrending = false,
  });
}

class InnovativeOfferFeedScreen extends StatefulWidget {
  const InnovativeOfferFeedScreen({super.key});

  @override
  State<InnovativeOfferFeedScreen> createState() =>
      _InnovativeOfferFeedScreenState();
}

class _InnovativeOfferFeedScreenState extends State<InnovativeOfferFeedScreen>
    with TickerProviderStateMixin {
  final List<Offer> offers = [
    Offer(
      supermarketName: 'Supermercado Bom Preço',
      productName: 'Leite Integral Parmalat',
      imageUrl: 'https://via.placeholder.com/200/FFC107/000000?Text=Leite',
      originalPrice: 5.50,
      discountedPrice: 4.99,
      discountPercentage: '9%',
      timeAgo: '5 min',
      likes: 12,
      comments: 3,
      isTrending: true,
    ),
    Offer(
      supermarketName: 'Mercado Central',
      productName: 'Arroz Tipo 1 Camil (5kg)',
      imageUrl: 'https://via.placeholder.com/200/4CAF50/FFFFFF?Text=Arroz',
      originalPrice: 28.90,
      discountedPrice: 24.50,
      discountPercentage: '15%',
      timeAgo: '15 min',
      likes: 25,
      comments: 8,
    ),
    Offer(
      supermarketName: 'Atacadão das Ofertas',
      productName: 'Detergente Ypê (500ml)',
      imageUrl: 'https://via.placeholder.com/200/F44336/FFFFFF?Text=Detergente',
      originalPrice: 3.20,
      discountedPrice: 2.79,
      discountPercentage: '13%',
      timeAgo: '30 min',
      likes: 8,
      comments: 1,
      isTrending: true,
    ),
    Offer(
      supermarketName: 'Hortifruti da Vila',
      productName: 'Maçã Fuji (kg)',
      imageUrl:
          'https://via.placeholder.com/200/E91E63/FFFFFF?Text=Ma%C3%A7%C3%A3',
      originalPrice: 7.99,
      discountedPrice: 5.99,
      discountPercentage: '25%',
      timeAgo: '1 hr',
      likes: 42,
      comments: 15,
    ),
    // Adicione mais ofertas aqui...
  ];

  final ScrollController _scrollController = ScrollController();
  final List<String> filters = [
    'Todos',
    'Alimentos',
    'Bebidas',
    'Limpeza',
    'Higiene',
  ];
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas Incríveis')),
      body: Column(
        children: [
          // Barra de Filtros Flutuante e Interativa
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children:
                  filters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final filter = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _selectedFilterIndex == index,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilterIndex =
                                selected ? index : _selectedFilterIndex;
                            // Adicione aqui a lógica para filtrar as ofertas
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                final double verticalOffset =
                    index * 20.0; // Efeito cascata sutil

                return Transform.translate(
                  offset: Offset(0, verticalOffset),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale:
                              1 -
                              (0.05 *
                                  (1 - value)), // Ligeiro scaling ao aparecer
                          child: OfferCard(offer: offer),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OfferCard extends StatefulWidget {
  final Offer offer;

  const OfferCard({super.key, required this.offer});

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> with TickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _likeController;
  late Animation<double> _likeAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _likeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeController.forward();
    });
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -10) {
          setState(() {
            _showDetails = true;
          });
        } else if (details.primaryDelta! > 10) {
          setState(() {
            _showDetails = false;
          });
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.offer.imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                if (widget.offer.isTrending)
                  Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.1),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Text(
                              '🔥 Destaque!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, size: 16, color: Colors.grey),
                      const SizedBox(width: 4.0),
                      Text(
                        widget.offer.supermarketName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        widget.offer.timeAgo,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.offer.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Text(
                        'R\$ ${widget.offer.discountedPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'R\$ ${widget.offer.originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          '-${widget.offer.discountPercentage}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: SizedBox(
                      height: _showDetails ? 60 : 0,
                      child: OverflowBox(
                        maxHeight: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Detalhes adicionais da oferta podem ser exibidos aqui ao arrastar o card para baixo. Imagine informações sobre validade, unidades disponíveis, etc.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: ScaleTransition(
                          scale: _likeAnimation,
                          child: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.redAccent : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4.0),
                          Text('${widget.offer.comments}'),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Ação para ver a oferta completa
                        },
                        child: const Text('Ver Mais'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
