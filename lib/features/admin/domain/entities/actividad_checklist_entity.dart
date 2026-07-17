class ActividadChecklistEntity {
  final String idTarea;
  final String idOrden;
  final DateTime? fechaCreacion;
  final String? horaCompletado;
  final String descripcion;
  final String? notaTarea;
  final bool estadoCompletado;

  ActividadChecklistEntity({
    required this.idTarea,
    required this.idOrden,
    this.fechaCreacion,
    this.horaCompletado,
    required this.descripcion,
    this.notaTarea,
    this.estadoCompletado = false,
  });

}