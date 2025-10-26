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

  // Método para enviar formularios multipart (archivos)
  Future<http.Response> postMultipart(String endpoint, Map<String, String> fields, List<http.MultipartFile> files) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));
      
      // Agregar headers de autenticación
      attachAuthToMultipart(request);
      
      // Agregar campos
      request.fields.addAll(fields);
      
      // Agregar archivos
      request.files.addAll(files);

      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Error de conexión multipart: $e');
    }
  }

  // Método para PUT con formularios multipart
  Future<http.Response> putMultipart(String endpoint, Map<String, String> fields, List<http.MultipartFile> files) async {
    try {
      final request = http.MultipartRequest('PUT', Uri.parse(endpoint));
      
      // Agregar headers de autenticación
      attachAuthToMultipart(request);
      
      // Agregar campos
      request.fields.addAll(fields);
      
      // Agregar archivos
      request.files.addAll(files);

      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: AppConfig.connectionTimeout),
      );

      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Error de conexión multipart: $e');
    }
  }

  // Método para descargar archivos
  Future<String?> downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: authHeaders(includeJson: false),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      if (response.statusCode == 200) {
        // Aquí podrías guardar el archivo en el dispositivo
        // Por ahora solo retornamos la URL ya que la descarga real
        // requiere manejo de archivos específico del dispositivo
        return url;
      }
      
      return null;
    } catch (e) {
      throw Exception('Error descargando archivo: $e');
    }
  }
}