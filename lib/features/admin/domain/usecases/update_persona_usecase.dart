import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/domain/repositories/admin_repository.dart';

class UpdatePersonaUsecase {
  final AdminRepository repository;
  UpdatePersonaUsecase(this.repository);
  Future<void> call(PersonaModel person) async{
    return await repository.updatePerson(person);
  }
}