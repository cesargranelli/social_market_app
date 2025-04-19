// Gemini
import 'package:flutter/material.dart';

class OfferTimelineScreen extends StatelessWidget {
  OfferTimelineScreen({super.key});

  final List<Offer> offers = [
    Offer(
      supermarketName: 'Supermercado Bom Preço',
      productName: 'Leite Integral Parmalat',
      imageUrl: 'https://via.placeholder.com/150/FFC107/000000?Text=Leite',
      originalPrice: 5.50,
      discountedPrice: 4.99,
      discountPercentage: '9%',
      timeAgo: '5 min',
      likes: 12,
      comments: 3,
    ),
    Offer(
      supermarketName: 'Mercado Central',
      productName: 'Arroz Tipo 1 Camil (5kg)',
      imageUrl: 'https://via.placeholder.com/150/4CAF50/FFFFFF?Text=Arroz',
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
      imageUrl: 'https://via.placeholder.com/150/F44336/FFFFFF?Text=Detergente',
      originalPrice: 3.20,
      discountedPrice: 2.79,
      discountPercentage: '13%',
      timeAgo: '30 min',
      likes: 8,
      comments: 1,
    ),
    // Adicione mais ofertas aqui...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas Imperdíveis')),
      body: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 16,
                        child: Icon(Icons.store, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        offer.supermarketName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        offer.timeAgo,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Image.network(
                  offer.imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.productName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Text(
                            'R\$ ${offer.discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'R\$ ${offer.originalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              '-${offer.discountPercentage}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4.0),
                          Text('${offer.likes}'),
                          const SizedBox(width: 16.0),
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4.0),
                          Text('${offer.comments}'),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              // Ação ao clicar em "Ver Oferta"
                            },
                            child: const Text('Ver Oferta'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
  });
}
