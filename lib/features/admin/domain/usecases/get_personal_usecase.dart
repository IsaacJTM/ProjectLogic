import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/domain/repositories/admin_repository.dart';

class GetPersonalUsecase {
  final AdminRepository repositry;
  GetPersonalUsecase(this.repositry);

  Future<List<PersonaModel>> call() async{
    return await repositry.obtenerPersonal();
  }
}