import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/media_upload_api.dart';
import '../../data/datasources/order_remote_api.dart';
import '../../data/datasources/route_gps_api.dart';
import '../../data/repositories/logistics_repository_impl.dart';
import '../../domain/entities/order_phase.dart';
import '../../domain/usecases/submit_execution_checklist_usecase.dart';
import '../../domain/usecases/track_technician_route_usecase.dart';
import '../controllers/master_order/master_order_controller.dart';
import '../controllers/phase_1_en_route/en_route_controller.dart';
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
  final String orderId;
  const LogisticsDashboardPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return _DashboardBody(orderId: orderId);
  }
}

class _DashboardBody extends StatefulWidget {
  final String orderId;
  const _DashboardBody({required this.orderId});

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  MasterOrderController? _masterController;

  bool _canRevert(OrderPhase phase) => phase.previous != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Equivalente al `listener` de BlocConsumer<MasterOrderBloc, ...>:
    // mostramos el SnackBar de error como efecto secundario, sin que
    // forme parte del build.
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

  Widget _buildPhaseContent(OrderPhase phase) {
    switch (phase) {
      case OrderPhase.assigned:
        return const AssignedPhaseView();
      case OrderPhase.enRoute:
        return EnRoutePhaseView(orderId: widget.orderId);
      case OrderPhase.onSite:
        return const OnSitePhaseView();
      case OrderPhase.execution:
        return ExecutionPhaseView(orderId: widget.orderId);
      case OrderPhase.completed:
        return const CompletedPhaseView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MasterOrderController>(
        builder: (context, masterState, _) {
          if (!masterState.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = masterState.order!;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 100,
                    pinned: true,
                    backgroundColor: const Color(0xFFF4F7FC),
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                      title: Text(
                        'Orden #${order.id}',
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
                          _buildPhaseContent(order.phase),
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
                        : () => context
                              .read<MasterOrderController>()
                              .revertPhase(),
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
