import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapaSeleccionPantalla extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const MapaSeleccionPantalla({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<MapaSeleccionPantalla> createState() => _MapaSeleccionPantallaState();
}

class _MapaSeleccionPantallaState extends State<MapaSeleccionPantalla> {
  LatLng? _ubicacionSeleccionada;
  late LatLng _centroMapa;
  final MapController _mapController =
      MapController(); // Controlador para mover la cámara
  bool _obteniendoUbicacion = true;

  @override
  void initState() {
    super.initState();
    // Por defecto inicia en las coordenadas pasadas (San Juan de Lurigancho/Lima)
    _centroMapa = LatLng(widget.initialLat, widget.initialLng);
    _ubicacionSeleccionada = _centroMapa;

    // Inmediatamente pedimos el GPS
    _determinarUbicacionActual();
  }

  Future<void> _determinarUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificamos si el GPS físico del celular está prendido
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _obteniendoUbicacion = false);
      _pedirEncenderGPS();
      return;
    }

    // 2. Verificamos los permisos de la app (Si le diste "Permitir")
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission(); // Lanza la ventana emergente de permisos de Android
      if (permission == LocationPermission.denied) {
        setState(() => _obteniendoUbicacion = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _obteniendoUbicacion = false);
      // Opcional: Podrías abrir la configuración de la app aquí con Geolocator.openAppSettings()
      return;
    }

    // 3. Obtenemos la posición real
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _centroMapa = LatLng(position.latitude, position.longitude);
        _ubicacionSeleccionada = _centroMapa;
        _obteniendoUbicacion = false;
      });

      _mapController.move(_centroMapa, 16.0);
    } catch (e) {
      setState(() => _obteniendoUbicacion = false);
    }
  }

  void _pedirEncenderGPS() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('GPS Desactivado'),
          content: const Text(
            'Por favor, enciende la ubicación (GPS) de tu teléfono para ubicarte en el mapa.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
              ),
              child: const Text(
                'Configuración',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toca para seleccionar'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E40AF),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, size: 28, color: Colors.green),
            onPressed: () {
              // Devuelve las coordenadas a la pantalla anterior
              Navigator.of(context).pop(_ubicacionSeleccionada);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // Conectar el controlador
            options: MapOptions(
              initialCenter: _centroMapa,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _ubicacionSeleccionada = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.logistics_pro.app',
              ),
              if (_ubicacionSeleccionada != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _ubicacionSeleccionada!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Muestra un indicador de carga mientras busca tu GPS
          if (_obteniendoUbicacion)
            const Center(
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF1E40AF)),
                      SizedBox(height: 16),
                      Text(
                        'Ubicándote en el mapa...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E40AF),
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () {
          setState(() {
            _obteniendoUbicacion = true;
          });
          _determinarUbicacionActual();
        },
      ),
    );
  }
}
