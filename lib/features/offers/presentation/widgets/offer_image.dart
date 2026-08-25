import 'package:flutter/material.dart';

/// Imagem da oferta em proporção 16:9. Sem foto (ou com falha de rede)
/// exibe um placeholder neutro com ícone — nunca quebra o layout do card.
class OfferImage extends StatelessWidget {
  const OfferImage({super.key, this.imageUrl, this.semanticLabel});

  final String? imageUrl;

  /// Rótulo de acessibilidade quando há foto carregada.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? url = imageUrl;

    if (url == null || url.isEmpty) {
      return _buildPlaceholder(theme);
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        semanticLabel: semanticLabel ?? 'Foto do produto',
        errorBuilder: (_, _, _) => _buildPlaceholder(theme),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Icon(
            Icons.local_offer,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
            semanticLabel: 'Oferta sem foto',
          ),
        ),
      ),
    );
  }
}
