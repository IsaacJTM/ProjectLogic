import 'dart:math';

import '../../domain/entities/order_phase.dart';
import '../models/order_model.dart';

class OrderRemoteApi {
  Future<List<OrderModel>> fetchActiveOrders(String technicianId) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return [
      OrderModel(
        id: '8492',
        title: 'Mantenimiento de aire acondicionado',
        clientName: 'Jossias Villa Bastidas',
        address: 'Av. Los Álamos 245, San Isidro',
        assignedTechnicianId: technicianId,
        phase: OrderPhase.assigned,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<OrderModel> changePhase({
    required String orderId,
    required OrderPhase targetPhase,
    String? note,
  }) async {
    // 🌐 Simulación de consumo de API REST
    await Future.delayed(const Duration(milliseconds: 1800));

    if (Random().nextDouble() < 0.02) {
      throw Exception('Error de red al sincronizar la fase');
    }

    return OrderModel(
      id: orderId,
      title: 'Mantenimiento de aire acondicionado',
      clientName: 'Jossias Villa Bastidas',
      address: 'Av. Los Álamos 245, San Isidro',
      assignedTechnicianId: 'tech-001',
      phase: targetPhase,
      createdAt: DateTime.now(),
    );
  }
}
