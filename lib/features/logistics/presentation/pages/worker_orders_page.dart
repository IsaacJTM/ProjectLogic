import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/logistics_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class WorkerOrdersPage extends StatelessWidget {
  final LogisticsRepository repository;

  const WorkerOrdersPage({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();
    final userEmail = authController.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Órdenes Asignadas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // FutureBuilder llamará a tu método getActiveOrders automáticamente
      body: FutureBuilder<List<OrderEntity>>(
        future: repository.getActiveOrders(userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tienes órdenes pendientes hoy. 🎉'),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.assignment, color: Colors.white),
                  ),
                  title: Text(
                    'Orden #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Estado: ${order.phase}',
                  ), // Ajusta esto según las propiedades de tu OrderEntity
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    // 🚀 AQUÍ NAVEGAMOS AL DASHBOARD ENVIANDO EL ID DE LA ORDEN
                    context.push('/worker-dashboard/${order.id}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
