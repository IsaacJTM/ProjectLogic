import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:firebase_storage/firebase_storage.dart';

class MediaUploadApi {
  final String _cloudName = 'xqbbe75e';
  final String _uploadPreset = 'evidencias';
  final String _uploadUsers = 'usuarios';

  /// Subida de imágenes de Ordenes a Cloudinary vía HTTP REST
  Future<String> upload({
    required String orderId,
    required String tag,
    required List<int> bytes,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      // 1. Definir identificador y carpeta en Cloudinary
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = '${tag}_$timestamp';
      final folderPath = 'evidencias/$orderId';

      // 2. Construir la petición Multipart con el array de bytes
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = folderPath
        ..fields['public_id'] = publicId
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: '$publicId.jpg',
          ),
        );

      // 3. Enviar a Cloudinary
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);

        // Retorna la URL HTTPS pública de la imagen en Cloudinary
        return jsonMap['secure_url'] as String;
      } else {
        throw Exception(
          'Error al subir imagen a Cloudinary (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Excepción en MediaUploadApi (Cloudinary): $e');
    }
  }

  //Subir imágenes de usuarios en cloudinary vía HTTP REST
  Future<String> uploadUser({
    required String tag,
    required List<int> bytes
  }) async{
    try{

      final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    //1. Definir identificador y carpeta 
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final publicId = '${tag}_$timeStamp';
    final folderPath = 'usuarios';

    //2. contruir la petición Multipart con el array de bytes
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folderPath
      ..fields['public_id'] = publicId
      ..files.add(
        http.MultipartFile.fromBytes(
          'file', 
          bytes,
          filename: '$publicId.jpg'
        )
      );

    //3. Enviamos a Cloudinary
    final response = await request.send();

    if(response.statusCode != 200){
      throw Exception(
        'Error al subir imagen a Cloudinay ${response.statusCode}'
      );
    }
    
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonMap = jsonDecode(responseString);

    // Retornamos la URL pública de la imagen 
    return jsonMap['secure_url'] as String;
    }catch(e){
      throw Exception('Excepción en MediaUploadApi (cloudinary): $e');
    }
  }

  // CONFIGURACIÓN FIREBASE STORAGE
  // ===========================================================================
  /*
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> upload({
    required String orderId,
    required String tag,
    required List<int> bytes,
  }) async {
    // 1. Definimos la ruta en la nube: evidencias/2/llegada_1721700000.jpg
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child(
      'evidencias/$orderId/${tag}_$timestamp.jpg',
    );

    // 2. Subimos los bytes a Firebase Storage
    final uploadTask = await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    // 3. Obtenemos el link público de internet
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
  */
}
