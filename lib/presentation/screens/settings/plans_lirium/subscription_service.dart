import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:http/http.dart' as http;

class SubscriptionService {

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
}
