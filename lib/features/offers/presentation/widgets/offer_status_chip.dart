import 'package:flutter/material.dart';

/// Chip cinza indicando que a oferta está expirada.
///
/// Apenas informativo: a oferta continua clicável/navegável no feed.
class OfferStatusChip extends StatelessWidget {
  const OfferStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
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
