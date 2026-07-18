import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/checklist_task_entity.dart';
import '../../../domain/repositories/logistics_repository.dart';
import '../../../domain/usecases/submit_execution_checklist_usecase.dart';

class ExecutionController extends ChangeNotifier {
  final SubmitExecutionChecklistUseCase submitChecklistUseCase;
  final LogisticsRepository logisticsRepository;

  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  ExecutionController({
    required this.submitChecklistUseCase,
    required this.logisticsRepository,
  });

  List<ChecklistTaskEntity> _tasks = const [];
  Duration _elapsed = Duration.zero;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  List<ChecklistTaskEntity> get tasks => _tasks;
  Duration get elapsed => _elapsed;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isSubmitted => _isSubmitted;

  double get progress =>
      _tasks.isEmpty ? 0 : _tasks.where((t) => t.done).length / _tasks.length;

  String get elapsedLabel =>
      '${_elapsed.inMinutes.toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

  Future<void> loadTasksFromFirestore(String orderId) async {
    if (_tasks.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final remoteTasks = await logisticsRepository.getChecklistTasks(orderId);
      _tasks = remoteTasks;
      startExecutionClock();
    } catch (e) {
      print('Error al cargar tareas desde Firestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadChecklist(List<ChecklistTaskEntity> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void startExecutionClock() {
    _stopwatch
      ..reset()
      ..start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = _stopwatch.elapsed;
      notifyListeners();
    });
  }

  void stopExecutionClock() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  /// Modifica la UI instantáneamente y luego actualiza Firestore en segundo plano
  void toggleTask(String taskId) {
    // 1. Buscamos el índice exacto de la tarea en la lista actual
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    // 2. Calculamos su nuevo estado (inverso al actual)
    final newTaskState = !_tasks[index].done;

    // 3. Actualizamos la lista local y la UI DE INMEDIATO (Optimistic Update)
    _tasks = _tasks.map((t) {
      if (t.id != taskId) return t;
      return t.copyWith(
        done: newTaskState,
        completedAt: newTaskState ? elapsedLabel : null,
      );
    }).toList();

    notifyListeners(); // ¡La barra de progreso salta al instante en la pantalla!

    // 4. Mandamos a guardar a Firebase en segundo plano sin bloquear la pantalla
    logisticsRepository.updateTaskStatus(taskId, newTaskState).catchError((
      error,
    ) {
      print('❌ [CONTROLLER ERROR] Falló el guardado en Firebase: $error');
      // Opcional: Podrías revertir el cambio local si Firebase falla aquí
    });
  }

  void updateTaskNote(String taskId, String note) {
    _tasks = _tasks.map((t) {
      if (t.id != taskId) return t;
      return t.copyWith(note: note);
    }).toList();
    notifyListeners();
  }

  Future<void> submitChecklist(String orderId) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await submitChecklistUseCase(orderId, _tasks);
      stopExecutionClock();
      _isSubmitting = false;
      _isSubmitted = true;
      notifyListeners();
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
