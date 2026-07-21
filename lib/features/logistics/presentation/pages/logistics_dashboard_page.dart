import 'package:flutter/material.dart';
import 'package:logistics_pro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/order_phase.dart';
import '../controllers/master_order/master_order_controller.dart';
import '../controllers/phase_3_execution/execution_controller.dart';
import '../phases/assigned_phase_view.dart';
import '../phases/completed_phase_view.dart';
import '../phases/en_route_phase_view.dart';
import '../phases/execution_phase_view.dart';
import '../phases/on_site_phase_view.dart';
import '../widgets/hero_status_card.dart';
import '../widgets/modern_loading_overlay.dart';
import '../widgets/timeline_stepper.dart';

class LogisticsDashboardPage extends StatelessWidget {
  const LogisticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardBody();
  }
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  MasterOrderController? _masterController;

  bool _canRevert(OrderPhase phase) => phase.previous != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<MasterOrderController>();
    if (_masterController != controller) {
      _masterController?.removeListener(_onMasterOrderChanged);
      _masterController = controller;
      _masterController!.addListener(_onMasterOrderChanged);
    }
  }

  void _onMasterOrderChanged() {
    final state = _masterController!;
    if (state.status == MasterOrderStatus.error && state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      state.consumeError();
    }
  }

  @override
  void dispose() {
    _masterController?.removeListener(_onMasterOrderChanged);
    super.dispose();
  }

  Widget _buildPhaseContent(OrderPhase phase, String currentOrderId) {
    switch (phase) {
      case OrderPhase.assigned:
        return const AssignedPhaseView();
      case OrderPhase.enRoute:
        return EnRoutePhaseView(orderId: currentOrderId);
      case OrderPhase.onSite:
        return const OnSitePhaseView();
      case OrderPhase.execution:
        return ExecutionPhaseView(orderId: currentOrderId);
      case OrderPhase.completed:
        return const CompletedPhaseView();
    }
  }

  /// Cuadro de diálogo institucional para confirmar la salida segura del técnico
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('¿Cerrar Sesión?'),
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
                  // ✅ CORREGIDO: Quitamos el 'await' ya que 'logout()' es síncrono (void)
                  context.read<AuthController>().logout();

                  if (context.mounted) {
                    context.go('/login');
                  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Fondo claro y pulcro para el Scaffold
      // 🛠️ BARRA SUPERIOR INSTITUCIONAL (Estilo idéntico a Screenshot_4.png)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Evita la flecha por defecto
        // Línea divisoria inferior muy sutil para igualar el estilo web
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.15), height: 1.0),
        ),

        // Icono de camión azul a la izquierda
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(
            Icons.local_shipping,
            color: Color(0xFF1E40AF), // El azul rey corporativo
            size: 28,
          ),
        ),
        leadingWidth: 44,

        // Título de la Aplicación en la AppBar
        title: const Text(
          'Logistics Pro',
          style: TextStyle(
            color: Color(0xFF1E40AF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
        ),

        // Botón de Salir (Cerrar Sesión) en el extremo derecho
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Color(0xFF334155), // Gris carbón profesional
                size: 28,
              ),
              tooltip: 'Cerrar Sesión',
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),

      body: Consumer<MasterOrderController>(
        builder: (context, masterState, _) {
          if (masterState.status == MasterOrderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. CONTROL DE ESTADO VACÍO: Si no hay órdenes
          if (masterState.status == MasterOrderStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.task_alt_rounded,
                        size: 80,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      masterState.errorMessage ?? 'Sin órdenes pendientes',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¡Excelente trabajo! Has completado tus asignaciones o estás al día con tus rutas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<MasterOrderController>().loadOrder(
                          "manuel.rm@worker.com",
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Comprobar nuevas órdenes'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!masterState.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = masterState.order!;
          final actualOrderId = order.id;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Mantiene el título "Orden #1002" flotante y elegante
                  SliverAppBar(
                    expandedHeight: 100,
                    pinned: true,
                    backgroundColor: const Color(0xFFF4F7FC),
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                      title: Text(
                        'Orden #$actualOrderId',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TimelineStepper(currentPhase: order.phase),
                          const SizedBox(height: 24),
                          Consumer<ExecutionController>(
                            builder: (context, execState, _) {
                              return HeroStatusCard(
                                phase: order.phase,
                                progress: execState.progress,
                                completedTasks: execState.tasks
                                    .where((t) => t.done)
                                    .length,
                                totalTasks: execState.tasks.length,
                                elapsedLabel: execState.elapsedLabel,
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          _buildPhaseContent(order.phase, actualOrderId),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (masterState.isSyncing) const ModernLoadingOverlay(),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<MasterOrderController>(
        builder: (context, masterState, _) {
          if (!masterState.isLoaded) return const SizedBox.shrink();
          final order = masterState.order!;
          final canRevert = _canRevert(order.phase);
          final isLast = order.phase == OrderPhase.completed;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (canRevert) ...[
                  IconButton.filledTonal(
                    onPressed: masterState.isSyncing
                        ? null
                        : () async {
                            String nombreFaseAnterior = '';
                            switch (order.phase) {
                              case OrderPhase.enRoute:
                                nombreFaseAnterior = 'ASIGNADO';
                                break;
                              case OrderPhase.onSite:
                                nombreFaseAnterior = 'EN RUTA';
                                break;
                              case OrderPhase.execution:
                                nombreFaseAnterior = 'EN SITIO';
                                break;
                              case OrderPhase.completed:
                                nombreFaseAnterior = 'EJECUCIÓN';
                                break;
                              default:
                                nombreFaseAnterior = 'FASE ANTERIOR';
                            }

                            final seguroDeRetroceder = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 10),
                                      Text('¿Regresar de fase?'),
                                    ],
                                  ),
                                  content: Text(
                                    '¿Estás seguro de que deseas regresar a la fase anterior ("$nombreFaseAnterior")? '
                                    'Esto cambiará el estado en el sistema.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade50,
                                        elevation: 0,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text(
                                        'Sí, regresar',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (seguroDeRetroceder == true && context.mounted) {
                              context
                                  .read<MasterOrderController>()
                                  .revertPhase();
                            }
                          },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: masterState.isSyncing || isLast
                          ? null
                          : () => context
                                .read<MasterOrderController>()
                                .advancePhase(),
                      child: Text(
                        isLast ? 'ORDEN FINALIZADA' : 'SIGUIENTE FASE',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
