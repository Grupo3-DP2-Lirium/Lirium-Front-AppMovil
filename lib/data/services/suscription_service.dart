import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:http/http.dart' as http;

class PayPalService {
  final http.Client _client;
  final HttpService _http;
  final String baseUrl = ApiConstants.baseUrl;

  PayPalService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  /// Crear orden de PayPal
  Future<Map<String, dynamic>> createPayPalOrder({
    required double amount,
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
}
