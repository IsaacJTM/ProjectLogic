class ChecklistTaskEntity {
  final String id;
  final String name;
  final bool done;
  final String? completedAt;
  final String note;

  const ChecklistTaskEntity({
    required this.id,
    required this.name,
    this.done = false,
    this.completedAt,
    this.note = '',
  });

  ChecklistTaskEntity copyWith({
    bool? done,
    String? completedAt,
    String? note,
  }) {
    return ChecklistTaskEntity(
      id: id,
      name: name,
      done: done ?? this.done,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
    );
  }
}
