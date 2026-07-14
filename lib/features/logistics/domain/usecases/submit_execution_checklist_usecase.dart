import '../entities/checklist_task_entity.dart';
import '../repositories/logistics_repository.dart';

class SubmitExecutionChecklistUseCase {
  final LogisticsRepository repository;

  SubmitExecutionChecklistUseCase(this.repository);

  Future<void> call(String orderId, List<ChecklistTaskEntity> tasks) {
    final allDone = tasks.every((t) => t.done);
    if (!allDone) {
      throw StateError(
        'Todas las tareas deben completarse antes de enviar el checklist',
      );
    }
    return repository.submitChecklist(orderId, tasks);
  }
}
