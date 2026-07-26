import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_phase.dart';
import '../../domain/repositories/logistics_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

const _brandBlue = Color(0xFF1E40AF); // mismo azul que LogisticsDashboardPage

/// ---------------------------------------------------------------------
/// TOKENS — misma identidad visual que la pantalla de detalle de orden:
/// azul de marca, tarjetas blancas flotantes, verde para completado.
/// ---------------------------------------------------------------------
class _T {
  static const bg = Color(0xFFF2F4F9); // fondo gris-azulado claro
  static const card = Colors.white;
  static const ink = Color(0xFF16213A); // texto principal
  static const inkSoft = Color(0xFF7B849A); // texto secundario

  static const blue = Color(0xFF2F55E0); // azul de marca
  static const blueDark = Color(0xFF17318F); // fin del degradado
  static const slate = Color(0xFF9AA3B8); // fase "asignado"
  static const indigo = Color(0xFF5B4FE0); // fase "ejecución"
  static const green = Color(0xFF2FA972); // fase "finalizado"
}

class WorkerOrdersPage extends StatefulWidget {
  final LogisticsRepository repository;

  const WorkerOrdersPage({super.key, required this.repository});

  @override
  State<WorkerOrdersPage> createState() => _WorkerOrdersPageState();
}

class _WorkerOrdersPageState extends State<WorkerOrdersPage> {
  late Future<List<OrderEntity>> _ordersFuture;
  late String _userEmail;

  @override
  void initState() {
    super.initState();
    final authController = context.read<AuthController>();
    _userEmail = authController.user?.email ?? '';
    _fetchOrders();
  }

  void _fetchOrders() {
    _ordersFuture = widget.repository.getActiveOrders(_userEmail);
  }

  Future<void> _onRefresh() async {
    setState(_fetchOrders);
    await _ordersFuture;
  }

  List<Color> _phaseGradient(OrderPhase phase) {
    switch (phase) {
      case OrderPhase.assigned:
        return [_T.slate, const Color(0xFF7C8499)];
      case OrderPhase.enRoute:
        return [const Color(0xFF3B6FF0), _T.blueDark];
      case OrderPhase.onSite:
        return [_T.blue, _T.blueDark];
      case OrderPhase.execution:
        return [_T.indigo, const Color(0xFF3B31A8)];
      case OrderPhase.completed:
        return [_T.green, const Color(0xFF1F8256)];
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('¿Cerrar sesión?'),
          content: const Text(
            '¿Estás seguro de que deseas salir de Logistics Pro?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                try {
                  context.read<AuthController>().logout();
                  if (context.mounted) context.go('/login');
                } catch (e) {
                  debugPrint('Error al cerrar sesión: $e');
                }
              },
              child: const Text(
                'Salir',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _phaseIcon(OrderPhase phase) {
    switch (phase) {
      case OrderPhase.assigned:
        return Icons.badge_rounded;
      case OrderPhase.enRoute:
        return Icons.local_shipping_rounded;
      case OrderPhase.onSite:
        return Icons.location_on_rounded;
      case OrderPhase.execution:
        return Icons.build_rounded;
      case OrderPhase.completed:
        return Icons.verified_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.15), height: 1.0),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(Icons.local_shipping, color: _brandBlue, size: 28),
        ),
        leadingWidth: 44,
        title: const Text(
          'Logistics Pro',
          style: TextStyle(
            color: _brandBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Color(0xFF334155),
                size: 28,
              ),
              tooltip: 'Cerrar Sesión',
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ListHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: _T.blue,
                backgroundColor: _T.card,
                child: FutureBuilder<List<OrderEntity>>(
                  future: _ordersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _T.blue),
                      );
                    }

                    if (snapshot.hasError) {
                      return _StateScroller(
                        icon: Icons.error_outline_rounded,
                        iconColor: const Color(0xFFD9564C),
                        title: 'No pudimos cargar tus órdenes',
                        subtitle: 'Desliza hacia abajo para reintentar.',
                        detail: snapshot.error.toString(),
                      );
                    }

                    final orders = snapshot.data ?? const <OrderEntity>[];

                    if (orders.isEmpty) {
                      return const _StateScroller(
                        icon: Icons.inbox_rounded,
                        iconColor: _T.slate,
                        title: 'Sin órdenes asignadas',
                        subtitle:
                            'Cuando te asignen una ruta aparecerá aquí. '
                            'Desliza hacia abajo para revisar de nuevo.',
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _OrderCard(
                          orderId: order.id,
                          phaseLabel: order.phase.label,
                          gradient: _phaseGradient(order.phase),
                          icon: _phaseIcon(order.phase),
                          onTap: () =>
                              context.push('/worker-dashboard/${order.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _T.card,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis órdenes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _T.ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Toca una orden para ver y avanzar su progreso',
            style: TextStyle(fontSize: 13, color: _T.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String phaseLabel;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _OrderCard({
    required this.orderId,
    required this.phaseLabel,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _T.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _T.ink.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden #$orderId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _T.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Text(
                        phaseLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _T.inkSoft,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateScroller extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? detail;

  const _StateScroller({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.68,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _T.card,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _T.ink.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 32, color: iconColor),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _T.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, color: _T.inkSoft),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      detail!,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: _T.inkSoft),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
