import 'order_phase.dart';

class OrderEntity {
  final String id;
  final String title;
  final String clientName;
  final String address;
  final String assignedTechnicianId;
  final OrderPhase phase;
  final DateTime createdAt;
  final Map<OrderPhase, String> phaseNotes;

  const OrderEntity({
    required this.id,
    required this.title,
    required this.clientName,
    required this.address,
    required this.assignedTechnicianId,
    required this.phase,
    required this.createdAt,
    this.phaseNotes = const {},
  });

  OrderEntity copyWith({
    OrderPhase? phase,
    Map<OrderPhase, String>? phaseNotes,
  }) {
    return OrderEntity(
      id: id,
      title: title,
      clientName: clientName,
      address: address,
      assignedTechnicianId: assignedTechnicianId,
      phase: phase ?? this.phase,
      createdAt: createdAt,
      phaseNotes: phaseNotes ?? this.phaseNotes,
    );
  }
}
