import 'package:dio/dio.dart';
import 'http_client.dart';
import 'storage_service.dart';
import '../models/register_request.dart';

/// Servicio de autenticación con Dio y almacenamiento seguro
class AuthService {
  final Dio _client = HttpClient.instance;

  /// Realiza login y guarda token automáticamente
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      //print("Respuesta login: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        final token = data['token'] as String;
        final plan = data['plan'] ?? 'FREE';
        final permissions = List<String>.from(data['permissions'] ?? []);

        print("Token recibido: $token");
        print("Plan recibido del back: $plan");
        print("Permisos recibidos: $permissions");

        // Guardar automáticamente en storage seguro
        await StorageService.saveToken(token);
        await StorageService.savePlan(plan);
        await StorageService.savePermissions(permissions);

        //print("Plan guardado en storage: ${await StorageService.getPlan()}");
        //print("Permisos guardados en storage: ${await StorageService.getPermissions()}");

        return token;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Cierra sesión eliminando el token
  Future<void> logout() async {
    await StorageService.deleteToken();
  }

  /// Registro de nuevo usuario
  Future<Map<String, dynamic>> register(RegisterRequest registerRequest) async {
    try {
      final response = await _client.post('/auth/register', data: registerRequest.toJson());

      if (response.statusCode == 201) {
        // El backend devuelve los datos del usuario creado
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Verifica si hay una sesión activa válida
  Future<bool> isAuthenticated() async {
    return await StorageService.hasValidToken();
  }

  /// Obtiene información del usuario actual
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await StorageService.getUserFromToken();
  }

  /// Maneja errores de Dio de forma centralizada
  void _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        throw Exception('Datos inválidos');
      case 401:
        throw Exception('Credenciales incorrectas');
      case 404:
        throw Exception('Usuario no encontrado');
      case 409:
        throw Exception('Email ya está registrado');
      case 500:
        throw Exception('Error del servidor');
      default:
        throw Exception('Error de conexión: ${e.message}');
    }
  }
}
