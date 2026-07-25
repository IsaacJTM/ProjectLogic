import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/coordinate_entity.dart';
import '../../../domain/usecases/track_technician_route_usecase.dart';

enum EnRouteStatus { idle, tracking, arrived }

class EnRouteController extends ChangeNotifier {
  final TrackTechnicianRouteUseCase trackRoute;
  StreamSubscription<CoordinateEntity>? _subscription;

  EnRouteController({required this.trackRoute});

  EnRouteStatus _status = EnRouteStatus.idle;
  CoordinateEntity? _lastPosition;

  EnRouteStatus get status => _status;
  CoordinateEntity? get lastPosition => _lastPosition;

  // Método privado para solicitar permisos de GPS
  Future<void> _solicitarPermisoGPS(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 1. Si apagó el GPS del celular, lo mandamos a prenderlo
      await Geolocator.openLocationSettings();
      return Future.error('El GPS está apagado');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // 2. EL TRABAJADOR PRESIONÓ "NO PERMITIR"
        // Aquí le muestras un mensaje o alerta diciendo:
        // "Obligatorio: Necesitas compartir tu ubicación para iniciar la ruta."
        return Future.error('Permiso denegado por el usuario');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      //3EL TRABAJADOR BLOQUEÓ LOS PERMISOS PERMANENTEMENTE
      // Si le dio a "No volver a preguntar", la única forma es abrir los ajustes del celular
      await Geolocator.openAppSettings();
      return Future.error('Permisos bloqueados. Ve a ajustes.');
    }
  }

  Future<void> startTracking(String orderId, BuildContext context) async {
    // 1. PROTECCIÓN: Si ya estamos rastreando y tenemos ubicación, no reinicies nada
    if (_status == EnRouteStatus.tracking && _lastPosition != null) {
      return;
    }

    try {
      await _solicitarPermisoGPS(context);

      _status = EnRouteStatus.tracking;
      notifyListeners();

      // 2. CARGA INSTANTÁNEA: Pedimos la ubicación actual de inmediato
      // (Comenta este bloque si estás usando el Stream de prueba del emulador)
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastPosition = CoordinateEntity(
        latitude: initialPosition.latitude,
        longitude: initialPosition.longitude,
        timestamp: initialPosition.timestamp ?? DateTime.now(),
      );
      notifyListeners(); // ¡El mapa se dibuja al instante!

      // 3. RASTREO CONTINUO: Ahora sí encendemos el Stream para cuando camine
      _subscription?.cancel();
      _subscription =
          Geolocator.getPositionStream(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 2,
                ),
              )
              // Convertimos Position a CoordinateEntity antes de escuchar
              .map(
                (Position position) => CoordinateEntity(
                  latitude: position.latitude,
                  longitude: position.longitude,
                  timestamp: position.timestamp ?? DateTime.now(),
                ),
              )
              .listen((CoordinateEntity coord) {
                _lastPosition = coord;
                notifyListeners();
              });
    } catch (e) {
      // 🛡️ 1. DESTRUIMOS LA COORDENADA ANTERIOR SI HAY ERROR
      // Esto forzará al botón de la vista a ponerse gris (null)
      _status = EnRouteStatus.idle;
      _lastPosition = null;
      notifyListeners();

      if (kDebugMode) {
        print("Error en startTracking: $e");
      }

      // 2. Mostramos la alerta roja
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ No podemos iniciar la ruta si el GPS está apagado o sin permisos.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void arrivedAtSite() {
    _status = EnRouteStatus.arrived;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
