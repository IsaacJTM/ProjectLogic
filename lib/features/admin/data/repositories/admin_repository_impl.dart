import 'package:logistics_pro/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository{
  final AdminRemoteDatasource remoteDatasource;

  AdminRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<PersonaModel>> obtenerPersonal() async{
    return await remoteDatasource.obtenerPersonal();
  }
  
  @override
  Future<void> crearPersonal(PersonaModel persona) async{
    // TODO: implement crearPersonal
     return await remoteDatasource.createPerson(persona);
  }
}