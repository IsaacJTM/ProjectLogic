import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/presentation/pages/agregar_oden_page.dart';
import 'package:logistics_pro/features/admin/presentation/pages/editar_perfil_page.dart';
import 'package:logistics_pro/features/admin/presentation/pages/lista_ordenes_page.dart';
import 'package:logistics_pro/features/admin/presentation/pages/main_shell.dart';
import 'package:logistics_pro/features/logistics/domain/usecases/submit_execution_checklist_usecase.dart';
import 'package:logistics_pro/features/logistics/domain/usecases/track_technician_route_usecase.dart';
import 'package:logistics_pro/features/logistics/presentation/controllers/master_order/master_order_controller.dart';
import 'package:logistics_pro/features/logistics/presentation/controllers/phase_1_en_route/en_route_controller.dart';
import 'package:logistics_pro/features/logistics/presentation/controllers/phase_3_execution/execution_controller.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_pro/features/admin/presentation/pages/create_personal_pages.dart';
import 'package:logistics_pro/features/admin/presentation/pages/persona_page.dart';
import 'package:logistics_pro/features/auth/domain/entities/user_role.dart';
import 'package:logistics_pro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:logistics_pro/features/auth/presentation/pages/login_page.dart';
import 'package:logistics_pro/features/logistics/data/datasources/media_upload_api.dart';
import 'package:logistics_pro/features/logistics/data/datasources/order_remote_api.dart';
import 'package:logistics_pro/features/logistics/data/datasources/route_gps_api.dart';
import 'package:logistics_pro/features/logistics/data/repositories/logistics_repository_impl.dart';
import 'package:logistics_pro/features/logistics/presentation/pages/logistics_dashboard_page.dart';

// 🚀 IMPORTACIÓN DE LA NUEVA PANTALLA DE ÓRDENES
import 'package:logistics_pro/features/logistics/presentation/pages/worker_orders_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String adminHome = '/admin-home';
  static const String workHome = '/worker-home';
  // 🚀 NUEVA RUTA PARA EL DASHBOARD
  static const String workDashboard = '/worker-dashboard/:orderId';
  static const String crearPersonal = '/create_person';
  static const String editPersonal = '/edit_person';
  static const String createOrden = '/create-orden';
  static const String listaOrdenes = '/list-ordens';

  AppRouter._();

  static GoRouter createRouter(AuthController authController) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: authController,
      redirect: (context, state) {
        //Obtener el estado acutal de autenticación
        final isLoggedIn = authController.status == AuthStatus.authenticated;
        final isOnLoginScreen = state.matchedLocation == login;
        //Si no esta logueado le mandamos al login
        if (!isLoggedIn && !isOnLoginScreen) {
          return login;
        }
        //si ya esta logueado e intenta ir al login
        if (isLoggedIn && isOnLoginScreen) {
          final dest = authController.user?.role == UserRole.admin
              ? adminHome
              : workHome;
          return dest;
        }

        return null;
      },
      routes: [
        GoRoute(path: login, builder: (context, state) => const LoginPage()),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: adminHome,
              builder: (context, state) => PersonaPage(),
            ),
            GoRoute(
              path: listaOrdenes,
              builder: (context, state) => ListaOrdenesPage(),
            ),
          ],
        ),
        GoRoute(
          path: crearPersonal,
          builder: (context, state) => CreatePersonalPages(),
        ),
        GoRoute(
          path: editPersonal,
          builder: (context, state) {
            final personaModel = state.extra as PersonaModel;
            return EditarPerfilPage(personaModel: personaModel);
          },
        ),
        GoRoute(
          path: createOrden,
          builder: (context, state) => AgregarOrdenPage(),
        ),

        // 🚀 ESTA RUTA AHORA MUESTRA LA LISTA DE ÓRDENES (WorkerOrdersPage)
        GoRoute(
          path: workHome,
          builder: (context, state) {
            final repository = LogisticsRepositoryImpl(
              orderRemoteApi: OrderRemoteApi(),
              routeGpsApi: RouteGpsApi(),
              mediaUploadApi: MediaUploadApi(),
            );

            return WorkerOrdersPage(repository: repository);
          },
        ),

        // 🚀 NUEVA RUTA: EL DASHBOARD DE LA ORDEN SELECCIONADA
        GoRoute(
          path: workDashboard,
          builder: (context, state) {
            // Extraemos el ID de la orden de la URL
            final orderId = state.pathParameters['orderId'] ?? '';

            final repository = LogisticsRepositoryImpl(
              orderRemoteApi: OrderRemoteApi(),
              routeGpsApi: RouteGpsApi(),
              mediaUploadApi: MediaUploadApi(),
            );

            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => MasterOrderController(
                    repository: repository,
                  )..loadOrderById(orderId), // Carga la orden específica por ID
                ),
                ChangeNotifierProvider(
                  create: (_) => EnRouteController(
                    trackRoute: TrackTechnicianRouteUseCase(repository),
                  ),
                ),
                ChangeNotifierProvider(
                  create: (_) => ExecutionController(
                    submitChecklistUseCase: SubmitExecutionChecklistUseCase(
                      repository,
                    ),
                    logisticsRepository: repository,
                  ),
                ),
              ],
              child: const LogisticsDashboardPage(),
            );
          },
        ),
      ],
    );
  }
}
