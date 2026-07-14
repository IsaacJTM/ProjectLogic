import '../entities/order_entity.dart';
import '../entities/order_phase.dart';
import '../repositories/logistics_repository.dart';

class AdvanceOrderPhaseUseCase {
  final LogisticsRepository repository;

  AdvanceOrderPhaseUseCase(this.repository);

  Future<OrderEntity> call({
    required OrderEntity currentOrder,
    required bool revert,
    String? note,
  }) async {
    final target = revert
        ? currentOrder.phase.previous
        : currentOrder.phase.next;

    if (target == null) {
      throw StateError(
        revert
            ? 'No se puede retroceder desde la primera fase'
            : 'La orden ya está en la última fase',
      );
    }

    return repository.changeOrderPhase(
      orderId: currentOrder.id,
      targetPhase: target,
      note: note,
    );
  }
}
