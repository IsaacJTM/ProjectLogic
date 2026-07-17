import 'package:flutter/material.dart';

enum _OnSiteStatus { idle, uploading, confirmed }

class OnSitePhaseView extends StatefulWidget {
  const OnSitePhaseView({super.key});

  @override
  State<OnSitePhaseView> createState() => _OnSitePhaseViewState();
}

class _OnSitePhaseViewState extends State<OnSitePhaseView> {
  _OnSiteStatus _status = _OnSiteStatus.idle;

  Future<void> _captureArrivalPhoto() async {
    setState(() => _status = _OnSiteStatus.uploading);
    //await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _status = _OnSiteStatus.confirmed);
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = _status == _OnSiteStatus.uploading;
    final isConfirmed = _status == _OnSiteStatus.confirmed;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.camera_alt_rounded,
            size: 48,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 12),
          const Text('Toma una foto como evidencia de llegada'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isUploading ? null : _captureArrivalPhoto,
            icon: isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.photo_camera),
            label: Text(
              isConfirmed ? 'Evidencia subida ✔' : 'Capturar evidencia',
            ),
          ),
        ],
      ),
    );
  }
}
