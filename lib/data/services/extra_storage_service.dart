import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:http/http.dart' as http;

class ExtraStorageService {
  final http.Client _client;
  final HttpService _http;
  final String baseUrl = ApiConstants.baseUrl;

  ExtraStorageService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  /// Crear suscripción de almacenamiento extra en PayPal
  Future<Map<String, dynamic>> createExtraStorageSubscription({
    required String paypalPlanId,
    required String extraPlanId,
    void Function(bool isLoading)? onLoading,
  }) async {
    final uri = Uri.parse("$baseUrl/paypal/create-extra-storage-subscription");
    onLoading?.call(true);

    try {
      final response = await _client.post(
        uri,
        headers: _http.authHeaders(includeJson: true),
        body: jsonEncode({
          "paypalPlanId": paypalPlanId,
          "extraPlanId": extraPlanId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            "Error creando suscripción de almacenamiento extra: "
                "${response.statusCode} ${response.body}");
      }
    } finally {
      onLoading?.call(false);
    }
  }

  /// Confirmar suscripción de almacenamiento extra tras aprobación de PayPal
  Future<void> confirmExtraStorageSubscription({
    required String subscriptionId,
    required String extraPlanId,
    void Function(bool isLoading)? onLoading,
  }) async {
    final uri = Uri.parse("$baseUrl/paypal/storage-success");
    onLoading?.call(true);

    try {
      final response = await _client.get(
        uri.replace(queryParameters: {
          "subscription_id": subscriptionId,
          "planId": extraPlanId,
        }),
        headers: _http.authHeaders(includeJson: true),
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Error confirmando suscripción de almacenamiento extra: ${response.statusCode}");
      }
    } finally {
      onLoading?.call(false);
    }
  }

  /// Cancelar suscripción de almacenamiento extra
  Future<void> cancelExtraStorageSubscription({
    void Function(bool isLoading)? onLoading,
  }) async {
    final uri = Uri.parse("$baseUrl/paypal/storage-cancel");
    onLoading?.call(true);

    try {
      final response = await _client.get(
        uri,
        headers: _http.authHeaders(includeJson: true),
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Error cancelando suscripción de almacenamiento extra: ${response.statusCode}");
      }
    } finally {
      onLoading?.call(false);
    }
  }

  /// Listar todos los planes de almacenamiento extra
  Future<List<Map<String, dynamic>>> listExtraStoragePlans() async {
    try {
      final uri = Uri.parse("$baseUrl/extra-storage/plans");

      final response = await _client.get(
        uri,
        headers: _http.authHeaders(includeJson: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Convertir a List<Map<String, dynamic>> y asegurar que todos los campos clave existan
        return data.map((item) {
          final plan = Map<String, dynamic>.from(item);

          return {
            "idExtraPlan": plan["idExtraPlan"]?.toString() ?? "",
            "name": plan["name"]?.toString() ?? "Plan Extra",
            "description": plan["description"]?.toString() ?? "",
            "additionalStorageGb": plan["additionalStorageGb"] ?? 0,
            "price": plan["price"] ?? 0,
            "currency": plan["currency"]?.toString() ?? "USD",
            "active": plan["active"] ?? true,
            "paypalPlanId": plan["paypalPlanId"]?.toString() ?? "-",
            "frequency": plan["frequency"]?.toString() ?? "Mensual",
          };
        }).toList();
      } else {
        throw Exception(
            "Error cargando planes de almacenamiento extra: ${response.statusCode}");
      }
    } catch (e) {
      print('Error en ExtraStorageService.listExtraStoragePlans: $e');
      throw Exception('Error cargando planes de almacenamiento extra');
    }
  }

  /// Obtener la suscripción activa de almacenamiento extra del usuario
  Future<Map<String, dynamic>?> getActiveExtraStorageSubscription() async {
    final uri = Uri.parse("$baseUrl/extra-storage/active");

    final response = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: true),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(
          "Error obteniendo suscripción activa de almacenamiento extra: ${response.statusCode}");
    }
  }

}
