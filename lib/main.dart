import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logistics_pro/core/router/app_router.dart';
import 'package:logistics_pro/features/auth/data/datasources/auth_remote_api.dart';
import 'package:logistics_pro/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:logistics_pro/features/auth/domain/usecases/login_usecase.dart';
import 'package:logistics_pro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:logistics_pro/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LogisticsProApp());
} 

class LogisticsProApp extends StatelessWidget {
  const LogisticsProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final api = AuthRemoteApi();
        final repository = AuthRepositoryImpl(api);
        final loginUseCase = LoginUseCase(repository);
        return AuthController(loginUseCase: loginUseCase);
      },
      child: Builder(
        builder: (context){
          // Obtenemos el controlador creado arriba
          final authController = context.watch<AuthController>();
          
          // Creamos el router pasándole el controlador
          final router = AppRouter.createRouter(authController);
          return MaterialApp.router(
            title: 'Logistics Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
          );
        }
      )
      
    );
  }
}
