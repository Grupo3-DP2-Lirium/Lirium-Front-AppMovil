import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para manejar almacenamiento seguro de tokens
class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _tokenKey = 'jwt_token';

  /// Guarda el token JWT de forma segura
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Obtiene el token JWT guardado
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Elimina el token JWT
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Elimina todos los datos guardados
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Verifica si existe un token válido (no expirado)
  static Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    return _isTokenValid(token);
  }

  /// Verifica si el JWT no ha expirado
  static bool _isTokenValid(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'] * 1000;
      return DateTime.now().millisecondsSinceEpoch < exp;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información del usuario desde el token
  static Future<Map<String, dynamic>?> getUserFromToken() async {
    final token = await getToken();
    if (token == null || !_isTokenValid(token)) return null;

    try {
      final parts = token.split('.');
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return payload;
    } catch (e) {
      return null;
    }
  }
}