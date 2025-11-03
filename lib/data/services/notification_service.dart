import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:flutter_frontend/domain/entities/notification.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final http.Client _client;
  final HttpService _http;

  NotificationService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  /// Obtiene todas las notificaciones del usuario
  Future<List<AppNotification>> getNotifications() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/notifications');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final listJson = jsonDecode(res.body) as List<dynamic>;
      return listJson.map((e) => AppNotification.fromJson(e)).toList();
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Obtiene el contador de notificaciones no leídas
  Future<int> getUnreadCount() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/notifications/unread-count');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final json = jsonDecode(res.body);
      return json['count'] ?? 0;
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Marca una notificación como leída
  Future<AppNotification> markAsRead(int notificationId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId/read');

    final res = await _client.patch(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return AppNotification.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/notifications/mark-all-read');

    final res = await _client.patch(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(int notificationId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId');

    final res = await _client.delete(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Registra el token FCM para recibir notificaciones push
  Future<void> registerDeviceToken(String fcmToken, {String? deviceId}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/device-tokens/register');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(includeJson: true),
      body: jsonEncode({
        'fcmToken': fcmToken,
        'deviceType': 'android', // o 'ios' según la plataforma
        if (deviceId != null) 'deviceId': deviceId,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Elimina el token FCM (al hacer logout)
  Future<void> unregisterDeviceToken(String fcmToken) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/device-tokens/unregister');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(includeJson: true),
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    } else {
      // No lanzar error si falla el unregister
      print('Warning: Failed to unregister device token');
    }
  }
}