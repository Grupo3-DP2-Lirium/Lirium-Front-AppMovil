import 'package:dio/dio.dart';
import '../../config/api_constants.dart';
import 'storage_service.dart';

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
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si recibimos 401, el token expiró o es inválido
    if (err.response?.statusCode == 401) {
      await StorageService.deleteToken();
    }

    super.onError(err, handler);
  }
}