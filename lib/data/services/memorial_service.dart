import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:http/http.dart' as http;

class MemorialService {
  final http.Client _client;
  final HttpService _http;
  final String baseUrl = ApiConstants.baseUrl;

  MemorialService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  /// Crear un memorial con o sin imagen
  Future<Memorial> createMemorial(
      MemorialRequestModel request,
      String? imagePath,
      ) async {
    final uri = Uri.parse("$baseUrl/memorials/create");

    // Hacemos un GET para obtener los headers con token
    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    final requestMultipart = http.MultipartRequest("POST", uri)
      ..headers.addAll(_http.authHeaders(includeJson: true)) // ahora Authorization + Accept JSON
      ..fields['memorial'] = jsonEncode(request.toJson());

    if (imagePath != null) {
      requestMultipart.files.add(await http.MultipartFile.fromPath("file", imagePath));
    }

    final streamedResponse = await requestMultipart.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body);
      return MemorialResponseModel.fromJson(jsonMap).toEntity();
    } else {
      throw Exception(
          "Error creando memorial: ${response.statusCode} ${response.body}"
      );
    }
  }

  /// Obtener memoriales colaborativos
  Future<List<Memorial>> getCollaborativeMemorials() async {
    try {
      final response = await _http.get(ApiConstants.collaborativeMemorials);

      print('--- Respuesta de /memorials/collaborative ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => MemorialResponseModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception('Failed to load collaborative memorials (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Memorial>> getMyMemorials() async {
    try {
      final response = await _http.get(ApiConstants.memorials);

      print('--- Respuesta de /memorials ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Convertir MemorialResponseModel a Memorial y devolver la lista de Memorial
        return data
            .map((json) => MemorialResponseModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception('Failed to load memorials (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Memorial>> fetchMyMemorials() async {
      await Future.delayed(const Duration(milliseconds: 250));
      return <Memorial>[
       //  Memorial(id: '1', name: 'LUPI'),
       //  Memorial(id: '2', name: 'CARMEN'),
       //  Memorial(id: '3', name: 'BRACO'),
      ];
  }
}
