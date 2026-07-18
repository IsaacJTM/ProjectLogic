import 'package:logistics_pro/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:logistics_pro/features/admin/data/datasources/ordenes_remote_datasource.dart';
import 'package:logistics_pro/features/admin/data/models/orden_trabajo_model.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/domain/entities/orden_trabajo_entity.dart';
import 'package:logistics_pro/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository{
  final AdminRemoteDatasource remoteDatasource;
  final OrdenesRemoteDatasource ordenDatasource;

  AdminRepositoryImpl(this.remoteDatasource, this.ordenDatasource);

  @override
  Future<List<PersonaModel>> obtenerPersonal() async{
    return await remoteDatasource.obtenerPersonal();
  }
  
  @override
  Future<void> crearPersonal(PersonaModel persona) async{
    // TODO: implement crearPersonal
     return await remoteDatasource.createPerson(persona);
  }

  @override
  Future<void> crearOrden(OrdenTrabajoEntity orden) {
    //Mapeo de la entidad al modelo (compatible con firestore)
    final model = OrdenTrabajoModel(
      idOrden: orden.idOrden, 
      idCliente: orden.idCliente, 
      idUsuario: orden.idUsuario, 
      nroOrden: orden.nroOrden, 
      fechaCreacion: orden.fechaCreacion, 
      fechaAsignacionOrden: orden.fechaAsignacionOrden, 
      titulo: orden.titulo, 
      tiempoEjecucion: orden.tiempoEjecucion,
      nombreLugar: orden.nombreLugar, 
      latitud: orden.latitud,
      longitud: orden.longitud, 
      actividades: orden.actividades
    );

    return ordenDatasource.guardarOrdenConChekList(model); 
  }
}