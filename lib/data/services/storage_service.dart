import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/extra_storage_response.dart';

/// Servicio para manejar almacenamiento seguro de tokens
class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _tokenKey = 'jwt_token';
  static const String _emailKey = 'user_email';
  static const String _fullNameKey = 'user_full_name';
  static const String _nameKey = 'user_name';
  static const String _usedSpaceKey = 'user_used_space';
  static const String _totalCapacityKey = 'user_total_capacity';
  static const String _documentariesPurchasedKey =
      'user_documentaries_purchased';
  static const String _documentariesAvailableKey =
      'user_documentaries_available';

  static Future<void> saveProfilePhotoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profilePhotoUrl", url);
  }

  static Future<String?> getProfilePhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("profilePhotoUrl");
  }

  /// Guarda la cantidad de documentarios adquiridos
  static Future<void> saveDocumentariesPurchased(int value) async {
    await _storage.write(
      key: _documentariesPurchasedKey,
      value: value.toString(),
    );
  }

  /// Obtiene la cantidad de documentarios adquiridos
  static Future<int> getDocumentariesPurchased() async {
    final str = await _storage.read(key: _documentariesPurchasedKey);
    return str != null ? int.tryParse(str) ?? 0 : 0;
  }

  /// Guarda la cantidad de documentarios disponibles
  static Future<void> saveDocumentariesAvailable(int value) async {
    await _storage.write(
      key: _documentariesAvailableKey,
      value: value.toString(),
    );
  }

  /// Obtiene la cantidad de documentarios disponibles
  static Future<int> getDocumentariesAvailable() async {
    final str = await _storage.read(key: _documentariesAvailableKey);
    return str != null ? int.tryParse(str) ?? 0 : 0;
  }

  static Future<void> saveUsedSpace(double value) async {
    await _storage.write(key: _usedSpaceKey, value: value.toString());
  }

  static Future<double> getUsedSpace() async {
    final str = await _storage.read(key: _usedSpaceKey);
    return str != null ? double.tryParse(str) ?? 0.0 : 0.0;
  }

  static Future<void> saveTotalCapacity(double value) async {
    await _storage.write(key: _totalCapacityKey, value: value.toString());
  }

  static Future<double> getTotalCapacity() async {
    final str = await _storage.read(key: _totalCapacityKey);
    return str != null ? double.tryParse(str) ?? 15.0 : 15.0; // default 15GB
  }

  static Future<void> saveFullSubscriptionJson(
    Map<String, dynamic> json,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("subscription_full_json", jsonEncode(json));
  }

  static Future<Map<String, dynamic>?> getFullSubscriptionJson() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString("subscription_full_json");
    if (str == null) return null;
    return jsonDecode(str);
  }

  /// Guarda el nombre completo del usuario
  static Future<void> saveFullName(String fullName) async {
    await _storage.write(key: _fullNameKey, value: fullName);
  }

  /// Obtiene el nombre completo del usuario
  static Future<String?> getFullName() async {
    return await _storage.read(key: _fullNameKey);
  }

  /// Elimina el nombre completo del usuario
  static Future<void> deleteFullName() async {
    await _storage.delete(key: _fullNameKey);
  }

  /// Guarda el nombre del usuario
  static Future<void> saveName(String name) async {
    await _storage.write(key: _nameKey, value: name);
  }

  /// Obtiene el nombre completo del usuario
  static Future<String?> getName() async {
    return await _storage.read(key: _nameKey);
  }

  /// Elimina el nombre completo del usuario
  static Future<void> deleteName() async {
    await _storage.delete(key: _nameKey);
  }

  /// Guarda el email del usuario
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  /// Obtiene el email del usuario
  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  /// Elimina el email del usuario
  static Future<void> deleteEmail() async {
    await _storage.delete(key: _emailKey);
  }

  /// Guarda las suscripciones de almacenamiento extra
  /*static Future<void> saveExtraStorageSubscriptions(List<Map<String, dynamic>> extraStorages) async {
    await _storage.write(key: _extraStorageKey, value: jsonEncode(extraStorages));
  }

  /// Obtiene las suscripciones de almacenamiento extra
  static Future<List<ExtraStorageResponse>> getExtraStorageSubscriptions() async {
    final data = await _storage.read(key: _extraStorageKey);
    if (data == null) return [];
    return List<ExtraStorageResponse>.from(jsonDecode(data));
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
  }*/

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
  /*static Future<void> deletePlan() async {
    await _storage.delete(key: _planKey);
  }

  /// Elimina los permisos del usuario
  static Future<void> deletePermissions() async {
    await _storage.delete(key: _permissionsKey);
  }*/

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

  // ============ PRIMER LOGIN POR USUARIO ============

  static const String _firstLoginPrefix = 'first_login_completed_';

  /// Verifica si el usuario específico ya completó su primer login
  static Future<bool> hasCompletedFirstLogin([String? userEmail]) async {
    final prefs = await SharedPreferences.getInstance();

    // Si no se proporciona email, intentar obtenerlo del token actual
    String? email = userEmail;
    if (email == null) {
      final user = await getUserFromToken();
      email = user?['email'] ?? user?['sub'];
    }

    // Si no hay email, asumir que no ha completado el primer login
    if (email == null) {
      print('🔍 hasCompletedFirstLogin: No email found, returning false');
      return false;
    }

    // Normalizar email (trim y lowercase para consistencia)
    email = email.trim().toLowerCase();
    final key = '$_firstLoginPrefix$email';
    final result = prefs.getBool(key) ?? false;
    print('🔍 hasCompletedFirstLogin: email=$email, key=$key, result=$result');
    return result;
  }

  /// Marca que el usuario específico completó su primer login
  static Future<void> markFirstLoginCompleted([String? userEmail]) async {
    final prefs = await SharedPreferences.getInstance();

    // Si no se proporciona email, intentar obtenerlo del token actual
    String? email = userEmail;
    if (email == null) {
      final user = await getUserFromToken();
      email = user?['email'] ?? user?['sub'];
    }

    // Si no hay email, no hacer nada
    if (email == null) {
      print(
        '❌ markFirstLoginCompleted: No email found, cannot mark as completed',
      );
      return;
    }

    // Normalizar email (trim y lowercase para consistencia)
    email = email.trim().toLowerCase();
    final key = '$_firstLoginPrefix$email';
    await prefs.setBool(key, true);
    print(
      '✅ markFirstLoginCompleted: email=$email, key=$key, marked as completed',
    );
  }

  /// Limpia el estado del primer login para un usuario específico
  static Future<void> clearFirstLoginStateForUser(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_firstLoginPrefix$userEmail';
    await prefs.remove(key);
  }

  /// Limpia TODOS los estados de primer login (para limpieza completa)
  static Future<void> clearAllFirstLoginStates() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_firstLoginPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Método de debug para listar todos los usuarios que han completado el primer login
  static Future<List<String>> getCompletedFirstLoginUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final completedUsers = <String>[];

    for (final key in keys) {
      if (key.startsWith(_firstLoginPrefix)) {
        final isCompleted = prefs.getBool(key) ?? false;
        if (isCompleted) {
          final email = key.substring(_firstLoginPrefix.length);
          completedUsers.add(email);
        }
      }
    }

    print(
      '🔍 DEBUG: Usuarios que han completado primer login: $completedUsers',
    );
    return completedUsers;
  }

  /// Método de debug para resetear el estado de primer login de un usuario específico
  /// (útil para testing)
  static Future<void> resetFirstLoginForUser(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = userEmail.trim().toLowerCase();
    final key = '$_firstLoginPrefix$normalizedEmail';
    await prefs.remove(key);
    print('🔄 DEBUG: Reset primer login para usuario: $normalizedEmail');
  }
}
