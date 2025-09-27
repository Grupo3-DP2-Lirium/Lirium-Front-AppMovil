import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_constants.dart';
import '../../config/app_config.dart';
import '../models/memorial_response.dart';


class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // headers públicos para reuso (JSON)
  Map<String, String> authHeaders({bool includeJson = true}) {
    final h = <String, String>{};
    if (includeJson) h['Content-Type'] = 'application/json';
    h['Accept'] = 'application/json';
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // aplica auth a multipart
  void attachAuthToMultipart(http.MultipartRequest req) {
    req.headers['Accept'] = 'application/json';
    if (_token != null && _token!.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $_token';
    }
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<List<MemorialResponseModel>> getCollaborativeMemorials() async {
    try {
      final response = await get(ApiConstants.collaborativeMemorials);

      // --- AGREGA ESTAS LÍNEAS PARA VER LA RESPUESTA ---
      print('--- Respuesta de /memorials/collaborative ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      // -------------------------------------------------

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MemorialResponseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load collaborative memorials (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<MemorialResponseModel>> getMyMemorials() async {
    try {
      final response = await get(ApiConstants.memorials);

      print('--- Respuesta de /memorials ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MemorialResponseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load memorials (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }


  Future<http.Response> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: _headers,
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: _headers,
        body: json.encode(body),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse(endpoint),
        headers: _headers,
        body: json.encode(body),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: _headers,
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}