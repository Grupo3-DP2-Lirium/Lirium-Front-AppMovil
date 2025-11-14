import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/api_constants.dart';
import 'storage_service.dart';
import 'auth_event_service.dart';

/// Cliente HTTP configurado con interceptores automáticos
class HttpClient {
  static Dio? _instance;

  /// Obtiene la instancia singleton del cliente HTTP
  static Dio get instance {
    _instance ??= _createDioInstance();
    return _instance!;
  }

  /// Crea una nueva instancia de Dio configurada
  static Dio _createDioInstance() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Agregar interceptores
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      logPrint: (obj) => print(obj),
    ));

    return dio;
  }

  /// Reinicia la instancia (útil para testing)
  static void resetInstance() {
    _instance = null;
  }
}

/// Interceptor que agrega automáticamente el token a las peticiones
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obtener token del storage seguro
    final token = await StorageService.getToken();

    if (token != null && token.isNotEmpty) {
      // Agregar automáticamente a TODAS las peticiones
      options.headers['Authorization'] = 'Bearer $token';
      print('🔐 Token agregado a petición: ${token.substring(0, 20)}...');
    } else {
      print('⚠️ No hay token disponible para la petición');
    }

    print('📍 Petición: ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('❌ HTTP Error: ${err.response?.statusCode}');
    print('❌ Response data: ${err.response?.data}');
    
    // Si recibimos 401, el token expiró o es inválido
    if (err.response?.statusCode == 401) {
      print('🔓 Token expirado - Limpiando datos');
      await StorageService.deleteToken();
      AuthEventService().emit(AuthEvent.tokenExpired);
      super.onError(err, handler);
      return;
    }
    
    // Si recibimos 403 con error ACCOUNT_SUSPENDED, cerrar sesión
    if (err.response?.statusCode == 403) {
      print('🚫 Recibido 403 - Verificando si es cuenta suspendida');
      final data = err.response?.data;
      print('🔍 Data type: ${data.runtimeType}');
      print('🔍 Data content: $data');
      
      // Intentar parsear si es String
      dynamic parsedData = data;
      if (data is String) {
        try {
          parsedData = json.decode(data);
          print('🔍 Data parseada: $parsedData');
        } catch (e) {
          print('⚠️ No se pudo parsear data como JSON');
        }
      }
      
      if (parsedData is Map && parsedData['error'] == 'ACCOUNT_SUSPENDED') {
        print('🚫 CONFIRMADO: Cuenta suspendida - Cerrando sesión automáticamente');
        await StorageService.deleteToken();
        await StorageService.deletePlan();
        await StorageService.deletePermissions();
        print('📤 Emitiendo evento accountSuspended');
        // Emitir evento para que la UI reaccione
        AuthEventService().emit(AuthEvent.accountSuspended);
        // NO pasar el error adelante, solo emitir el evento
        return;
      } else {
        print('⚠️ 403 pero NO es cuenta suspendida');
        print('⚠️ parsedData type: ${parsedData.runtimeType}');
        if (parsedData is Map) {
          print('⚠️ error key: ${parsedData['error']}');
        }
      }
    }

    super.onError(err, handler);
  }
}