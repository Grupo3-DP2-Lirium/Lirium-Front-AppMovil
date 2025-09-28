import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/auth_state.dart';
import '../data/services/auth_service.dart';
import '../data/services/storage_service.dart';

/// Provider del servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider principal de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.read(authServiceProvider);
  return AuthNotifier(service);
});

/// Notifier que maneja estado de autenticación con persistencia
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial()) {
    _initializeAuth();
  }

  /// Inicializa el estado verificando token guardado
  Future<void> _initializeAuth() async {
    state = AuthState.loading();

    try {
      final isAuthenticated = await _authService.isAuthenticated();
      final token = await StorageService.getToken();

      if (isAuthenticated && token != null) {
        state = AuthState.authenticated(token);
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      state = AuthState.error('Error al verificar sesión');
    }
  }

  /// Realiza login con credenciales
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();

    try {
      final token = await _authService.login(
        email: email,
        password: password,
      );

      state = AuthState.authenticated(token);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.initial();
  }

  /// Limpia errores
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

