import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logistics_pro/core/router/app_router.dart';
import 'package:logistics_pro/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:logistics_pro/features/admin/data/datasources/ordenes_remote_datasource.dart';
import 'package:logistics_pro/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:logistics_pro/features/admin/domain/usecases/create_orden_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/create_persona_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/get_personal_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/update_persona_usecase.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/ordenes_controller.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/persona_controller.dart';
import 'package:logistics_pro/features/auth/data/datasources/auth_remote_api.dart';
import 'package:logistics_pro/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:logistics_pro/features/auth/domain/usecases/login_usecase.dart';
import 'package:logistics_pro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:logistics_pro/firebase_options.dart';
import 'package:logistics_pro/gencode/TareaChecklistService.dart';
import 'core/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
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
  late final OrdenesController _ordenesController;
  late final _router;
  //final ClienteService _clienteService = ClienteService();
  //final OrdenTrabajoService _ordenService = OrdenTrabajoService();
  final TareaChecklistService _tareaChecklistService = TareaChecklistService();
  @override
  void initState() {
    super.initState();

    //Ensambar el Modulo de auth
    final authApi = AuthRemoteApi();
    final authRepo = AuthRepositoryImpl(authApi);
    _authController = AuthController(loginUseCase: LoginUseCase(authRepo));

    //Ensambar Módulo admin
    final adminDataSource = AdminRemoteDatasource();
    final ordenDataSource = OrdenesRemoteDatasource();
    final adminRepository = AdminRepositoryImpl(adminDataSource, ordenDataSource);

    _personaController = PersonaController(
      createPersonaUsecase: CreatePersonaUsecase(adminRepository),
      getPersonalUsecase: GetPersonalUsecase(adminRepository),
      updatePersonaUsecase: UpdatePersonaUsecase(adminRepository)
    );

    _ordenesController = OrdenesController(
      CreateOrdenUsecase(adminRepository),
    );


    _router = AppRouter.createRouter(_authController);
    //_inicializarClientes();
  }

  Future<void> _inicializarClientes() async {
    final existenOrdenes = await _tareaChecklistService.getAllTareas();
    if (!existenOrdenes.isNotEmpty) {
      await _tareaChecklistService.registrarTareasChecklist();
    } else {
      print('Órdenes ya existen en la base de datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _authController),
        ChangeNotifierProvider<PersonaController>.value(value: _personaController),
        ChangeNotifierProvider<OrdenesController>.value(value: _ordenesController),
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
