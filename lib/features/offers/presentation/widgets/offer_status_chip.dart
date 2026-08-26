import 'package:flutter/material.dart';

import '../../domain/offer_model.dart';

/// Chip de status da oferta, usado no header do detalhe e nos cards do feed.
///
/// - [OfferStatus.expired]: chip cinza 'Expirada' (apenas informativo; a
///   oferta continua clicável/navegável).
/// - [OfferStatus.verified]: chip verde 'Verificada pela comunidade'.
class OfferStatusChip extends StatelessWidget {
  const OfferStatusChip({super.key, required this.status});

  final OfferStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OfferStatus.verified) {
      return Chip(
        key: const Key('offer_verified_chip'),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: Colors.green.shade50,
        side: BorderSide.none,
        avatar: Icon(
          Icons.verified,
          size: 16,
          color: Colors.green.shade700,
          semanticLabel: 'Oferta verificada pela comunidade',
        ),
        label: Text(
          'Verificada pela comunidade',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.green.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // expired (active não deve chegar aqui — os call sites filtram).
    return Chip(
      key: const Key('offer_expired_chip'),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: Colors.grey.shade200,
      side: BorderSide.none,
      avatar: Icon(
        Icons.hourglass_bottom,
        size: 16,
        color: Colors.grey.shade700,
        semanticLabel: 'Oferta expirada',
      ),
      label: Text(
        'Expirada',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
