import '../entities/coordinate_entity.dart';
import '../repositories/logistics_repository.dart';

class TrackTechnicianRouteUseCase {
  final LogisticsRepository repository;

  TrackTechnicianRouteUseCase(this.repository);

  Stream<CoordinateEntity> call(String orderId) {
    return repository.watchTechnicianRoute(orderId);
  }
}
