import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kLastEmail = 'last_email'; // clave para último correo persistente
  final _s = const FlutterSecureStorage();

  Future<void> save({required String access, String? refresh}) async {
    await _s.write(key: _kAccess, value: access);
    if (refresh != null) await _s.write(key: _kRefresh, value: refresh);
  }

  Future<String?> readAccess() => _s.read(key: _kAccess);
  Future<String?> readRefresh() => _s.read(key: _kRefresh);

  // Guardar último correo
  Future<void> saveLastEmail(String email) async {
    await _s.write(key: _kLastEmail, value: email);
  }

  // Obtener último correo
  Future<String?> getLastEmail() => _s.read(key: _kLastEmail);

  // Limpia solo tokens; preserva el último correo para prellenar en el login tras cerrar sesión
  Future<void> clear() async {
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
    // Nota: NO borramos _kLastEmail para recordar el último correo después del logout.
    // Si alguna vez necesitas limpiar absolutamente todo, crea un método dedicado como:
    // Future<void> clearAll() async => _s.deleteAll();
  }
}