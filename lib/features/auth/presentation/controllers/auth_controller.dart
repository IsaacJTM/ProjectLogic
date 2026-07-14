import 'package:flutter/foundation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthController({required this.loginUseCase});

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<void> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final user = await loginUseCase(email: email, password: password);
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'No se pudo iniciar sesión: $e';
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _status = AuthStatus.initial;
    notifyListeners();
  }

  /// Debe llamarse después de mostrar el mensaje de error para que no
  /// se repita en el próximo build.
  void consumeError() {
    _errorMessage = null;
  }
}
