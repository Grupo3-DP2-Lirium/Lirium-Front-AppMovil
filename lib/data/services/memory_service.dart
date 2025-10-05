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
  Future<List<Memory>> listMemoriesByAuthor() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/memories/my-memories');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false), // Authorization + Accept
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final listJson = jsonDecode(res.body) as List<dynamic>;
      // Mapear MemoryResponse a Memory
      return listJson
          .map((e) => MemoryResponse.fromJson(e).toEntity())
          .toList();
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
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

}
