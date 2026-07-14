import '../../domain/entities/coordinate_entity.dart';

/// Servicio de mapas/ubicación (Fase 2: En Ruta).
/// Reemplazar por geolocator / google_maps_flutter en producción.
class RouteGpsApi {
  Stream<CoordinateEntity> watchPosition(String orderId) async* {
    double lat = -12.0464;
    double lng = -77.0428;

    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      lat += 0.0005;
      lng += 0.0003;
      yield CoordinateEntity(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
      );
    }
  }
}
