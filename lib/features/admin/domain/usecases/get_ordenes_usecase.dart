import 'package:logistics_pro/features/admin/domain/entities/orden_trabajo_entity.dart';
import 'package:logistics_pro/features/admin/domain/repositories/admin_repository.dart';

class GetOrdenesUsecase {
  final AdminRepository repository;
  GetOrdenesUsecase(this.repository);

  Stream<List<OrdenTrabajoEntity>> call(){
    return repository.getOrdenTrabajo();
  }
}