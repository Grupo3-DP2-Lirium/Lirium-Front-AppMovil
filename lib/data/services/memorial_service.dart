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
      String? imagePath, {
        void Function(bool isLoading)? onLoading,
      }) async {
    final uri = Uri.parse("$baseUrl/memorials/create");

    // Indicar que empieza la carga
    onLoading?.call(true);

    try {
      // GET previo para obtener headers con token
      final res = await _client.get(
        uri,
        headers: _http.authHeaders(includeJson: false),
      );

      final requestMultipart = http.MultipartRequest("POST", uri)
        ..headers.addAll(_http.authHeaders(includeJson: true))
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
    } finally {
      // Indicar que terminó la carga
      onLoading?.call(false);
    }
  }

  /// Obtener memoriales colaborativos
  Future<List<Memorial>> getCollaborativeMemorials() async {
    print('DEBUG: getCollaborativeMemorials() called');
    try {
      print('DEBUG: Making request to collaborative memorials endpoint');
      final response = await _http.get(ApiConstants.getCollaborativeMemorials);

      print('DEBUG: Collaborative memorials response - Status: ${response.statusCode}');
      print('DEBUG: Collaborative memorials response - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final memorials = data
            .map((json) => MemorialResponseModel.fromJson(json).toEntity())
            .toList();
        print('DEBUG: Parsed ${memorials.length} collaborative memorials from response');
        return memorials;
      } else {
        throw Exception('Failed to load collaborative memorials (${response.statusCode})');
      }
    } catch (e) {
      print('ERROR in getCollaborativeMemorials: $e');
      throw Exception('Error: $e');
    }
  }

 Future<List<Memorial>> getMyCollaborations() async {
    print('📡 Obteniendo mis colaboraciones...');
    
    try {
      final response = await _http.get(ApiConstants.getMyCollaborations);
      
      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Manejar respuesta vacía
        if (response.body.isEmpty || response.body == 'null') {
          print('✅ No hay colaboraciones (respuesta vacía)');
          return [];
        }

        final dynamic decoded = json.decode(response.body);

        // Si es null o no es lista, retornar vacío
        if (decoded == null || decoded is! List) {
          print('⚠️ Respuesta no es lista: ${decoded.runtimeType}');
          return [];
        }

        // Si la lista está vacía
        if (decoded.isEmpty) {
          print('✅ No hay colaboraciones (lista vacía)');
          return [];
        }

        // Parsear lista usando MemorialResponseModel → Memorial
        final collaborations = decoded
            .map((json) => MemorialResponseModel.fromJson(json).toEntity())
            .toList();

        print('✅ Colaboraciones cargadas: ${collaborations.length}');

        return collaborations;

      } else if (response.statusCode == 404) {
        print('⚠️ No se encontraron colaboraciones');
        return [];
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
        throw Exception('Error al cargar colaboraciones: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getMyCollaborations: $e');

      // Si es error de conexión o parsing, re-lanzar
      if (e.toString().contains('FormatException') || 
          e.toString().contains('SocketException')) {
        rethrow;
      }

      // Para otros errores, retornar lista vacía
      return [];
    }
  }

  /// Listar memoriales
  Future<List<Memorial>> getMemorials() async {
    print('DEBUG: getMemorials() called');
    final uri = Uri.parse("$baseUrl/memorials/getMemorials");
    print('DEBUG: Making request to: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(), // aquí ya incluyes token y JSON
    );

    print('DEBUG: getMemorials response - Status: ${res.statusCode}, Body: ${res.body}');
    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      final memorials = jsonList
          .map((json) => MemorialResponseModel.fromJson(json).toEntity())
          .toList();
      print('DEBUG: Parsed ${memorials.length} memorials from response');
      return memorials;
    } else {
      throw Exception(
        "Error listando memorials: ${res.statusCode} ${res.body}",
      );
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

  /// Obtener un memorial por ID
  Future<MemorialResponseModel> getMemorialById(String memorialId) async {
    print('DEBUG: getMemorialById($memorialId) called');
    final uri = Uri.parse("$baseUrl/memorials/$memorialId");
    print('DEBUG: Making request to: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: getMemorialById response - Status: ${res.statusCode}, Body: ${res.body}');
    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(res.body);
      return MemorialResponseModel.fromJson(jsonMap);
    } else {
      throw Exception(
        "Error obteniendo memorial: ${res.statusCode} ${res.body}",
      );
    }
  }

  /// Actualizar un memorial con o sin imagen
  Future<Memorial> updateMemorial(
      String memorialId,
      MemorialRequestModel request,
      String? imagePath,
      ) async {
    final uri = Uri.parse("$baseUrl/memorials/$memorialId");
    print('DEBUG: updateMemorial($memorialId) called');
    print('DEBUG: Making request to: $uri');

    final requestMultipart = http.MultipartRequest("PUT", uri)
      ..headers.addAll(_http.authHeaders(includeJson: true))
      ..fields['memorial'] = jsonEncode(request.toJson());

    if (imagePath != null) {
      requestMultipart.files.add(await http.MultipartFile.fromPath("file", imagePath));
    }

    final streamedResponse = await requestMultipart.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('DEBUG: updateMemorial response - Status: ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body);
      return MemorialResponseModel.fromJson(jsonMap).toEntity();
    } else {
      throw Exception(
          "Error actualizando memorial: ${response.statusCode} ${response.body}"
      );
    }
  }

  /// Eliminar un memorial por ID
  Future<void> deleteMemorial(String memorialId) async {
    print('DEBUG: deleteMemorial($memorialId) called');
    final uri = Uri.parse("$baseUrl/memorials/$memorialId");
    print('DEBUG: Making DELETE request to: $uri');

    final res = await _client.delete(
      uri,
      headers: _http.authHeaders(), // incluye token
    );

    print('DEBUG: deleteMemorial response - Status: ${res.statusCode}, Body: ${res.body}');
    if (res.statusCode == 200 || res.statusCode == 204) {
      print('DEBUG: Memorial $memorialId deleted successfully');
    } else {
      throw Exception(
        "Error eliminando memorial: ${res.statusCode} ${res.body}",
      );
    }
  }

  /// Generar Link de Compartir
  Future<Map<String, dynamic>> generateShareLink(String memorialId) async {
    print('DEBUG: generateShareLink($memorialId) called');
    final uri = Uri.parse("$baseUrl/memorials/$memorialId/share");
    print('DEBUG: Making POST request to: $uri');
    final res = await _client.post(
      uri,
      headers: _http.authHeaders(),
    );
    print('DEBUG: generateShareLink response - Status: ${res.statusCode}, Body: ${res.body}');
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception(
        "Error generando link de compartir: ${res.statusCode} ${res.body}",
      );
    }
  }
}
