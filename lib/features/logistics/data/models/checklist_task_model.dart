import '../../domain/entities/checklist_task_entity.dart';

class ChecklistTaskModel extends ChecklistTaskEntity {
  final int idOrden;
  final int idTarea;
  final String notaTarea;

  ChecklistTaskModel({
    required super.id,
    required super.name,
    required super.done,
    required this.idOrden,
    required this.idTarea,
    required this.notaTarea,
  });

  factory ChecklistTaskModel.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return ChecklistTaskModel(
      id: docId,
      name: data['descripcion'] ?? '',
      done: data['estadoCompletada'] as bool? ?? false,
      idOrden: data['idOrden'] as int? ?? 0,
      idTarea: data['idTarea'] as int? ?? 0,
      notaTarea: data['notaTarea'] ?? '',
    );
  }

  @override
  ChecklistTaskModel copyWith({
    String? id,
    String? name,
    bool? done,
    int? idOrden,
    int? idTarea,
    String? notaTarea,

    String? completedAt,
    String? note,
  }) {
    return ChecklistTaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      done: done ?? this.done,
      idOrden: idOrden ?? this.idOrden,
      idTarea: idTarea ?? this.idTarea,
      notaTarea: notaTarea ?? note ?? this.notaTarea,
    );
  }
}
