import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/models/documentary_model.dart';
import 'package:flutter_frontend/data/models/documentary_request.dart';
import 'package:flutter_frontend/data/models/music_track_model.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:http/http.dart' as http;

class DocumentaryService {
  final http.Client _client;
  final HttpService _http;
  final String baseUrl = ApiConstants.baseUrl;

  DocumentaryService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  /// ✨ NUEVO: Validar si memorial tiene suficientes recuerdos
  Future<Map<String, dynamic>> validateMemorial(String memorialId) async {
    final uri = Uri.parse('$baseUrl/documentaries/validate-memorial/$memorialId');

    print('DEBUG: Validating memorial - URI: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: validateMemorial response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      return jsonMap['data'];
    } else {
      throw Exception('Error validando memorial: ${res.statusCode}');
    }
  }

  /// Crear un nuevo documental (ahora crea en DRAFT)
  Future<DocumentaryModel> createDocumentary(
      DocumentaryRequestModel request, {
        void Function(bool isLoading)? onLoading,
      }) async {
    final uri = Uri.parse('$baseUrl/documentaries');

    onLoading?.call(true);

    try {
      print('DEBUG: Creating documentary - URI: $uri');

      final res = await _client.post(
        uri,
        headers: _http.authHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('DEBUG: createDocumentary response - Status: ${res.statusCode}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonMap = jsonDecode(res.body);
        final data = jsonMap['data'];
        return DocumentaryModel.fromJson(data);
      } else {
        throw Exception('Error creando documental: ${res.statusCode}');
      }
    } finally {
      onLoading?.call(false);
    }
  }

  /// ✨ NUEVO: Iniciar generación del video
  Future<DocumentaryModel> generateDocumentary(String documentaryId) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId/generate');

    print('DEBUG: Generating documentary - URI: $uri');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: generateDocumentary response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return DocumentaryModel.fromJson(data);
    } else {
      throw Exception('Error generando documental: ${res.statusCode}');
    }
  }

  /// ✨ NUEVO: Publicar documental
  Future<DocumentaryModel> publishDocumentary(String documentaryId) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId/publish');

    print('DEBUG: Publishing documentary - URI: $uri');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: publishDocumentary response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return DocumentaryModel.fromJson(data);
    } else {
      throw Exception('Error publicando documental: ${res.statusCode}');
    }
  }

  /// ✨ NUEVO: Actualizar documental
  Future<DocumentaryModel> updateDocumentary(
      String documentaryId,
      DocumentaryRequestModel request,
      ) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId');

    print('DEBUG: Updating documentary - URI: $uri');

    final res = await _client.put(
      uri,
      headers: _http.authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    print('DEBUG: updateDocumentary response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return DocumentaryModel.fromJson(data);
    } else {
      throw Exception('Error actualizando documental: ${res.statusCode}');
    }
  }

  /// ✨ NUEVO: Obtener documentales por estado
  Future<List<DocumentaryModel>> getDocumentariesByStatus(
      String memorialId,
      String status,
      ) async {
    final uri = Uri.parse(
        '$baseUrl/documentaries/memorial/$memorialId/by-status?status=$status');

    print('DEBUG: Getting documentaries by status - URI: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data.map((json) => DocumentaryModel.fromJson(json)).toList();
    } else {
      throw Exception('Error obteniendo documentales: ${res.statusCode}');
    }
  }

  /// Obtener estado de un documental específico
  Future<DocumentaryModel> getDocumentaryStatus(String documentaryId) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return DocumentaryModel.fromJson(data);
    } else {
      throw Exception('Error obteniendo estado: ${res.statusCode}');
    }
  }

  /// Obtener todos los documentales del usuario
  Future<List<DocumentaryModel>> getMyDocumentaries() async {
    final uri = Uri.parse('$baseUrl/documentaries/my-documentaries');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data.map((json) => DocumentaryModel.fromJson(json)).toList();
    } else {
      throw Exception('Error obteniendo mis documentales: ${res.statusCode}');
    }
  }

  /// Cancelar un documental en proceso
  Future<void> cancelDocumentary(String documentaryId) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId/cancel');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error cancelando documental: ${res.statusCode}');
    }
  }

  /// Eliminar un documental
  Future<void> deleteDocumentary(String documentaryId) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId');

    final res = await _client.delete(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error eliminando documental: ${res.statusCode}');
    }
  }

  /// Obtener catálogo de música
  Future<List<MusicTrackModel>> getMusicCatalog() async {
    final uri = Uri.parse('$baseUrl/documentaries/music-catalog');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data.map((json) => MusicTrackModel.fromJson(json)).toList();
    } else {
      throw Exception('Error obteniendo catálogo de música: ${res.statusCode}');
    }
  }
}