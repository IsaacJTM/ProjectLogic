import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics_pro/features/logistics/data/models/checklist_task_model.dart';
import '../../domain/entities/order_phase.dart';
import '../models/order_model.dart';

class OrderRemoteApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<OrderModel>> fetchActiveOrders(String technicianId) async {
    try {
      final querySnapshot = await _firestore
          .collection('ordenes_trabajo')
          .where('idUsuario', isEqualTo: technicianId)
          .where('estadoFase', isNotEqualTo: 4)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final int faseNum = data['estadoFase'] as int? ?? 0;

        OrderPhase currentPhase;
        switch (faseNum) {
          case 0:
            currentPhase = OrderPhase.assigned;
            break;
          case 1:
            currentPhase = OrderPhase.enRoute;
            break;
          case 2:
            currentPhase = OrderPhase.onSite;
            break;
          case 3:
            currentPhase = OrderPhase.execution;
            break;
          case 4:
            currentPhase = OrderPhase.completed;
            break;
          default:
            currentPhase = OrderPhase.assigned;
        }

        return OrderModel(
          id: data['nroOrden']?.toString() ?? doc.id,
          title: data['notasGenerales'] ?? 'Sin descripción',
          clientName: 'Cliente ID: ${data['idCliente'] ?? "Desconocido"}',
          address: 'Dirección pendiente de cliente',
          assignedTechnicianId: data['idUsuario'] ?? technicianId,
          phase: currentPhase,
          createdAt: data['fechaCreacion'] != null
              ? (data['fechaCreacion'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener las órdenes de Firestore: $e');
    }
  }

  Future<OrderModel> changePhase({
    required String orderId,
    required OrderPhase targetPhase,
    String? note,
  }) async {
    try {
      int faseNum;
      switch (targetPhase) {
        case OrderPhase.assigned:
          faseNum = 0;
          break;
        case OrderPhase.enRoute:
          faseNum = 1;
          break;
        case OrderPhase.onSite:
          faseNum = 2;
          break;
        case OrderPhase.execution:
          faseNum = 3;
          break;
        case OrderPhase.completed:
          faseNum = 4;
          break;
      }

      final targetNum = int.tryParse(orderId) ?? orderId;
      final querySnapshot = await _firestore
          .collection('ordenes_trabajo')
          .where('nroOrden', isEqualTo: targetNum)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception(
          'No se encontró ningún documento con nroOrden: $orderId',
        );
      }

      final docRef = querySnapshot.docs.first.reference;

      await docRef.update({
        'estadoFase': faseNum,
        if (note != null) 'notasGenerales': note,
      });

      final updatedDoc = await docRef.get();
      final data = updatedDoc.data()!;

      return OrderModel(
        id: orderId,
        title: data['notasGenerales'] ?? 'Sin descripción',
        clientName: 'Cliente ID: ${data['idCliente'] ?? "Desconocido"}',
        address: 'Dirección pendiente',
        assignedTechnicianId: data['idUsuario'] ?? '',
        phase: targetPhase,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error al cambiar de fase en Firestore: $e');
    }
  }

  Future<List<ChecklistTaskModel>> fetchTasksForOrder(
    int idOrdenInterno,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('tareas_checklist')
          .where('idOrden', isEqualTo: idOrdenInterno)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final listaTareas = querySnapshot.docs.map((doc) {
        return ChecklistTaskModel.fromFirestore(doc.id, doc.data());
      }).toList();

      return listaTareas;
    } catch (e) {
      throw Exception('Error al obtener el checklist de Firestore: $e');
    }
  }

  Future<void> updateTaskStatus(String taskDocumentId, bool isCompleted) async {
    try {
      await _firestore
          .collection('tareas_checklist')
          .doc(taskDocumentId)
          .update({
            'estadoCompletada': isCompleted,
            'horaCompletado': isCompleted ? "09:35" : null,
          });
    } catch (e) {
      throw Exception('No se pudo actualizar la tarea: $e');
    }
  }
}
