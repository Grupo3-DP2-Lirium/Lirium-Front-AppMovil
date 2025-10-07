import 'dart:io';
import 'package:dio/dio.dart';
import 'http_client.dart';

/// Servicio para mejora de imágenes usando el microservicio ML
class ImageService {
  final Dio _client = HttpClient.instance;

  /// Mejora una imagen enviándola al backend
  /// Retorna los bytes de la imagen mejorada
  Future<List<int>> enhanceImage(File imageFile) async {
    try {
      // Crear FormData con la imagen
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Hacer petición al backend
      final response = await _client.post(
        '/image-enhancer/enhance',
        data: formData,
        options: Options(
          responseType: ResponseType.bytes, // Recibir bytes de la imagen
          receiveTimeout: const Duration(minutes: 2), // Timeout extendido para ML
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception('Error enhancing image: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Verifica el estado del servicio ML
  Future<bool> checkHealth() async {
    try {
      final response = await _client.get('/image-enhancer/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Maneja errores de Dio de forma centralizada
  void _handleDioError(DioException e) {
    if (e.response != null) {
      switch (e.response?.statusCode) {
        case 400:
          throw Exception('Imagen inválida o no proporcionada');
        case 413:
          throw Exception('La imagen es demasiado grande');
        case 503:
          throw Exception('Servicio de mejora no disponible');
        case 500:
          throw Exception('Error del servidor al procesar la imagen');
        default:
          throw Exception('Error ${e.response?.statusCode}: ${e.message}');
      }
    } else {
      throw Exception('Error de conexión: ${e.message}');
    }
  }
}