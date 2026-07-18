import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics_pro/features/admin/domain/entities/orden_trabajo_entity.dart';

class OrdenTrabajoModel extends OrdenTrabajoEntity{
  OrdenTrabajoModel({
    required super.idOrden, 
    required super.idCliente, 
    required super.idUsuario, 
    required super.nroOrden, 
    required super.fechaCreacion, 
    required super.fechaAsignacionOrden, 
    super.fechafinalizacionOrden,
    required super.titulo,
    super.tiempoEjecucion, 
    required super.nombreLugar,
    required super.latitud, 
    required super.longitud, 
    required super.actividades
  });

  Map<String, dynamic> toMap(){
    return {
      'idOrden': idOrden,
      'idCliente': idCliente,
      'idUsuario': idUsuario,
      'nroOrden': nroOrden,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaAsignacionOrden': Timestamp.fromDate(fechaAsignacionOrden),
      'fechafinalizacionOrden': fechafinalizacionOrden != null ? Timestamp.fromDate(fechafinalizacionOrden!) : null,
      'titulo': titulo,
      'tiempoEjecucion': tiempoEjecucion,
      'lugar': {
        'nombreLugar': nombreLugar,
        'latitud': latitud,
        'longitud': longitud
      }
    };
  }
}