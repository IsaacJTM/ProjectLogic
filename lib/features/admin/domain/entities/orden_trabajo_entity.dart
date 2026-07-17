import 'package:logistics_pro/features/admin/domain/entities/actividad_checklist_entity.dart';

class OrdenTrabajoEntity {
  final String idOrden;
  final String idCliente;
  final String idUsuario;
  final int nroOrden;
  final int estadoFase;
  final DateTime fechaCreacion;
  final DateTime fechaAsignacionOrden;
  final DateTime? fechafinalizacionOrden;
  final String titulo;
  final String? descripcion;
  final int? tiempoEjecucion;
  final String nombreLugar;
  final double latitud;
  final double longitud;
  final List<ActividadChecklistEntity> actividades;

  OrdenTrabajoEntity({
    required this.idOrden,
    required this.idCliente,
    required this.idUsuario,
    required this.nroOrden,
    this.estadoFase = 1,
    required this.fechaCreacion,
    required this.fechaAsignacionOrden,
    this.fechafinalizacionOrden,
    required this.titulo,
    this.descripcion,
    this.tiempoEjecucion = 0,
    required this.nombreLugar,
    required this.latitud,
    required this.longitud,
    required this.actividades
  });
}