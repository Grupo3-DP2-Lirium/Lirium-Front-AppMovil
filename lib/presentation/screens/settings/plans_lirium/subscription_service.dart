import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/services/subscription_response.dart';
import 'package:http/http.dart' as http;

import '../../../../data/services/http_service.dart';

class SubscriptionService {

  final http.Client _client;
  final HttpService _http;
  final String baseUrl = ApiConstants.baseUrl;

  SubscriptionService({http.Client? client})
      : _client = client ?? http.Client(),
        _http = HttpService();

  // Obtiene los planes desde el backend
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

  Future<SubscriptionResponse> getCurrentSubscription() async {
    print('DEBUG: getCurrentSubscription() called');
    final uri = Uri.parse("${ApiConstants.baseUrl}/subscriptions/current-subscription");
    print('DEBUG: Making request to: $uri');

    final res = await _client.get(
      uri,
      headers: _http.authHeaders(), // token Bearer
    );

    print('DEBUG: getCurrentSubscription response - Status: ${res.statusCode}, Body: ${res.body}');
    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(res.body);

      // Convertir JSON a entidad
      final subscriptionResponse = SubscriptionResponse.fromJson(jsonMap);
      print('DEBUG: Parsed subscription with plan: ${subscriptionResponse.planName}');
      return subscriptionResponse;
    } else {
      throw Exception(
        "Error fetching current subscription: ${res.statusCode} ${res.body}",
      );
    }
  }
}
