import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:flutter_frontend/domain/entities/reminder.dart';
import 'package:http/http.dart' as http;

class ReminderService {
  final http.Client _client;
  final HttpService _http;

  ReminderService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  /// Obtiene todos los recordatorios del usuario autenticado
  Future<List<Reminder>> getReminders() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reminders');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final listJson = jsonDecode(res.body) as List<dynamic>;
      return listJson.map((e) => Reminder.fromJson(e)).toList();
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Obtiene recordatorios próximos (ej: próximos 7 días)
  Future<List<Reminder>> getUpcomingReminders({int days = 7}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reminders/upcoming?days=$days');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: false),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final listJson = jsonDecode(res.body) as List<dynamic>;
      return listJson.map((e) => Reminder.fromJson(e)).toList();
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Crea un nuevo recordatorio
  Future<Reminder> createReminder(Reminder reminder) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reminders');

    final res = await _client.post(
      uri,
      headers: _http.authHeaders(includeJson: true),
      body: jsonEncode(reminder.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Reminder.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Actualiza un recordatorio existente
  Future<Reminder> updateReminder(int reminderId, Reminder reminder) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reminders/$reminderId');

    final res = await _client.put(
      uri,
      headers: _http.authHeaders(includeJson: true),
      body: jsonEncode(reminder.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Reminder.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// Elimina un recordatorio
  Future<void> deleteReminder(int reminderId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reminders/$reminderId');

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

  /// Activa/desactiva un recordatorio específico
  Future<Reminder> toggleReminderActive(int reminderId, bool active) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reminders/$reminderId/toggle');

    final res = await _client.patch(
      uri,
      headers: _http.authHeaders(includeJson: true),
      body: jsonEncode({'active': active}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Reminder.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      throw Exception('Sesión expirada (401).');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}