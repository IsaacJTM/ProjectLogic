import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🚀 Para conectar Firestore
import 'package:logistics_pro/features/logistics/data/datasources/media_upload_api.dart';

enum _OnSiteStatus { idle, uploading, confirmed }

class OnSitePhaseView extends StatefulWidget {
  final String orderId;

  const OnSitePhaseView({super.key, required this.orderId});

  @override
  State<OnSitePhaseView> createState() => _OnSitePhaseViewState();
}

class _OnSitePhaseViewState extends State<OnSitePhaseView> {
  _OnSiteStatus _status = _OnSiteStatus.idle;
  final ImagePicker _picker = ImagePicker();
  final MediaUploadApi _mediaApi = MediaUploadApi();

  // Variable para guardar y mostrar la URL de la foto
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    // Al abrir la pantalla, buscamos si ya hay una foto guardada
    _loadExistingPhoto();
  }
  Future<void> _loadExistingPhoto() async {
    try {
      final numOrden = int.tryParse(widget.orderId) ?? 0;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('ordenes_trabajo')
          .where('nroOrden', isEqualTo: numOrden)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final existingUrl = data['urlEvidenciaLlegada'] as String?;

        if (existingUrl != null && existingUrl.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _uploadedImageUrl = existingUrl;
            _status = _OnSiteStatus.confirmed;
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar evidencia existente: $e');
    }
  }

  Future<void> _captureArrivalPhoto() async {
    try {
      // 1. Abrimos la cámara
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo == null) return;

      setState(() => _status = _OnSiteStatus.uploading);

      // 2. Leemos la imagen como bytes
      final bytes = await photo.readAsBytes();

      // 3. Subimos los bytes a Firebase Cloud Storage o Cloudinary
      final String photoUrl = await _mediaApi.upload(
        orderId: widget.orderId,
        tag: 'llegada',
        bytes: bytes,
      );

      // 4. Buscamos el ID real ("2") usando el nroOrden ("1002")
      final numOrden = int.tryParse(widget.orderId) ?? 0;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ordenes_trabajo')
          .where('nroOrden', isEqualTo: numOrden)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No se encontró el número de orden $numOrden');
      }

      final docIdReal = querySnapshot.docs.first.id;

      // 5. Guardamos la URL en el documento correcto en Firestore
      await FirebaseFirestore.instance
          .collection('ordenes_trabajo')
          .doc(docIdReal)
          .update({
            'urlEvidenciaLlegada': photoUrl,
            'fechaEvidenciaLlegada': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      setState(() {
        _status = _OnSiteStatus.confirmed;
        _uploadedImageUrl = photoUrl; // Actualizamos la vista previa
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Evidencia guardada en la nube con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        // Si hay error, regresamos al estado anterior
        _status = _uploadedImageUrl != null
            ? _OnSiteStatus.confirmed
            : _OnSiteStatus.idle;
      });
      debugPrint('Error al guardar evidencia: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = _status == _OnSiteStatus.uploading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_uploadedImageUrl != null && !isUploading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _uploadedImageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text(
                  'Evidencia registrada',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else if (isUploading) ...[
            const SizedBox(
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Subiendo nueva imagen a la nube...'),
                ],
              ),
            ),
          ] else ...[
            const Icon(
              Icons.camera_alt_rounded,
              size: 48,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 12),
            const Text(
              'Toma una foto como evidencia de llegada',
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 16),
          if (_uploadedImageUrl != null) ...[
            // Botón para Retomar Foto (si ya existe una)
            OutlinedButton.icon(
              onPressed: isUploading ? null : _captureArrivalPhoto,
              icon: const Icon(Icons.cameraswitch_outlined),
              label: const Text('Volver a tomar foto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueGrey.shade700,
                side: BorderSide(color: Colors.blueGrey.shade300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ] else ...[
            // Botón Principal de Captura (si no hay foto)
            ElevatedButton.icon(
              onPressed: isUploading ? null : _captureArrivalPhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Capturar evidencia'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
