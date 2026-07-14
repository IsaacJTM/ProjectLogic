import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteApi remoteApi;
  AuthRepositoryImpl(this.remoteApi);

  @override
  Future<UserEntity> login({required String email, required String password}) {
    return remoteApi.login(email: email, password: password);
  }

  @override
  Future<void> logout() async {}
}
