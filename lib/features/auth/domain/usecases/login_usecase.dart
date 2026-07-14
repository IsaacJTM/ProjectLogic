import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserEntity> call({required String email, required String password}) {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Correo y contraseña son obligatorios');
    }
    return repository.login(email: email, password: password);
  }
}
