import 'package:flutter/material.dart';

enum _AssignedStatus { idle, processing, accepted, rejected }

class AssignedPhaseView extends StatefulWidget {
  const AssignedPhaseView({super.key});

  @override
  State<AssignedPhaseView> createState() => _AssignedPhaseViewState();
}

class _AssignedPhaseViewState extends State<AssignedPhaseView> {
  _AssignedStatus _status = _AssignedStatus.idle;

  Future<void> _acceptOrder() async {
    setState(() => _status = _AssignedStatus.processing);
    if (!mounted) return;
    setState(() => _status = _AssignedStatus.accepted);
  }

  Future<void> _rejectOrder(String reason) async {
    setState(() => _status = _AssignedStatus.processing);
    if (!mounted) return;
    setState(() => _status = _AssignedStatus.rejected);
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = _status == _AssignedStatus.processing;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '¿Aceptas esta orden de trabajo?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing
                      ? null
                      : () => _rejectOrder('No disponible'),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _acceptOrder,
                  child: isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
