import 'dart:convert';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> createPayPalOrder({
  required String amount,
  bool simulateFail = false,
}) async {
  final uri = Uri.parse("${ApiConstants.baseUrl}/paypal/create-order");

  final req = http.MultipartRequest('POST', uri);

  // Headers
  req.headers['Accept'] = 'application/json';
  req.headers['Content-Type'] = 'application/json';

  // Agregar body como campo JSON
  req.fields['body'] = jsonEncode({'amount': amount, 'simulateFail': simulateFail});

  // Enviar
  final streamed = await req.send();
  final resp = await http.Response.fromStream(streamed);

  if (resp.statusCode == 200) {
    return jsonDecode(resp.body) as Map<String, dynamic>;
  } else {
    throw Exception(
      "Error ${resp.statusCode}: ${resp.body.isEmpty ? 'sin cuerpo' : resp.body}",
    );
  }
}

Future<Map<String, dynamic>> capturePayPalOrder({
  required String orderId,
  required int userId,
  bool simulateFail = false,
}) async {
  final uri = Uri.parse("${ApiConstants.baseUrl}/paypal/capture-order");
  final req = http.MultipartRequest('POST', uri);

  req.headers['Accept'] = 'application/json';
  req.headers['Content-Type'] = 'application/json';

  req.fields['body'] = jsonEncode({
    'orderId': orderId,
    'userId': userId,
    'simulateFail': simulateFail,
  });

  final streamed = await req.send();
  final resp = await http.Response.fromStream(streamed);

  if (resp.statusCode == 200) {
    return jsonDecode(resp.body) as Map<String, dynamic>;
  } else {
    throw Exception(
      "Error ${resp.statusCode}: ${resp.body.isEmpty ? 'sin cuerpo' : resp.body}",
    );
  }
}
