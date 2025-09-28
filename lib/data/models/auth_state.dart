/// Estado de autenticación inmutable
class AuthState {
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  /// Crea una copia con valores modificados
  AuthState copyWith({
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  /// Estado inicial sin autenticación
  factory AuthState.initial() => const AuthState();

  /// Estado de carga
  factory AuthState.loading() => const AuthState(isLoading: true);

  /// Estado autenticado
  factory AuthState.authenticated(String token) {
    return AuthState(
      token: token,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  /// Estado de error
  factory AuthState.error(String message) {
    return AuthState(
      error: message,
      isLoading: false,
      isAuthenticated: false,
    );
  }
}