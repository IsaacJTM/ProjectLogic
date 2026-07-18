import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/checklist_task_entity.dart';
import '../../domain/entities/coordinate_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_phase.dart';
import '../../domain/repositories/logistics_repository.dart';
import '../datasources/media_upload_api.dart';
import '../datasources/order_remote_api.dart';
import '../datasources/route_gps_api.dart';

class LogisticsRepositoryImpl implements LogisticsRepository {
  final OrderRemoteApi orderRemoteApi;
  final RouteGpsApi routeGpsApi;
  final MediaUploadApi mediaUploadApi;

  LogisticsRepositoryImpl({
    required this.orderRemoteApi,
    required this.routeGpsApi,
    required this.mediaUploadApi,
  });

  @override
  Future<List<OrderEntity>> getActiveOrders(String technicianId) {
    return orderRemoteApi.fetchActiveOrders(technicianId);
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    try {
      final targetNum = int.tryParse(orderId) ?? orderId;
      final query = await FirebaseFirestore.instance
          .collection('ordenes_trabajo')
          .where('nroOrden', isEqualTo: targetNum)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No se encontró la orden con nroOrden: $orderId');
      }

      final userId = query.docs.first.data()['idUsuario'] ?? '';
      final orders = await orderRemoteApi.fetchActiveOrders(userId);
      return orders.firstWhere(
        (o) => o.id == orderId,
        orElse: () =>
            throw Exception('No se encontró la orden con ID: $orderId'),
      );
    } catch (e) {
      throw Exception('Error al obtener la orden por ID: $e');
    }
  }

  @override
  Future<OrderEntity> changeOrderPhase({
    required String orderId,
    required OrderPhase targetPhase,
    String? note,
  }) async {
    return await orderRemoteApi.changePhase(
      orderId: orderId,
      targetPhase: targetPhase,
      note: note,
    );
  }

  @override
  Future<List<ChecklistTaskEntity>> getChecklistTasks(String orderId) async {
    try {
      final targetNum = int.tryParse(orderId) ?? orderId;
      final orderQuery = await FirebaseFirestore.instance
          .collection('ordenes_trabajo')
          .where('nroOrden', isEqualTo: targetNum)
          .get();

      if (orderQuery.docs.isEmpty) {
        return [];
      }

      final dataOrden = orderQuery.docs.first.data();
      final int idOrdenInterno = dataOrden['idOrden'] as int? ?? 0;
      return await orderRemoteApi.fetchTasksForOrder(idOrdenInterno);
    } catch (e) {
      throw Exception('Error en repositorio al cargar tareas: $e');
    }
  }

  @override
  Future<void> submitChecklist(
    String orderId,
    List<ChecklistTaskEntity> tasks,
  ) async {
    // Aquí
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

  @override
  Future<void> updateTaskStatus(
    String taskId,
    bool isCompleted, [
    String? elapsedMinutes,
  ]) async {
    try {
      await orderRemoteApi.updateTaskStatus(
        taskId,
        isCompleted,
        elapsedMinutes,
      );
    } catch (e) {
      throw Exception('Error al actualizar tarea en el repositorio: $e');
    }
  }
}
