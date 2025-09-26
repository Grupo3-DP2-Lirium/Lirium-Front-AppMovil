import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  final _s = const FlutterSecureStorage();

  Future<void> save({required String access, String? refresh}) async {
    await _s.write(key: _kAccess, value: access);
    if (refresh != null) await _s.write(key: _kRefresh, value: refresh);
  }

  Future<String?> readAccess() => _s.read(key: _kAccess);
  Future<String?> readRefresh() => _s.read(key: _kRefresh);
  Future<void> clear() async {
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
  }
}