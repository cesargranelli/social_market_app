import 'package:flutter_test/flutter_test.dart';
import 'package:social_market_app/core/utils/geo_distance.dart';

void main() {
  group('haversineDistanceKm', () {
    test('São Paulo -> Guarulhos (~14,75 km) com valores fixos', () {
      // Praça da Sé (-23.5505, -46.6333) -> centro de Guarulhos
      // (-23.4543, -46.5337).
      final double distance = haversineDistanceKm(
        lat1: -23.5505,
        lon1: -46.6333,
        lat2: -23.4543,
        lon2: -46.5337,
      );

      expect(distance, closeTo(14.75, 0.05));
    });

    test('mesmo ponto tem distância zero', () {
      final double distance = haversineDistanceKm(
        lat1: -23.5505,
        lon1: -46.6333,
        lat2: -23.5505,
        lon2: -46.6333,
      );

      expect(distance, 0);
    });

    test('é simétrica', () {
      final double ab = haversineDistanceKm(
        lat1: -22.9068,
        lon1: -43.1729, // Rio de Janeiro
        lat2: -23.5505,
        lon2: -46.6333, // São Paulo
      );
      final double ba = haversineDistanceKm(
        lat1: -23.5505,
        lon1: -46.6333,
        lat2: -22.9068,
        lon2: -43.1729,
      );

      expect(ab, closeTo(ba, 1e-9));
    });
  });

  group('formatDistanceKm', () {
    test('menor que 100 m', () {
      expect(formatDistanceKm(0.05), '< 100 m');
      expect(formatDistanceKm(0), '< 100 m');
    });

    test('metros arredondados abaixo de 1 km', () {
      expect(formatDistanceKm(0.35), '350 m');
      expect(formatDistanceKm(0.9994), '999 m');
    });

    test('quilômetros com vírgula PT-BR e 1 casa', () {
      expect(formatDistanceKm(1.234), '1,2 km');
      expect(formatDistanceKm(14.7497), '14,7 km');
    });
  });
}
