import '../../domain/entities/checklist_task_entity.dart';
import '../../domain/entities/coordinate_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_phase.dart';
import '../../domain/repositories/logistics_repository.dart';
import '../datasources/media_upload_api.dart';
import '../datasources/order_remote_api.dart';
import '../datasources/route_gps_api.dart';
import '../models/checklist_task_model.dart';

class LogisticsRepositoryImpl implements LogisticsRepository {
  final OrderRemoteApi orderRemoteApi;
  final RouteGpsApi routeGpsApi;
  final MediaUploadApi mediaUploadApi;

  LogisticsRepositoryImpl({
    required this.orderRemoteApi,
    required this.routeGpsApi,
    required this.mediaUploadApi,
  });

  static const _mockChecklist = [
    ChecklistTaskModel(id: 't1', name: 'Revisión de fugas de gas'),
    ChecklistTaskModel(id: 't2', name: 'Limpieza de condensador'),
    ChecklistTaskModel(id: 't3', name: 'Carga de Gas R410A'),
    ChecklistTaskModel(id: 't4', name: 'Pruebas de presión térmica'),
  ];

  @override
  Future<List<OrderEntity>> getActiveOrders(String technicianId) {
    return orderRemoteApi.fetchActiveOrders(technicianId);
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    final orders = await orderRemoteApi.fetchActiveOrders('tech-001');
    return orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => orders.first,
    );
  }

  @override
  Future<OrderEntity> changeOrderPhase({
    required String orderId,
    required OrderPhase targetPhase,
    String? note,
  }) {
    return orderRemoteApi.changePhase(
      orderId: orderId,
      targetPhase: targetPhase,
      note: note,
    );
  }

  @override
  Future<List<ChecklistTaskEntity>> getChecklistTasks(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockChecklist;
  }

  @override
  Future<void> submitChecklist(
    String orderId,
    List<ChecklistTaskEntity> tasks,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Stream<CoordinateEntity> watchTechnicianRoute(String orderId) {
    return routeGpsApi.watchPosition(orderId);
  }

  @override
  Future<String> uploadEvidence(
    String orderId,
    String phaseTag,
    List<int> bytes,
  ) {
    return mediaUploadApi.upload(orderId: orderId, tag: phaseTag, bytes: bytes);
  }
}
