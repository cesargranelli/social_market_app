import 'dart:math' as math;

/// Cálculo de distância geográfica e formatação em PT-BR. Funções puras.
///
/// Raio terrestre médio de 6371 km; precisão suficiente para exibir
/// distâncias aproximadas até mercados.
const double _earthRadiusKm = 6371.0;

/// Distância haversine entre dois pontos geográficos, em quilômetros.
double haversineDistanceKm({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  final double phi1 = _degreesToRadians(lat1);
  final double phi2 = _degreesToRadians(lat2);
  final double deltaPhi = _degreesToRadians(lat2 - lat1);
  final double deltaLambda = _degreesToRadians(lon2 - lon1);

  final double sinHalfDeltaPhi = math.sin(deltaPhi / 2);
  final double sinHalfDeltaLambda = math.sin(deltaLambda / 2);

  final double a =
      sinHalfDeltaPhi * sinHalfDeltaPhi +
      math.cos(phi1) *
          math.cos(phi2) *
          sinHalfDeltaLambda *
          sinHalfDeltaLambda;
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return _earthRadiusKm * c;
}

/// Formata uma distância em km para leitura humana em PT-BR:
/// '< 100 m' | 'X m' (arredondado, para < 1 km) | 'X,X km' (1 casa decimal).
String formatDistanceKm(double km) {
  if (km < 0.1) return '< 100 m';
  if (km < 1) return '${(km * 1000).round()} m';

  final String oneDecimal =
      ((km * 10).round() / 10).toStringAsFixed(1).replaceAll('.', ',');
  return '$oneDecimal km';
}

double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;
