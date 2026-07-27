import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/master_order/master_order_controller.dart';
import '../controllers/phase_1_en_route/en_route_controller.dart';

class EnRoutePhaseView extends StatefulWidget {
  final String orderId;
  const EnRoutePhaseView({super.key, required this.orderId});

  @override
  State<EnRoutePhaseView> createState() => _EnRoutePhaseViewState();
}

class _EnRoutePhaseViewState extends State<EnRoutePhaseView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Solo reintentamos si ya estábamos en modo tracking
      if (context.read<EnRouteController>().status == EnRouteStatus.tracking) {
        context.read<EnRouteController>().startTracking(
          widget.orderId,
          context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnRouteController>(
      builder: (context, state, _) {
        final isTracking = state.status == EnRouteStatus.tracking;
        final isIdle = state.status == EnRouteStatus.idle;
        final coord = isTracking ? state.lastPosition : null;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_shipping_rounded, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'En camino al sitio',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // TEXTO DE ESTADO O COORDENADAS
              Text(
                isIdle
                    ? 'Listo para iniciar el trayecto.'
                    : (coord == null
                          ? 'Obteniendo ubicación GPS...'
                          : 'Lat: ${coord.latitude.toStringAsFixed(4)}, Lng: ${coord.longitude.toStringAsFixed(4)}'),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // ZONA DEL MAPA O BOTÓN DE INICIO
              if (isIdle)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 0,
                      ),
                      onPressed: () {
                        context.read<EnRouteController>().startTracking(
                          widget.orderId,
                          context,
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Iniciar Ruta y Activar GPS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              else if (coord == null)
                // 2️⃣ CARGANDO UBICACIÓN
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                // 3️⃣ MAPA CON COORDENADAS
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(coord.latitude, coord.longitude),
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.logistics_pro.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(coord.latitude, coord.longitude),
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // BOTÓN FINAL (Llegada al sitio)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: coord == null
                      ? null
                      : () async {
                          print(
                            '1️⃣ BOTÓN PRESIONADO: Voy a mandar Lat: ${coord.latitude}',
                          );
                          context.read<EnRouteController>().arrivedAtSite();

                          final master = context.read<MasterOrderController>();
                          if (!master.isSyncing) {
                            await master.advancePhase(
                              lat: coord.latitude,
                              lng: coord.longitude,
                            );
                          }
                        },
                  icon: const Icon(Icons.location_on_rounded),
                  label: const Text('He llegado al sitio'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
