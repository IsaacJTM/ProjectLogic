import 'package:flutter/material.dart';

enum _CompletedStatus { idle, processing, done }

class CompletedPhaseView extends StatefulWidget {
  const CompletedPhaseView({super.key});

  @override
  State<CompletedPhaseView> createState() => _CompletedPhaseViewState();
}

class _CompletedPhaseViewState extends State<CompletedPhaseView> {
  _CompletedStatus _status = _CompletedStatus.idle;
  String? _summary;

  Future<void> _collectSignature() async {
    setState(() => _status = _CompletedStatus.processing);
    await Future.delayed(const Duration(milliseconds: 800));
    await _generateSummary();
  }

  Future<void> _generateSummary() async {
    if (!mounted) return;
    setState(() => _status = _CompletedStatus.processing);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _summary = 'Orden completada exitosamente.';
      _status = _CompletedStatus.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_status == _CompletedStatus.done) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.verified_rounded, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text(_summary ?? '', textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final isProcessing = _status == _CompletedStatus.processing;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.draw_rounded, size: 48, color: Colors.blueGrey),
          const SizedBox(height: 12),
          const Text('Solicita la firma del cliente para cerrar la orden'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isProcessing ? null : _collectSignature,
            icon: isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check),
            label: const Text('Capturar firma'),
          ),
        ],
      ),
    );
  }
}
