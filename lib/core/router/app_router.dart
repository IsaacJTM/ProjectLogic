import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_pro/features/admin/presentation/pages/create_personal_pages.dart';
import 'package:logistics_pro/features/admin/presentation/pages/persona_page.dart';
import 'package:logistics_pro/features/auth/domain/entities/user_role.dart';
import 'package:logistics_pro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:logistics_pro/features/auth/presentation/pages/login_page.dart';
import 'package:logistics_pro/features/logistics/presentation/pages/logistics_dashboard_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String adminHome = '/admin-home';
  static const String workHome = '/worker-home';
  static const String editPersonal = '/edit-person';

  AppRouter._();
 
  static GoRouter createRouter(AuthController authController){
      return GoRouter(
        initialLocation: login,
        refreshListenable: authController,
        redirect: (context, state){
          //Obtener el estado acutal de autenticación
          final isLoggedIn  = authController.status == AuthStatus.authenticated;
          final isOnLoginScreen = state.matchedLocation == login;

          print("$authController");
          //Si no esta logueado le mandamos al login 
          if(!isLoggedIn && !isOnLoginScreen) {
            print('Bloqueado. Redirigiendo al login por falta de session');
            return login;
          }
          //si ya esta logueado e intenta ir al login 
          if(isLoggedIn && isOnLoginScreen){
           
            final dest =  authController.user?.role == UserRole.admin ? adminHome : workHome;
            print('-> [Router] Redirigiendo a Home correspondiente por rol: $dest');
            return dest;
          }
          
          return null;
        },
        routes: [
          GoRoute(
            path: login,
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: workHome,
            builder: (context, state) => const LogisticsDashboardPage(orderId: '2344')
          ),
          GoRoute(
            path: adminHome,
            builder: (context, state) => const PersonaPage()
          ),
          GoRoute(
            path: editPersonal,
            builder: (context, state) =>  CreatePersonalPages()
          ),
        ]
      );
  }
}