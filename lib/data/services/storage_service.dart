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
  static const String _planKey = 'user_plan';
  static const String _permissionsKey = 'user_permissions';
  static const String _extraStorageKey = 'user_extra_storage';

  /// Guarda las suscripciones de almacenamiento extra
  static Future<void> saveExtraStorageSubscriptions(List<Map<String, dynamic>> extraStorages) async {
    await _storage.write(key: _extraStorageKey, value: jsonEncode(extraStorages));
  }

  /// Obtiene las suscripciones de almacenamiento extra
  static Future<List<Map<String, dynamic>>> getExtraStorageSubscriptions() async {
    final data = await _storage.read(key: _extraStorageKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  /// Elimina las suscripciones de almacenamiento extra
  static Future<void> deleteExtraStorageSubscriptions() async {
    await _storage.delete(key: _extraStorageKey);
  }

  static Future<void> savePlan(String plan) async {
    await _storage.write(key: _planKey, value: plan);
  }

  static Future<void> savePermissions(List<String> permissions) async {
    await _storage.write(key: _permissionsKey, value: jsonEncode(permissions));
  }

  static Future<String?> getPlan() async {
    return await _storage.read(key: _planKey);
  }

  static Future<List<String>> getPermissions() async {
    final data = await _storage.read(key: _permissionsKey);
    if (data == null) return [];
    return List<String>.from(jsonDecode(data));
  }

  /// Guarda el token JWT de forma segura
  static Future<void> saveToken(String token) async {
    final cleanedToken = token.trim().replaceAll('"', '');
    await _storage.write(key: _tokenKey, value: cleanedToken);
  }

  /// Obtiene el token JWT guardado
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Elimina el token JWT
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Elimina el plan del usuario
  static Future<void> deletePlan() async {
    await _storage.delete(key: _planKey);
  }

  /// Elimina los permisos del usuario
  static Future<void> deletePermissions() async {
    await _storage.delete(key: _permissionsKey);
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