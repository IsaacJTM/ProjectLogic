class TareaChecklistEntity {
  final int idTarea;
  final int idOrden;
  final DateTime? fechaCreacion;
  final String? horaCompletado;
  final String descripcion;
  final String? notaTarea;
  final bool estadoCompletada;

  TareaChecklistEntity({
    required this.idTarea,
    required this.idOrden,
    this.fechaCreacion,
    this.horaCompletado,
    required this.descripcion,
    this.notaTarea,
    this.estadoCompletada = false,
  });

}