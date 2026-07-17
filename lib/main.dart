import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logistics_pro/core/router/app_router.dart';
import 'package:logistics_pro/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:logistics_pro/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:logistics_pro/features/admin/domain/usecases/create_persona_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/get_personal_usecase.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/persona_controller.dart';
import 'package:logistics_pro/features/auth/data/datasources/auth_remote_api.dart';
import 'package:logistics_pro/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:logistics_pro/features/auth/domain/usecases/login_usecase.dart';
import 'package:logistics_pro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:logistics_pro/features/logistics/data/datasources/media_upload_api.dart';
import 'package:logistics_pro/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LogisticsProApp());
} 

class LogisticsProApp extends StatefulWidget {
  const LogisticsProApp({super.key});

  @override
  State<LogisticsProApp> createState() => _LogisticsProAppState();
}

class _LogisticsProAppState extends State<LogisticsProApp> {
  late final AuthController _authController;
  late final PersonaController _personaController;
  late final _router;

  @override
  void initState() {
    super.initState();

    //Ensambar el Modulo de auth
    final authApi = AuthRemoteApi();
    final authRepo = AuthRepositoryImpl(authApi);
    _authController = AuthController(loginUseCase: LoginUseCase(authRepo));

    //Ensambar el modulo del admin
    final adminDataSource = AdminRemoteDatasource();
    final admiRepository = AdminRepositoryImpl(adminDataSource);
    _personaController = PersonaController(
      createPersonaUsecase: CreatePersonaUsecase(admiRepository), 
      getPersonalUsecase: GetPersonalUsecase(admiRepository)
    );


    _router = AppRouter.createRouter(_authController);

  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _authController),
        ChangeNotifierProvider<PersonaController>.value(value: _personaController),
      ],
      child: MaterialApp.router(
        title: 'Logistcs App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
