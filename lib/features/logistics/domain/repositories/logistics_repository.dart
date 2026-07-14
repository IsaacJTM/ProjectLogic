import '../entities/checklist_task_entity.dart';
import '../entities/coordinate_entity.dart';
import '../entities/order_entity.dart';
import '../entities/order_phase.dart';

abstract class LogisticsRepository {
  Future<List<OrderEntity>> getActiveOrders(String technicianId);

  Future<OrderEntity> getOrderById(String orderId);

  Future<OrderEntity> changeOrderPhase({
    required String orderId,
    required OrderPhase targetPhase,
    String? note,
  });

  Future<List<ChecklistTaskEntity>> getChecklistTasks(String orderId);

  Future<void> submitChecklist(String orderId, List<ChecklistTaskEntity> tasks);

  Stream<CoordinateEntity> watchTechnicianRoute(String orderId);

  Future<String> uploadEvidence(
    String orderId,
    String phaseTag,
    List<int> bytes,
  );
}
