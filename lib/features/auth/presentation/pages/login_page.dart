import 'package:flutter/material.dart';
import 'package:logistics_pro/features/admin/presentation/widgets/persona_card_widget.dart';
import 'package:provider/provider.dart';

import '../../data/datasources/auth_remote_api.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/login_usecase.dart';
import '../controllers/auth_controller.dart';
import 'admin_home_page.dart';
import '../../../logistics/presentation/pages/logistics_dashboard_page.dart';

/// Login único que redirige por rol: técnico -> dashboard de logística,
/// administrador -> panel de creación/asignación de órdenes.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AuthRepositoryImpl(AuthRemoteApi());

    return ChangeNotifierProvider(
      create: (_) => AuthController(loginUseCase: LoginUseCase(repository)),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<AuthController>();
    if (_controller != controller) {
      _controller?.removeListener(_onAuthChanged);
      _controller = controller;
      _controller!.addListener(_onAuthChanged);
    }
  }

  void _onAuthChanged() {
    final state = _controller!;
    if (state.status == AuthStatus.authenticated && state.user != null) {
      final destination = state.user!.role == UserRole.admin
          //? const AdminHomePage()
          ? const PersonaCardWidget()
          : const LogisticsDashboardPage(orderId: '8492');

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
    }
    if (state.status == AuthStatus.error && state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      state.consumeError();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthController>(
        builder: (context, state, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Logistics Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildField(
                      _emailController,
                      'Correo electrónico',
                      Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      _passwordController,
                      'Contraseña',
                      Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E40AF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: state.status == AuthStatus.loading
                            ? null
                            : () => context.read<AuthController>().login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              ),
                        child: state.status == AuthStatus.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Ingresar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Técnico: worker@demo.com   |   Admin: admin@demo.com',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
