/// Subida de fotos/firmas (Fase 3: On Site, y firma en Fase 5).
class MediaUploadApi {
  Future<String> upload({
    required String orderId,
    required String tag,
    required List<int> bytes,
  }) async {
    //await Future.delayed(const Duration(milliseconds: 1200));
    return 'https://storage.logisticspro.app/$orderId/$tag.jpg';
  }
}
