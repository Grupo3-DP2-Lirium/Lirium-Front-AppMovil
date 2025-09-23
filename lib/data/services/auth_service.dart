// services/auth_service.dart
import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final http.Client _client;
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Login que devuelve un token
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    final res = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      // Ajusta la key según tu backend (puede ser 'token' o 'accessToken')
      return body['token'] as String;
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
