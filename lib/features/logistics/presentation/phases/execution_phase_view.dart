import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/phase_3_execution/execution_controller.dart';

class ExecutionPhaseView extends StatelessWidget {
  final String orderId;
  const ExecutionPhaseView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExecutionController>(
      builder: (context, state, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'CHECKLIST OPERATIVO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: state.tasks.map((task) {
                  return CheckboxListTile(
                    value: task.done,
                    onChanged: (_) =>
                        context.read<ExecutionController>().toggleTask(task.id),
                    title: Text(
                      task.name,
                      style: TextStyle(
                        decoration: task.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.done ? Colors.grey : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: task.done
                        ? Text('Completado a las ${task.completedAt ?? ''}')
                        : null,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.progress < 1 || state.isSubmitting
                    ? null
                    : () => context.read<ExecutionController>().submitChecklist(
                        orderId,
                      ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enviar checklist y finalizar ejecución'),
              ),
            ),
          ],
        );
      },
    );
  }
}
