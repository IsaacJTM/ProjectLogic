import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/domain/repositories/admin_repository.dart';

class CreatePersonaUsecase {
  final AdminRepository repository;
  //controlador
  CreatePersonaUsecase(this.repository);

  //Método
  Future<void> call(PersonaModel persona) async{
    if(persona.contrasena != null && persona.contrasena!.length < 6){
      throw Exception('La contraseña del empleado debe tener al menos 6 caracteres');
    }
    return await repository.crearPersonal(persona);
  } 
}