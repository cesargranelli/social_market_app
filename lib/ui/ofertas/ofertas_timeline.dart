// DeepSeek
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

// ======== MODELO DE OFERTA ========
class Oferta {
  final String id;
  final String titulo;
  final String descricao;
  final String imagem;
  final String loja;
  final double precoOriginal;
  final double precoPromo;
  final int descontosRestantes;
  final String categoria;
  final double distanciaKm;
  final bool isFavorita;

  Oferta({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.imagem,
    required this.loja,
    required this.precoOriginal,
    required this.precoPromo,
    required this.descontosRestantes,
    required this.categoria,
    required this.distanciaKm,
    this.isFavorita = false,
  });
}

// ======== TELA PRINCIPAL ========
class OfertasTimeline extends StatefulWidget {
  @override
  _OfertasTimelineState createState() => _OfertasTimelineState();
}

class _OfertasTimelineState extends State<OfertasTimeline> {
  final ConfettiController _confettiController = ConfettiController();
  List<Oferta> _ofertas = [];
  List<Oferta> _ofertasFiltradas = [];
  Set<String> _ofertasColetadas = {};
  String _filtroAtual = "Todas";

  @override
  void initState() {
    super.initState();
    _carregarOfertas();
    _ofertasFiltradas = _ofertas;
  }

  void _carregarOfertas() {
    _ofertas = [
      Oferta(
        id: "1",
        titulo: "Smartphone 50% OFF",
        descricao: "Promoção relâmpago! Apenas hoje.",
        imagem: "https://picsum.photos/500/300?random=1",
        loja: "TechStore",
        precoOriginal: 1999.90,
        precoPromo: 999.90,
        descontosRestantes: 12,
        categoria: "Eletrônicos",
        distanciaKm: 2.5,
      ),
      Oferta(
        id: "2",
        titulo: "Almoço Executivo",
        descricao: "Prato feito + suco por R\$ 15,90",
        imagem: "https://picsum.photos/500/300?random=2",
        loja: "Restaurante Sabor & Cia",
        precoOriginal: 25.90,
        precoPromo: 15.90,
        descontosRestantes: 8,
        categoria: "Alimentação",
        distanciaKm: 1.2,
      ),
      Oferta(
        id: "3",
        titulo: "Yoga Mat 60% OFF",
        descricao: "Imperdível para fitness!",
        imagem: "https://picsum.photos/500/300?random=3",
        loja: "SportLife",
        precoOriginal: 120.00,
        precoPromo: 48.00,
        descontosRestantes: 5,
        categoria: "Esportes",
        distanciaKm: 3.8,
      ),
    ];
  }

  void _filtrarOfertas(String categoria) {
    setState(() {
      _filtroAtual = categoria;
      _ofertasFiltradas =
          categoria == "Todas"
              ? _ofertas
              : _ofertas
                  .where((oferta) => oferta.categoria == categoria)
                  .toList();
    });
  }

  void _coletarOferta(String id) {
    setState(() {
      _ofertasColetadas.add(id);
      // _confettiController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ofertas perto de você 🔥"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(bottom: 80),
            itemCount: _ofertasFiltradas.length,
            itemBuilder: (context, index) {
              return OfertaCard(
                oferta: _ofertasFiltradas[index],
                onCollect: _coletarOferta,
                isCollected: _ofertasColetadas.contains(
                  _ofertasFiltradas[index].id,
                ),
              );
            },
          ),
          // Barra de progresso (gamificação)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    "Colete ofertas e ganhe recompensas!",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  FAProgressBar(
                    // currentValue:
                    //     (_ofertasColetadas.length / _ofertas.length * 100)
                    //         .toInt(),
                    maxValue: 100,
                    progressColor: Colors.deepOrange,
                    backgroundColor: Colors.grey.shade200,
                    displayText: '%',
                  ),
                ],
              ),
            ),
          ),
          // Confetti ao coletar oferta
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: ConfettiWidget(
          //     confettiController: _confettiController,
          //     blastDirectionality: BlastDirectionality.explosive,
          //     shouldLoop: false,
          //     colors: [Colors.red, Colors.orange, Colors.yellow],
          //   ),
          // ),
        ],
      ),
    );
  }

  void _mostrarFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Filtrar por categoria",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip("Todas"),
                  _buildFilterChip("Eletrônicos"),
                  _buildFilterChip("Alimentação"),
                  _buildFilterChip("Esportes"),
                  _buildFilterChip("Moda"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String categoria) {
    return FilterChip(
      label: Text(categoria),
      selected: _filtroAtual == categoria,
      onSelected: (selected) {
        _filtrarOfertas(categoria);
        Navigator.pop(context);
      },
    );
  }
}

// ======== CARD DE OFERTA (INOVADOR) ========
class OfertaCard extends StatefulWidget {
  final Oferta oferta;
  final Function(String) onCollect;
  final bool isCollected;

  const OfertaCard({
    required this.oferta,
    required this.onCollect,
    required this.isCollected,
  });

  @override
  _OfertaCardState createState() => _OfertaCardState();
}

class _OfertaCardState extends State<OfertaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => setState(() {
            _isExpanded = !_isExpanded;
            _isExpanded
                ? _animationController.forward()
                : _animationController.reverse();
          }),
      child: Card(
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          children: [
            // Imagem da oferta (com zoom ao tocar)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Image.network(
                    widget.oferta.imagem,
                    width: double.infinity,
                    height: _isExpanded ? 250 : 180,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "-${((widget.oferta.precoOriginal - widget.oferta.precoPromo) / widget.oferta.precoOriginal * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Detalhes da oferta
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.oferta.loja,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      Text("${widget.oferta.distanciaKm} km"),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.oferta.titulo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(widget.oferta.descricao),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "R\$ ${widget.oferta.precoPromo.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "R\$ ${widget.oferta.precoOriginal.toStringAsFixed(2)}",
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "${widget.oferta.descontosRestantes} restantes",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  // Botão de coleta (gamificação)
                  if (!widget.isCollected)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.card_giftcard),
                        label: Text("Colecionar"),
                        style: ElevatedButton.styleFrom(
                          // primary: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => widget.onCollect(widget.oferta.id),
                      ),
                    ),
                  if (widget.isCollected)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Chip(
                        label: Text(
                          "Coletado!",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
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
