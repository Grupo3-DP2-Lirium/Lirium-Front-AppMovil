import 'package:flutter_frontend/data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  /// Hace login y retorna el token JWT
  Future<String> login({
    required String email,
    required String password,
  }) async {
    return await _authService.login(email: email, password: password);
  }

}
