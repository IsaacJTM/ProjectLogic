import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

/// Simula la autenticación contra el backend.
/// Reemplazar por llamadas HTTP reales al endpoint de login.
class AuthRemoteApi {
  Future<UserModel> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 900));

    // 🧪 Mock: los correos que empiezan con "admin" entran como administrador,
    // cualquier otro entra como técnico. Reemplazar por la respuesta real del backend.
    if (email.trim().toLowerCase().startsWith('admin')) {
      return UserModel(id: 'adm-001', name: 'Administrador', email: email, role: UserRole.admin);
    }
    return UserModel(id: 'tech-001', name: 'Técnico de campo', email: email, role: UserRole.worker);
  }
}
