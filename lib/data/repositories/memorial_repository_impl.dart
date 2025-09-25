import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/repositories/memorial_repository.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/memorial.dart';
import '../models/memorial_request.dart';
import '../models/memorial_response.dart';

class MemorialRepositoryImpl implements MemorialRepository {
  final String baseUrl;

  MemorialRepositoryImpl(this.baseUrl);

  @override
  Future<Memorial> createMemorial(
      MemorialRequestModel request,
      String? imagePath,
      String token,
      ) async {
    var uri = Uri.parse("${ApiConstants.baseUrl}/memorials");

    final requestMultipart = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..fields['memorial'] = jsonEncode(request.toJson());

    if (imagePath != null) {
      requestMultipart.files.add(
        await http.MultipartFile.fromPath("file", imagePath),
      );
    }

    final response = await requestMultipart.send();
    final httpResponse = await http.Response.fromStream(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(httpResponse.body);

      // 👇 Convierte el modelo en entidad
      return MemorialResponseModel.fromJson(jsonMap).toEntity();
    } else {
      throw Exception("Error creando memorial: ${response.statusCode} ${httpResponse.body}");
    }

  }
}
