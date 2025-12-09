import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reflection_model.dart';
import '../../config/api_constants.dart';
import '../services/http_service.dart';

class ReflectionApiService {
  final HttpService _httpService = HttpService();

  // Obtener todas las reflexiones del usuario con paginación
  Future<List<ReflectionModel>> getReflections({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _httpService.get(
        '${ApiConstants.reflections}?page=$page&size=$size',
      );
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        List<dynamic> reflectionsJson;
        
        // El backend devuelve: {"success": true, "data": {"content": [...]}}
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final data = responseData['data'] as Map<String, dynamic>;
          if (data.containsKey('content')) {
            reflectionsJson = data['content'] as List<dynamic>;
          } else {
            reflectionsJson = [];
          }
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('content')) {
          // Fallback: si 'content' está en el nivel superior
          reflectionsJson = responseData['content'] as List<dynamic>;
        } else if (responseData is List) {
          // Fallback: si es una lista directa
          reflectionsJson = responseData;
        } else {
          return [];
        }
        
        return reflectionsJson
            .map((json) => ReflectionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtener una reflexión específica por ID
  Future<ReflectionModel?> getReflection(String id) async {
    try {
      final response = await _httpService.get('${ApiConstants.reflections}/$id');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ReflectionModel.fromJson(responseData);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Crear una nueva reflexión
  Future<ReflectionModel?> createReflection({
    required String title,
    required String content,
    double? latitude,
    double? longitude,
    List<File>? files,
  }) async {
    try {
      // Preparar los datos de la reflexión como JSON
      Map<String, dynamic> reflectionData = {
        'title': title,
        'description': content,
        'type': 'REFLECTION',
        'visible': true,
        // Omitir photoDate temporalmente - no hay campo en frontend para seleccionar fecha
      };
      
      // Coordenadas si están disponibles
      if (latitude != null && longitude != null) {
        reflectionData['latitude'] = latitude;
        reflectionData['longitude'] = longitude;
      }
      
      Map<String, String> fields = {
        'reflection': json.encode(reflectionData), // Enviar datos como JSON en campo 'reflection'
      };
      
      List<http.MultipartFile> multipartFiles = [];
      
      // Archivos multimedia
      if (files != null && files.isNotEmpty) {
        for (File file in files) {
          final fileName = file.path.split('/').last;
          final multipartFile = await http.MultipartFile.fromPath(
            'files',
            file.path,
            filename: fileName,
          );
          multipartFiles.add(multipartFile);
        }
      }

      final response = await _httpService.postMultipart(
        ApiConstants.reflections,
        fields,
        multipartFiles,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ReflectionModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Actualizar una reflexión existente
  Future<ReflectionModel?> updateReflection({
    required String id,
    String? title,
    String? content,
    double? latitude,
    double? longitude,
    List<File>? newFiles,
    List<String>? filesToDelete,
  }) async {
    try {
      // Preparar los datos de la reflexión como JSON
      Map<String, dynamic> reflectionData = {
        'type': 'REFLECTION',
        'visible': true,
      };
      
      // Solo agregar campos que han sido modificados
      if (title != null) {
        reflectionData['title'] = title;
      }
      if (content != null) {
        reflectionData['description'] = content;
      }
      if (latitude != null && longitude != null) {
        reflectionData['latitude'] = latitude;
        reflectionData['longitude'] = longitude;
      }
      
      Map<String, String> fields = {
        'reflection': json.encode(reflectionData), // Datos como JSON
      };
      
      // Archivos a eliminar
      if (filesToDelete != null && filesToDelete.isNotEmpty) {
        fields['filesToDelete'] = json.encode(filesToDelete);
      }
      
      List<http.MultipartFile> multipartFiles = [];
      
      // Nuevos archivos
      if (newFiles != null && newFiles.isNotEmpty) {
        for (File file in newFiles) {
          final fileName = file.path.split('/').last;
          final multipartFile = await http.MultipartFile.fromPath(
            'files',
            file.path,
            filename: fileName,
          );
          multipartFiles.add(multipartFile);
        }
      }

      final response = await _httpService.putMultipart(
        '${ApiConstants.reflections}/$id',
        fields,
        multipartFiles,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ReflectionModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Eliminar una reflexión
  Future<bool> deleteReflection(String id) async {
    try {
      final response = await _httpService.delete('${ApiConstants.reflections}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // Buscar reflexiones por contenido
  Future<List<ReflectionModel>> searchReflections({
    required String query,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _httpService.get(
        '${ApiConstants.reflectionSearch}?query=$query&page=$page&size=$size',
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> reflectionsJson = responseData['content'] ?? responseData;
        return reflectionsJson
            .map((json) => ReflectionModel.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      final response = await _httpService.get(ApiConstants.reflectionStats);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtener reflexiones por categoría
  Future<List<ReflectionModel>> getReflectionsByCategory({
    required String category,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _httpService.get(
        '${ApiConstants.reflections}/category/$category?page=$page&size=$size',
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> reflectionsJson = responseData['content'] ?? responseData;
        return reflectionsJson
            .map((json) => ReflectionModel.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Descargar archivo de reflexión
  Future<String?> downloadReflectionFile(String downloadUrl, String fileName) async {
    try {
      // Usar el HttpService para descargar el archivo
      final response = await _httpService.downloadFile(downloadUrl, fileName);
      return response; // Devuelve la ruta local del archivo descargado
    } catch (e) {
      return null;
    }
  }

}