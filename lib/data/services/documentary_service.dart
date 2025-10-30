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

  /// Crear un nuevo documental
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
      print('DEBUG: createDocumentary response - Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonMap = jsonDecode(res.body);
        final data = jsonMap['data'];
        return DocumentaryModel.fromJson(data);
      } else {
        throw Exception(
          'Error creando documental: ${res.statusCode} ${res.body}',
        );
      }
    } finally {
      onLoading?.call(false);
    }
  }

  /// Obtener estado de un documental específico
  Future<DocumentaryModel> getDocumentaryStatus(String documentaryId) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId');

    print('DEBUG: Getting documentary status - URI: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: getDocumentaryStatus response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return DocumentaryModel.fromJson(data);
    } else {
      throw Exception(
        'Error obteniendo estado: ${res.statusCode} ${res.body}',
      );
    }
  }

  /// Obtener documentales de un memorial
  Future<List<DocumentaryModel>> getDocumentariesByMemorial(
      String memorialId,
      ) async {
    final uri = Uri.parse('$baseUrl/documentaries/memorial/$memorialId');

    print('DEBUG: Getting documentaries by memorial - URI: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: getDocumentariesByMemorial response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data
          .map((json) => DocumentaryModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error obteniendo documentales: ${res.statusCode} ${res.body}',
      );
    }
  }

  /// Obtener todos los documentales del usuario
  Future<List<DocumentaryModel>> getMyDocumentaries() async {
    final uri = Uri.parse('$baseUrl/documentaries/my-documentaries');

    print('DEBUG: Getting my documentaries - URI: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: getMyDocumentaries response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data
          .map((json) => DocumentaryModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error obteniendo mis documentales: ${res.statusCode} ${res.body}',
      );
    }
  }

  /// Cancelar un documental en proceso
  Future<void> cancelDocumentary(String documentaryId) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId/cancel');

    print('DEBUG: Cancelling documentary - URI: $uri');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: cancelDocumentary response - Status: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw Exception(
        'Error cancelando documental: ${res.statusCode} ${res.body}',
      );
    }
  }

  /// Eliminar un documental
  Future<void> deleteDocumentary(String documentaryId) async {
    final uri = Uri.parse('$baseUrl/documentaries/$documentaryId');

    print('DEBUG: Deleting documentary - URI: $uri');

    final res = await _client.delete(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: deleteDocumentary response - Status: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw Exception(
        'Error eliminando documental: ${res.statusCode} ${res.body}',
      );
    }
  }

  /// Obtener catálogo de música
  Future<List<MusicTrackModel>> getMusicCatalog() async {
    final uri = Uri.parse('$baseUrl/documentaries/music-catalog');

    print('DEBUG: Getting music catalog - URI: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: getMusicCatalog response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data
          .map((json) => MusicTrackModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error obteniendo catálogo de música: ${res.statusCode} ${res.body}',
      );
    }
  }
}