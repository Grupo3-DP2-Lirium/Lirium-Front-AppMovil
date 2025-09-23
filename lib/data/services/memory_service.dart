import 'dart:convert';
import 'dart:io';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../models/memory_response.dart';

class MemoryService {
  final http.Client _client;
  MemoryService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<PageMemoryResponse> listMemories({
    required String token,           // solo el JWT sin 'Bearer '
    required String memorialId,
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/memories?memorialId=$memorialId&page=$page&size=$size',
    );

    final res = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return PageMemoryResponse.fromJson(map);
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

}
