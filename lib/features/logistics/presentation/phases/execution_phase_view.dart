import 'package:flutter/material.dart';
import 'package:logistics_pro/features/logistics/presentation/controllers/master_order/master_order_controller.dart';
import 'package:provider/provider.dart';
import '../controllers/phase_3_execution/execution_controller.dart';

class ExecutionPhaseView extends StatefulWidget {
  final String orderId;
  const ExecutionPhaseView({super.key, required this.orderId});

  @override
  State<ExecutionPhaseView> createState() => _ExecutionPhaseViewState();
}

class _ExecutionPhaseViewState extends State<ExecutionPhaseView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final masterController = context.read<MasterOrderController>();
      final orderEntity = masterController.order;

      if (orderEntity != null) {
        context.read<ExecutionController>().loadTasksFromFirestore(
          widget.orderId,
          orderEntity.createdAt,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExecutionController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.tasks.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No hay tareas asignadas a esta orden en Firestore.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.tasks.length,
              itemBuilder: (context, index) {
                final task = controller.tasks[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  color: task.done
                      ? Colors.blue.shade50
                      : const Color(0xFFF8FAFC),
                  child: CheckboxListTile(
                    activeColor: Colors.blue.shade600,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      task.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: task.done
                            ? Colors.blue.shade900
                            : const Color(0xFF334155),
                        decoration: task.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: task.note != null && task.note!.isNotEmpty
                        ? Text(task.note!, style: const TextStyle(fontSize: 12))
                        : null,
                    value: task.done,
                    onChanged: (_) {
                      controller.toggleTask(task.id);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Botón de finalización
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.progress == 1.0
                      ? Colors.green
                      : Colors.grey.shade300,
                  foregroundColor: controller.progress == 1.0
                      ? Colors.white
                      : Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    controller.progress == 1.0 && !controller.isSubmitting
                    ? () => controller.submitChecklist(widget.orderId)
                    : null,
                child: controller.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Enviar checklist y finalizar ejecución',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
