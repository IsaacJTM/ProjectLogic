import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_phase.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.title,
    required super.clientName,
    required super.address,
    required super.assignedTechnicianId,
    required super.phase,
    required super.createdAt,
    super.phaseNotes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      clientName: json['clientName'] as String,
      address: json['address'] as String,
      assignedTechnicianId: json['assignedTechnicianId'] as String,
      phase: OrderPhase.values[json['phaseIndex'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'clientName': clientName,
      'address': address,
      'assignedTechnicianId': assignedTechnicianId,
      'phaseIndex': phase.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
