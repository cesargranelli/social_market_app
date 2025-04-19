import 'package:flutter/material.dart';

class OfertaX {
  final String usuario;
  final String texto;
  final String? imagemUrl;
  final String tempo;
  final String local;

  OfertaX({
    required this.usuario,
    required this.texto,
    this.imagemUrl,
    required this.tempo,
    required this.local,
  });
}

class XFeedChatGptScreen extends StatelessWidget {
  final List<OfertaX> ofertas = [
    OfertaX(
      usuario: '@promo_da_ana',
      texto: 'Leite Italac 1L por R\$ 3,49 no Mercado Ideal da Av. Paulista!',
      imagemUrl: 'https://picsum.photos/seed/1/600/300',
      tempo: '2h',
      local: '1.2km',
    ),
    OfertaX(
      usuario: '@consumidor007',
      texto: 'Alface e tomate com preço bom no mercado municipal 🍅',
      imagemUrl: null,
      tempo: '3h',
      local: '2.5km',
    ),
    OfertaX(
      usuario: '@descontosz',
      texto: 'Papel higiênico Personal c/ 12 por R\$ 9,99. 😱',
      imagemUrl: 'https://picsum.photos/seed/2/600/300',
      tempo: '5h',
      local: '0.8km',
    ),
  ];

  XFeedChatGptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ofertas em tempo real"),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: ofertas.length,
        itemBuilder: (context, index) {
          return TweetCard(oferta: ofertas[index]);
        },
      ),
    );
  }
}

class TweetCard extends StatelessWidget {
  final OfertaX oferta;

  const TweetCard({super.key, required this.oferta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              const CircleAvatar(radius: 20, child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Text(
                oferta.usuario,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${oferta.tempo} • ${oferta.local}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Texto da oferta
          Text(oferta.texto, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),

          // Imagem (se existir)
          if (oferta.imagemUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(oferta.imagemUrl!),
            ),

          const SizedBox(height: 10),

          // Botões estilo X
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.repeat, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
