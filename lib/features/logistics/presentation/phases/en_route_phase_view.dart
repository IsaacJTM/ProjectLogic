import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/phase_1_en_route/en_route_controller.dart';

class EnRoutePhaseView extends StatelessWidget {
  final String orderId;
  const EnRoutePhaseView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnRouteController>(
      builder: (context, state, _) {
        final coord = state.status == EnRouteStatus.tracking ? state.lastPosition : null;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_shipping_rounded, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('En camino al sitio', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                coord == null
                    ? 'Obteniendo ubicación GPS...'
                    : 'Lat: ${coord.latitude.toStringAsFixed(4)}, Lng: ${coord.longitude.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.read<EnRouteController>().arrivedAtSite(),
                icon: const Icon(Icons.location_on_rounded),
                label: const Text('He llegado al sitio'),
              ),
            ],
          ),
        );
      },
    );
  }
}
