import 'package:logistics_pro/features/admin/domain/entities/orden_trabajo_entity.dart';
import 'package:logistics_pro/features/admin/domain/repositories/admin_repository.dart';

class CreateOrdenUsecase {
  final AdminRepository repository;
  CreateOrdenUsecase(this.repository);

  Future<void> call(OrdenTrabajoEntity orden){
    return repository.crearOrden(orden);
  }
}