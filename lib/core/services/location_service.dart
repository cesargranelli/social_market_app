import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Abstração de posição atual, injetável nos widget tests.
abstract class LocationService {
  Future<Position?> getCurrentPosition();
}

/// Implementação com geolocator. NUNCA lança: qualquer falha
/// (serviço desligado, permissão negada, plugin indisponível) resulta em
/// null e a UI trata a ausência de localização como estado normal.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => const GeolocatorLocationService(),
);

/// Posição do usuário capturada UMA VEZ por tela (autoDispose): falha
/// silenciosa vira AsyncData(null), nunca estado de erro.
final currentPositionProvider = FutureProvider.autoDispose<Position?>((
  ref,
) {
  return ref.watch(locationServiceProvider).getCurrentPosition();
});
