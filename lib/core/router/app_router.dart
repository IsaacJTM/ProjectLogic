import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics_pro/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:logistics_pro/features/admin/data/datasources/ordenes_remote_datasource.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:logistics_pro/features/admin/domain/usecases/create_orden_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/create_persona_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/get_personal_usecase.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/ordenes_controller.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/persona_controller.dart';
import 'package:logistics_pro/features/admin/presentation/pages/agregar_oden_page.dart';
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

class AppRouter {
  static const String login = '/login';
  static const String adminHome = '/admin-home';
  static const String workHome = '/worker-home';
  static const String editPersonal = '/edit-person';
  static const String createOrden = '/create-orden';

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
        GoRoute(
          path: login, 
          builder: (context, state) => const LoginPage()
        ),
        ShellRoute(
          builder: (context, state, child){
            final adminDataSource = AdminRemoteDatasource();
            final ordenDataSource = OrdenesRemoteDatasource();
            final adminRepository = AdminRepositoryImpl(adminDataSource,ordenDataSource );

            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => PersonaController(
                    createPersonaUsecase: CreatePersonaUsecase(adminRepository),
                    getPersonalUsecase: GetPersonalUsecase(adminRepository)
                  ),
                ),
                ChangeNotifierProvider(
                  create: (_) => OrdenesController(
                    CreateOrdenUsecase(adminRepository)
                  ),
                )
              ],
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: adminHome,
              builder: (context, state) => PersonaPage(),
            ),
            GoRoute(
              path: editPersonal,
              builder: (context, state) => CreatePersonalPages(),
            ),
            GoRoute(
              path: createOrden,
              builder: (context, state) {
                final personalSeleccionado = state.extra as PersonaModel;
                return AgregarOrdenPage(tecnico: personalSeleccionado);
              }
            )
          ]
        ),
        GoRoute(
          path: workHome,
          builder: (context, state) {
            //const orderId = '234433';
            final userEmail = authController.user?.email ?? '';
            final repository = LogisticsRepositoryImpl(
              orderRemoteApi: OrderRemoteApi(),
              routeGpsApi: RouteGpsApi(),
              mediaUploadApi: MediaUploadApi(),
            );

            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) =>
                      MasterOrderController(repository: repository)
                        ..loadOrder(userEmail),
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
              //child: const LogisticsDashboardPage(orderId: orderId),
              child: const LogisticsDashboardPage(),
            );
          },
        ),
      ],
    );
  }
}
