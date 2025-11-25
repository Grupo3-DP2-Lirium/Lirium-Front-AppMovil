import 'dart:convert';
import 'dart:io';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../models/memory_response.dart';
import '../models/memory_create_request.dart';
import '../models/memories_organized_response.dart';
import '../models/memories_by_type_response.dart';
import '../models/memory_lite_response.dart';
import '../models/paginated_memories.dart';

class MemoryService {
  final http.Client _client;
  final HttpService _http;

  MemoryService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();


  /// Crea una memoria personal con soporte de archivos (imagenes, audio, etc).
  /// [token] = "Bearer <jwt>" (solo el jwt, sin la palabra Bearer, porque aquí lo añadimos).
  Future<Map<String, dynamic>> createPersonalMemory({
    required String token,
    required Map<String, dynamic> memoryJson,
    List<File>? files,
  }) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/memories");
    final req = http.MultipartRequest('POST', uri);

    // Headers (Authorization y Aceptar JSON)
    req.headers['Authorization'] = 'Bearer $token';
    req.headers['Accept'] = 'application/json';

    // Campo 'memory' como string JSON
    req.fields['memory'] = jsonEncode(memoryJson);

    // Adjuntar archivos (si hay)
    if (files != null && files.isNotEmpty) {
      for (final f in files) {
        final mime = lookupMimeType(f.path) ?? 'application/octet-stream';
        final parts = mime.split('/');
        final filePart = await http.MultipartFile.fromPath(
          'files',
          f.path,
          contentType: MediaType(parts.first, parts.last),
          filename: f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : 'upload',
        );
        req.files.add(filePart);
      }
    }

    // Enviar
    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        "Error ${resp.statusCode}: ${resp.body.isEmpty ? 'sin cuerpo' : resp.body}",
      );
    }
  }

  /// Creates a memory with files using MemoryCreateRequest model
  Future<MemoryResponse> createMemory({
    required MemoryCreateRequest request,
    List<File>? files,
  }) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/memories");
    final req = http.MultipartRequest('POST', uri);

    // Headers with auth from HttpService
    req.headers.addAll(_http.authHeaders(includeJson: false));
    req.headers['Accept'] = 'application/json';

    // Memory data as JSON string
    req.fields['memory'] = jsonEncode(request.toJson());

    // Attach files if any
    if (files != null && files.isNotEmpty) {
      print('DEBUG: Attaching ${files.length} files');
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
        final parts = mime.split('/');
        
        print('DEBUG: File - path: ${file.path}, exists: $exists, size: $size, mime: $mime');
        
        final filePart = await http.MultipartFile.fromPath(
          'files', // Changed back to simple 'files' for @RequestParam
          file.path,
          contentType: MediaType(parts.first, parts.last),
          filename: file.uri.pathSegments.isNotEmpty 
              ? file.uri.pathSegments.last 
              : 'upload',
        );
        req.files.add(filePart);
        print('DEBUG: Added file to request: ${filePart.filename}');
      }
    } else {
      print('DEBUG: No files to attach');
    }

    // Send request
    final streamedResponse = await req.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return MemoryResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Error creating memory: ${response.statusCode} ${response.body}');
    }
  }

  Future<PageMemoryResponse> listMemories({ //el token lo saca desde el login
    required String memorialId,
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/memories?memorialId=$memorialId&page=$page&size=$size',
    );

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false), // Authorization + Accept
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return PageMemoryResponse.fromJson(map);
    } else if (res.statusCode == 401) {
      // aquí podrías limpiar sesión y redirigir
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// List Memories from log user
  Future<PaginatedMemories> listMemoriesByAuthor({int page = 0, int size = 4}) async {
    print('DEBUG: getMemories() called');
    final uri = Uri.parse('${ApiConstants.baseUrl}/memories/my-memories?page=$page&size=$size');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);

      final content = (json['content'] as List)
          .map((j) => MemoryResponse.fromJson(j).toEntity())
          .toList();

      return PaginatedMemories(
        items: content,
        page: json['number'],
        totalPages: json['totalPages'],
        totalItems: json['totalElements'],
      );
    } else {
      throw Exception("Error listando memorials");
    }
  }

  Future<Map<String, dynamic>> updateMemory({
    required String memoryId,
    required Map<String, dynamic> memoryJson,
    List<File>? files, // archivos nuevos
    List<Map<String, String>>? filesToDelete, // [{"id": "...", "path": "..."}]
  }) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/memories/$memoryId");
    final req = http.MultipartRequest('PUT', uri);

    // Headers (Authorization + Accept JSON)
    req.headers.addAll(_http.authHeaders());

    // Campo 'memory' como string JSON
    req.fields['memory'] = jsonEncode(memoryJson);

    // Adjuntar archivos nuevos (si hay)
    if (files != null && files.isNotEmpty) {
      for (final f in files) {
        final mime = lookupMimeType(f.path) ?? 'application/octet-stream';
        final parts = mime.split('/');
        final filePart = await http.MultipartFile.fromPath(
          'files', // coincide con @RequestPart("files") en backend
          f.path,
          contentType: MediaType(parts.first, parts.last),
          filename: f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : 'upload',
        );
        req.files.add(filePart);
      }
    }

    // Agregar archivos a eliminar (id + path)
    if (filesToDelete != null && filesToDelete.isNotEmpty) {
      print('Files to delete: $filesToDelete');
      req.fields['filesToDelete'] = jsonEncode(filesToDelete);
    }

    // Enviar
    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        "Error ${resp.statusCode}: ${resp.body.isEmpty ? 'sin cuerpo' : resp.body}",
      );
    }
  }

  // Nuevos métodos para visualizar recuerdos organizados

  Future<MemoriesOrganizedResponse> getMemoriesOrganized({
    required String memorialId,
    String filterType = 'all',
    String sortBy = 'date',
    String sortOrder = 'desc',
    int page = 0,
    int size = 20,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/memories/memorial/$memorialId/organized'
      '?filterType=$filterType&sortBy=$sortBy&sortOrder=$sortOrder&page=$page&size=$size',
    );

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return MemoriesOrganizedResponse.fromJson(map);
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<MemoriesByTypeResponse> getMemoriesByType({
    required String memorialId,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/memories/by-type/$memorialId');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return MemoriesByTypeResponse.fromJson(map);
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> getMemoriesByTimeline({
    required String memorialId,
    String? year,
    String? month,
  }) async {
    String url = '${ApiConstants.baseUrl}/memories/memorial/$memorialId/by-timeline';
    
    List<String> queryParams = [];
    if (year != null) queryParams.add('year=$year');
    if (month != null) queryParams.add('month=$month');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final uri = Uri.parse(url);

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> getMemoriesByThemes({
    required String memorialId,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/memories/memorial/$memorialId/by-themes');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> getMemoriesByMoments({
    required String memorialId,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/memories/memorial/$memorialId/by-moments');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Obtiene memorias agrupadas por categoría y tipo
  /// Retorna: Map<String, Map<String, List<MemoryLiteResponse>>>
  /// Ejemplo: { "Infancia": { "image": [...], "video": [...] }, "Adolescencia": { ... } }
  Future<Map<String, Map<String, List<MemoryLiteResponse>>>> getMemoriesGroupedByCategory({
    required String memorialId,
    int page = 0,
    int size = 100,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/memories/grouped-by-category?memorialId=$memorialId&page=$page&size=$size',
    );

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return _parseGroupedMemories(data);
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Obtiene memorias agrupadas por momento y tipo
  /// Retorna: Map<String, Map<String, List<MemoryLiteResponse>>>
  /// Ejemplo: { "Primer día de escuela": { "image": [...], "video": [...] }, "Graduación": { ... } }
  Future<Map<String, Map<String, List<MemoryLiteResponse>>>> getMemoriesGroupedByMoment({
    required String memorialId,
    int page = 0,
    int size = 100,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/memories/grouped-by-moment?memorialId=$memorialId&page=$page&size=$size',
    );

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return _parseGroupedMemories(data);
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Helper para parsear la estructura anidada de memorias agrupadas
  Map<String, Map<String, List<MemoryLiteResponse>>> _parseGroupedMemories(
    Map<String, dynamic> data,
  ) {
    final result = <String, Map<String, List<MemoryLiteResponse>>>{};

    data.forEach((category, typeMap) {
      if (typeMap is Map<String, dynamic>) {
        final typeResult = <String, List<MemoryLiteResponse>>{};
        
        typeMap.forEach((type, memoriesList) {
          if (memoriesList is List) {
            typeResult[type] = memoriesList
                .map((m) => MemoryLiteResponse.fromJson(m as Map<String, dynamic>))
                .toList();
          }
        });
        
        result[category] = typeResult;
      }
    });

    return result;
  }

  /// Obtiene memorias en formato timeline (línea de tiempo)
  /// Retorna una lista de memorias ordenadas cronológicamente
  Future<List<MemoryResponse>> getTimelineMemories({
    required String memorialId,
    int page = 0,
    int size = 50,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/memories/timeline/$memorialId?page=$page&size=$size',
    );

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final listJson = json.decode(res.body) as List<dynamic>;
      return listJson
          .map((e) => MemoryResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Elimina una memoria por su ID
  Future<void> deleteMemory(String memoryId) async {
    print('DEBUG: deleteMemory($memoryId) called');
    final uri = Uri.parse("${ApiConstants.baseUrl}/memories/$memoryId");
    print('DEBUG: Making DELETE request to: $uri');

    final res = await _client.delete(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: deleteMemory response - Status: ${res.statusCode}');
    
    if (res.statusCode == 200 || res.statusCode == 204) {
      print('DEBUG: Memory deleted successfully');
      return;
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
    } else if (res.statusCode == 403) {
      throw Exception('No tienes permisos para eliminar esta memoria.');
    } else if (res.statusCode == 404) {
      throw Exception('La memoria no existe o ya fue eliminada.');
    } else {
      throw Exception('Error al eliminar memoria: ${res.statusCode} ${res.body}');
    }
  }

}
