import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:http/http.dart' as http;

class MemorialService {
  final String baseUrl;

  MemorialService({this.baseUrl = ApiConstants.baseUrl});

  /// Crear un memorial con o sin imagen
  Future<Memorial> createMemorial(
      MemorialRequestModel request,
      String? imagePath,
      String token,
      ) async {
    final uri = Uri.parse("$baseUrl/memorials/create");

    final requestMultipart = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
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

  /// Obtener los memoriales del usuario
  /*Future<List<Memorial>> fetchMyMemorials(String token) async {
    final uri = Uri.parse("$baseUrl/memorials");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => MemorialResponseModel.fromJson(json).toEntity())
          .toList();
    } else {
      throw Exception(
          "Error al obtener memoriales: ${response.statusCode} ${response.body}"
      );
    }
  }*/

  /// Obtener memoriales colaborativos
  Future<List<Memorial>> fetchCollaborativeMemorials(String token) async {
    final uri = Uri.parse("$baseUrl/memorials/collaborative");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => MemorialResponseModel.fromJson(json).toEntity())
          .toList();
    } else {
      throw Exception(
          "Error al obtener memoriales colaborativos: ${response.statusCode} ${response.body}"
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
}
