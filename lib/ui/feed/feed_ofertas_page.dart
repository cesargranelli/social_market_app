// ChatGPT
import 'package:flutter/material.dart';

class Oferta {
  final String usuario;
  final String mercado;
  final String descricao;
  final String imagemUrl;
  final double distanciaKm;
  final int reputacao;

  Oferta({
    required this.usuario,
    required this.mercado,
    required this.descricao,
    required this.imagemUrl,
    required this.distanciaKm,
    required this.reputacao,
  });
}

class FeedOfertasPage extends StatelessWidget {
  final List<Oferta> ofertas = List.generate(
    5,
    (index) => Oferta(
      usuario: 'user$index',
      mercado: 'Mercado Bom Preço',
      descricao: 'Arroz 5kg por R\$${15 + index},99!',
      imagemUrl: 'https://picsum.photos/seed/oferta$index/400/200',
      distanciaKm: (index + 1) * 1.2,
      reputacao: 50 + index * 10,
    ),
  );

  FeedOfertasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ofertas Perto de Você"),
        backgroundColor: Colors.orange[700],
      ),
      body: ListView.builder(
        itemCount: ofertas.length,
        itemBuilder: (context, index) {
          return CardOferta(oferta: ofertas[index]);
        },
      ),
    );
  }
}

class CardOferta extends StatelessWidget {
  final Oferta oferta;

  const CardOferta({super.key, required this.oferta});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 10),
                Text(
                  oferta.usuario,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text('${oferta.reputacao} pts'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Imagem da oferta
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(oferta.imagemUrl),
            ),
            const SizedBox(height: 10),

            // Detalhes da oferta
            Text(
              oferta.mercado,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(oferta.descricao),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.grey),
                Text('${oferta.distanciaKm.toStringAsFixed(1)} km de você'),
              ],
            ),
            const SizedBox(height: 12),

            // Botões interativos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Validação da oferta (ganha pontos)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Oferta validada! +5 pontos"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Vi essa oferta"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Marca como expirada
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Oferta marcada como expirada."),
                      ),
                    );
                  },
                  icon: const Icon(Icons.report_gmailerrorred),
                  label: const Text("Oferta encerrada"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
