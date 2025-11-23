import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:flutter_frontend/data/models/subscription_response.dart';
import 'package:http/http.dart' as http;

class SubscriptionService {
  final http.Client _client;
  final HttpService _http;
  final String baseUrl = ApiConstants.baseUrl;

  SubscriptionService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  /// Crear orden de PayPal
  Future<Map<String, dynamic>> createPayPalOrder({
    required double amount,
    required String planId,
    bool simulateFail = false,
    void Function(bool isLoading)? onLoading,
  }) async {
    final uri = Uri.parse("$baseUrl/paypal/create-order");
    onLoading?.call(true);

    try {
      final response = await _client.post(
        uri,
        headers: _http.authHeaders(includeJson: true),
        body: jsonEncode({
          'amount': amount,
          'simulateFail': simulateFail,
          'planId': planId
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            "Error creando orden PayPal: ${response.statusCode} ${response.body}");
      }
    } finally {
      onLoading?.call(false);
    }
  }

  /// Capturar orden de PayPal
  Future<Map<String, dynamic>> capturePayPalOrder({
    required String orderId,
    required String planId,
    required String frequency, // "MONTHLY" o "YEARLY"
    bool simulateFail = false,
    void Function(bool isLoading)? onLoading,
  }) async {
    final uri = Uri.parse("$baseUrl/paypal/capture-order");
    onLoading?.call(true);

    try {
      final response = await _client.post(
        uri,
        headers: _http.authHeaders(includeJson: true),
        body: jsonEncode({
          'orderId': orderId,
          'planId': planId,
          'frequency': frequency,
          'simulateFail': simulateFail,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            "Error capturando orden PayPal: ${response.statusCode} ${response.body}");
      }
    } finally {
      onLoading?.call(false);
    }
  }

  /// Cargar los planes de suscripcion
  static Future<List<Map<String, dynamic>>> loadPlans() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/plans/available'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error cargando planes (${response.statusCode})');
      }
    } catch (e) {
      print('Error en SubscriptionService.loadPlans: $e');
      throw Exception('Error cargando planes');
    }
  }

  /// Obtener suscripcion actual
  Future<SubscriptionResponse> getCurrentSubscription() async {
    print('DEBUG: getCurrentSubscription() called');
    final uri = Uri.parse("${ApiConstants.baseUrl}/subscriptions/current-subscription");
    print('DEBUG: Making request to: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(),
    );

    print('DEBUG: getCurrentSubscription response - Status: ${res.statusCode}, Body: ${res.body}');
    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(res.body);

      // Convertir JSON a entidad
      final subscriptionResponse = SubscriptionResponse.fromJson(jsonMap);
      print('DEBUG: Parsed subscription with plan: ${subscriptionResponse.planName}');
      Future<SubscriptionResponse> getCurrentSubscription() async {
        print('DEBUG: getCurrentSubscription() called');
        final uri = Uri.parse("${ApiConstants.baseUrl}/subscriptions/current-subscription");
        print('DEBUG: Making request to: $uri');

        final res = await _client.get(
          uri,
          headers: _http.authHeaders(),
        );

        print('DEBUG: getCurrentSubscription response - Status: ${res.statusCode}, Body: ${res.body}');

        if (res.statusCode == 200) {
          final Map<String, dynamic> jsonMap = jsonDecode(res.body);

          // Ver todo el JSON crudo
          print('DEBUG: Raw JSON parsed: $jsonMap');

          // Convertir JSON a entidad
          final subscriptionResponse = SubscriptionResponse.fromJson(jsonMap);

          // Imprimir todos los detalles de la suscripción
          print('>>> Subscription Parsed <<<');
          print('Subscription ID: ${subscriptionResponse.subscriptionId}');
          print('Status: ${subscriptionResponse.status}');
          print('Frequency: ${subscriptionResponse.frequency}');
          print('StartDate: ${subscriptionResponse.startDate}');
          print('EndDate: ${subscriptionResponse.endDate}');
          print('PaymentMethod: ${subscriptionResponse.paymentMethod}');

          print('--- Plan Details ---');
          print('Plan ID: ${subscriptionResponse.planId}');
          print('Plan Name: ${subscriptionResponse.planName}');
          print('Plan Description: ${subscriptionResponse.planDescription}');
          print('Plan Price: ${subscriptionResponse.planPrice}');
          print('Plan Currency: ${subscriptionResponse.planCurrency}');
          print('Storage Limit GB: ${subscriptionResponse.storageLimitGb}');
          print('Max Files: ${subscriptionResponse.maxFiles}');
          print('Max Collaborations: ${subscriptionResponse.maxCollaborations}');
          print('Max Documentaries Per Month: ${subscriptionResponse.maxDocumentariesPerMonth}');


          return subscriptionResponse;
        } else {
          throw Exception(
            "Error fetching current subscription: ${res.statusCode} ${res.body}",
          );
        }
      }

      return subscriptionResponse;
    } else {
      throw Exception(
        "Error fetching current subscription: ${res.statusCode} ${res.body}",
      );
    }
  }

  Future<Map<String, dynamic>> createPaypalSubscription({
    required String paypalPlanId,
    required String planId,
    void Function(bool isLoading)? onLoading,
  }) async {
    final uri = Uri.parse("$baseUrl/paypal/create-subscription");
    onLoading?.call(true);

    try {
      final response = await _client.post(
        uri,
        headers: _http.authHeaders(includeJson: true),
        body: jsonEncode({
          "paypalPlanId": paypalPlanId,
          'planId': planId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Error creando suscripción PayPal: "
              "${response.statusCode} ${response.body}",
        );
      }
    } finally {
      onLoading?.call(false);
    }
  }

  Future<void> confirmPaypalSubscription(String subscriptionId, String planId) async {
    final uri = Uri.parse('$baseUrl/paypal/subscription-success');

    final response = await _client.post(
      uri,
      headers: _http.authHeaders(includeJson: true),
      body: jsonEncode({
        'subscriptionId': subscriptionId,
        'planId': planId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error confirmando suscripción en backend");
    }
  }

  Future<void> cancelPaypalSubscription() async {
    final uri = Uri.parse('$baseUrl/paypal/subscription-cancel');

    final response = await _client.post(
      uri,
      headers: _http.authHeaders(includeJson: true),
    );

    if (response.statusCode != 200) {
      throw Exception("Error cancelando suscripción en backend");
    }
  }

  Future<List<String>> getPlanPermissions(String planId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/subscriptions/$planId/permissions');

    final response = await _client.get(
      uri,
      headers: _http.authHeaders(includeJson: true), // si necesitas token
    );

    if (response.statusCode == 200) {
      // Decodificar JSON
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Convertir dinámicos a strings
      return jsonList.map((e) => e.toString()).toList();
    } else {
      throw Exception("Error obteniendo permisos del plan");
    }
  }

}
