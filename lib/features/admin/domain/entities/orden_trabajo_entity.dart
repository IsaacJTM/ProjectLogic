import 'package:logistics_pro/features/admin/domain/entities/tarea_checklist_entity.dart';

class OrdenTrabajoEntity {
  final int idOrden;
  final int idCliente;
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
  final String latitud;
  final String longitud;
  final List<TareaChecklistEntity> actividades;

  OrdenTrabajoEntity({
    required this.idOrden,
    required this.idCliente,
    required this.idUsuario,
    required this.nroOrden,
    this.estadoFase = 0,
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