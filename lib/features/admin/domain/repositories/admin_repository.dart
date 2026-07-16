import 'package:logistics_pro/features/admin/data/models/persona_model.dart';

abstract class AdminRepository {
  Future<void> crearPersonal(PersonaModel persona);
  Future<List<PersonaModel>> obtenerPersonal();
}