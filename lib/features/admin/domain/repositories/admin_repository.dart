import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/domain/entities/orden_trabajo_entity.dart';

abstract class AdminRepository {
  Future<void> crearPersonal(PersonaModel persona);
  Future<List<PersonaModel>> obtenerPersonal();
  Future<void> crearOrden(OrdenTrabajoEntity orden);
}