import 'package:flutter/material.dart';

/// Conquista (badge) conquistada pelo usuário via gamificação.
class Badge {
  const Badge({
    required this.id,
    required this.label,
    required this.icon,
  });

  /// Identificador estável do badge (ex.: `first_offer`).
  final String id;

  /// Rótulo de exibição em PT-BR.
  final String label;

  /// Ícone representativo para a UI.
  final IconData icon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Badge && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Badge(id: $id, label: $label)';
}

const _firstOffer = Badge(
  id: 'first_offer',
  label: 'Primeira oferta publicada',
  icon: Icons.local_offer,
);

const _prolific = Badge(
  id: 'prolific',
  label: '10+ ofertas',
  icon: Icons.emoji_events,
);

const _trusted = Badge(
  id: 'trusted',
  label: 'Oferta verificada',
  icon: Icons.verified,
);

const _commenter = Badge(
  id: 'commenter',
  label: 'Comentarista ativo',
  icon: Icons.forum,
);

/// Computa os badges conquistados a partir dos contadores agregados do
/// usuário. A ordem é fixa e não há duplicatas.
List<Badge> computeBadges({
  required int offersCount,
  required int verifiedCount,
  required int commentsCount,
}) {
  return <Badge>[
    if (offersCount >= 1) _firstOffer,
    if (offersCount >= 10) _prolific,
    if (verifiedCount >= 1) _trusted,
    if (commentsCount >= 5) _commenter,
  ];
}
