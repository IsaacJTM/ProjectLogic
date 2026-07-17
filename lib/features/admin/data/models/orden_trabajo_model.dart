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
    required super.nombreLugar,
    required super.latitud, 
    required super.longitud, 
    required super.actividades
  });

}