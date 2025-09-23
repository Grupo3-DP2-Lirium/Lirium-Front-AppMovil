import 'package:flutter_frontend/data/repositories/auth_repository.dart';
import 'package:flutter_frontend/data/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1. Provider del service (depende de http client o config)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// 2. Provider del repository (usa el service)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.read(authServiceProvider);
  return AuthRepository(service);
});

/// 3. Estado de auth: AsyncValue<String> = token o error
final authProvider =
StateNotifierProvider<AuthNotifier, AsyncValue<String?>>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(repo);
});

/// 4. Notifier que maneja el login/logout
class AuthNotifier extends StateNotifier<AsyncValue<String?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final token = await _repository.login(
        email: email,
        password: password,
      );
      state = AsyncValue.data(token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

