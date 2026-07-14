import '../../domain/entities/checklist_task_entity.dart';

class ChecklistTaskModel extends ChecklistTaskEntity {
  const ChecklistTaskModel({
    required super.id,
    required super.name,
    super.done,
    super.completedAt,
    super.note,
  });

  factory ChecklistTaskModel.fromJson(Map<String, dynamic> json) {
    return ChecklistTaskModel(
      id: json['id'] as String,
      name: json['name'] as String,
      done: json['done'] as bool? ?? false,
      completedAt: json['completedAt'] as String?,
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'done': done,
        'completedAt': completedAt,
        'note': note,
      };
}
