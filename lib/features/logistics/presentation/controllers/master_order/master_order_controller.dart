import 'package:flutter/foundation.dart';

import '../../../data/repositories/logistics_repository_impl.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/advance_order_phase_usecase.dart';

enum MasterOrderStatus { initial, loading, loaded, error }

class MasterOrderController extends ChangeNotifier {
  final LogisticsRepositoryImpl repository;
  late final AdvanceOrderPhaseUseCase _advancePhase;

  MasterOrderController({required this.repository}) {
    _advancePhase = AdvanceOrderPhaseUseCase(repository);
  }

  MasterOrderStatus _status = MasterOrderStatus.initial;
  OrderEntity? _order;
  bool _isSyncing = false;
  String? _errorMessage;

  MasterOrderStatus get status => _status;
  OrderEntity? get order => _order;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  bool get isLoaded => _status == MasterOrderStatus.loaded && _order != null;

  Future<void> loadOrder(String userEmail) async {
    _status = MasterOrderStatus.loading;
    notifyListeners();
    try {
      final orders = await repository.getActiveOrders(userEmail);

      // 2. Validamos si hay órdenes en la fase 0 para este trabajador
      if (orders.isEmpty) {
        throw Exception(
          'No tienes órdenes nuevas por aceptar en este momento.',
        );
      }

      _order = orders.first;

      _status = MasterOrderStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = MasterOrderStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> advancePhase({String? note}) async {
    if (!isLoaded) return;
    final current = _order!;

    _isSyncing = true;
    notifyListeners();
    try {
      final updated = await _advancePhase(
        currentOrder: current,
        revert: false,
        note: note,
      );
      _order = updated;
      _status = MasterOrderStatus.loaded;
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      _status = MasterOrderStatus.error;
      _errorMessage = 'Error al avanzar de fase: $e';
      notifyListeners();
    }
  }

  Future<void> revertPhase() async {
    if (!isLoaded) return;
    final current = _order!;

    _isSyncing = true;
    notifyListeners();
    try {
      final updated = await _advancePhase(currentOrder: current, revert: true);
      _order = updated;
      _status = MasterOrderStatus.loaded;
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      _status = MasterOrderStatus.error;
      _errorMessage = 'Error al retroceder de fase: $e';
      notifyListeners();
    }
  }

  void updatePhaseNote(String note) {
    if (!isLoaded) return;
    final current = _order!;
    final notes = Map.of(current.phaseNotes);
    notes[current.phase] = note;
    _order = current.copyWith(phaseNotes: notes);
    notifyListeners();
  }

  void consumeError() {
    _errorMessage = null;
  }
}
