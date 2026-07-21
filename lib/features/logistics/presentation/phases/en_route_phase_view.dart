import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart'; // Requiere flutter_map en pubspec.yaml
import 'package:latlong2/latlong.dart'; // Requiere latlong2 en pubspec.yaml

import '../controllers/master_order/master_order_controller.dart';
import '../controllers/phase_1_en_route/en_route_controller.dart';

class EnRoutePhaseView extends StatefulWidget {
  final String orderId;
  const EnRoutePhaseView({super.key, required this.orderId});

  @override
  State<EnRoutePhaseView> createState() => _EnRoutePhaseViewState();
}

class _EnRoutePhaseViewState extends State<EnRoutePhaseView> {
  @override
  void initState() {
    super.initState();
    // Inicia el rastreo de GPS al cargar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnRouteController>().startTracking(widget.orderId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnRouteController>(
      builder: (context, state, _) {
        final coord = state.status == EnRouteStatus.tracking
            ? state.lastPosition
            : null;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
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
                coord == null
                    ? 'Obteniendo ubicación GPS...'
                    : 'Lat: ${coord.latitude.toStringAsFixed(4)}, Lng: ${coord.longitude.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // 🗺️ ZONA DEL MAPA (OPENSTREETMAP)
              if (coord == null)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
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

              // BOTÓN FINAL
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    context.read<EnRouteController>().arrivedAtSite();

                    final master = context.read<MasterOrderController>();
                    if (!master.isSyncing) {
                      await master.advancePhase();
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
