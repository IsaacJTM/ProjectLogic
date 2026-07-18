import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/checklist_task_entity.dart';
import '../../../domain/repositories/logistics_repository.dart';
import '../../../domain/usecases/submit_execution_checklist_usecase.dart';

class ExecutionController extends ChangeNotifier {
  final SubmitExecutionChecklistUseCase submitChecklistUseCase;
  final LogisticsRepository logisticsRepository;

  Timer? _timer;
  //final Stopwatch _stopwatch = Stopwatch();

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

  String get elapsedLabel {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> loadTasksFromFirestore(
    String orderId,
    DateTime orderCreatedAt,
  ) async {
    if (_tasks.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final remoteTasks = await logisticsRepository.getChecklistTasks(orderId);
      _tasks = remoteTasks;

      startExecutionClock(orderCreatedAt);
    } catch (e) {
      print('Error al cargar tareas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadChecklist(List<ChecklistTaskEntity> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void startExecutionClock(DateTime startTime) {
    _timer?.cancel();

    _elapsed = DateTime.now().difference(startTime);
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Restamos el milisegundo actual menos la fecha de creación de ayer
      _elapsed = DateTime.now().difference(startTime);
      notifyListeners();
    });
  }

  void stopExecutionClock() {
    //_stopwatch.stop();
    _timer?.cancel();
  }

  void toggleTask(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final newTaskState = !_tasks[index].done;

    _tasks = _tasks.map((t) {
      if (t.id != taskId) return t;
      return t.copyWith(
        done: newTaskState,
        completedAt: newTaskState ? elapsedLabel : null,
      );
    }).toList();

    notifyListeners();

    logisticsRepository.updateTaskStatus(taskId, newTaskState).catchError((
      error,
    ) {
      print('Falló el guardado en Firebase: $error');
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
