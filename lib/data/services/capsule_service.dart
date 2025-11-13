import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/models/capsule_model.dart';
import 'package:flutter_frontend/data/models/capsule_request.dart';
import 'package:flutter_frontend/data/models/capsule_filter_model.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:http/http.dart' as http;

class CapsuleService {
  final http.Client _client;
  final HttpService _http;
  final String baseUrl = ApiConstants.baseUrl;

  CapsuleService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  /// Crear una nueva cápsula (DRAFT)
  Future<CapsuleModel> createCapsule(
      CapsuleRequestModel request, {
        void Function(bool isLoading)? onLoading,
      }) async {
    final uri = Uri.parse('$baseUrl/capsules');

    onLoading?.call(true);

    try {
      print('DEBUG: Creating capsule - URI: $uri');

      final res = await _client.post(
        uri,
        headers: _http.authHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('DEBUG: createCapsule response - Status: ${res.statusCode}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonMap = jsonDecode(res.body);
        final data = jsonMap['data'];
        return CapsuleModel.fromJson(data);
      } else {
        throw Exception('Error creando cápsula: ${res.statusCode}');
      }
    } finally {
      onLoading?.call(false);
    }
  }

  /// Iniciar generación de la cápsula
  Future<CapsuleModel> generateCapsule(String capsuleId) async {
    final uri = Uri.parse('$baseUrl/capsules/$capsuleId/generate');

    print('DEBUG: Generating capsule - URI: $uri');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: generateCapsule response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return CapsuleModel.fromJson(data);
    } else {
      throw Exception('Error generando cápsula: ${res.statusCode}');
    }
  }

  /// Publicar cápsula
  Future<CapsuleModel> publishCapsule(String capsuleId) async {
    final uri = Uri.parse('$baseUrl/capsules/$capsuleId/publish');

    print('DEBUG: Publishing capsule - URI: $uri');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: publishCapsule response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return CapsuleModel.fromJson(data);
    } else {
      throw Exception('Error publicando cápsula: ${res.statusCode}');
    }
  }

  /// Actualizar cápsula
  Future<CapsuleModel> updateCapsule(
      String capsuleId,
      CapsuleRequestModel request,
      ) async {
    final uri = Uri.parse('$baseUrl/capsules/$capsuleId');

    print('DEBUG: Updating capsule - URI: $uri');

    final res = await _client.put(
      uri,
      headers: _http.authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    print('DEBUG: updateCapsule response - Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return CapsuleModel.fromJson(data);
    } else {
      throw Exception('Error actualizando cápsula: ${res.statusCode}');
    }
  }

  /// Obtener estado de una cápsula específica
  Future<CapsuleModel> getCapsuleStatus(String capsuleId) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final uri = Uri.parse('$baseUrl/capsules/$capsuleId?_=$ts');

    final headers = {
      ..._http.authHeaders(),
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    };

    final res = await _client.get(uri, headers: headers);

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final data = jsonMap['data'];
      return CapsuleModel.fromJson(data);
    } else {
      throw Exception('Error obteniendo estado: ${res.statusCode}');
    }
  }

  /// Obtener todas las cápsulas del usuario
  Future<List<CapsuleModel>> getMyCapsules() async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final uri = Uri.parse('$baseUrl/capsules/my-capsules?_=$ts');

    final headers = {
      ..._http.authHeaders(),
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    };

    final res = await _client.get(uri, headers: headers);

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data.map((json) => CapsuleModel.fromJson(json)).toList();
    } else {
      throw Exception('Error obteniendo mis cápsulas: ${res.statusCode}');
    }
  }

  /// Obtener cápsulas por estado
  Future<List<CapsuleModel>> getCapsulesByStatus(
      String memorialId,
      String status,
      ) async {
    final uri = Uri.parse(
        '$baseUrl/capsules/memorial/$memorialId/by-status?status=$status');

    print('DEBUG: Getting capsules by status - URI: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data.map((json) => CapsuleModel.fromJson(json)).toList();
    } else {
      throw Exception('Error obteniendo cápsulas: ${res.statusCode}');
    }
  }

  /// Cancelar una cápsula en proceso
  Future<void> cancelCapsule(String capsuleId) async {
    final uri = Uri.parse('$baseUrl/capsules/$capsuleId/cancel');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error cancelando cápsula: ${res.statusCode}');
    }
  }

  /// Eliminar una cápsula
  Future<void> deleteCapsule(String capsuleId) async {
    final uri = Uri.parse('$baseUrl/capsules/$capsuleId');

    final res = await _client.delete(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception('Error eliminando cápsula: ${res.statusCode}');
    }
  }

  /// Obtener catálogo de filtros
  Future<List<CapsuleFilterModel>> getFilters() async {
    final uri = Uri.parse('$baseUrl/capsules/filters');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body);
      final List<dynamic> data = jsonMap['data'];
      return data.map((json) => CapsuleFilterModel.fromJson(json)).toList();
    } else {
      throw Exception('Error obteniendo filtros: ${res.statusCode}');
    }
  }
}