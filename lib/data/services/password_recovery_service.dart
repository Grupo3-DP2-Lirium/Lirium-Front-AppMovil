import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_frontend/config/api_constants.dart';
import '../models/forgot_password_request.dart';
import '../models/verify_code_request.dart';
import '../models/reset_password_request.dart';

class PasswordRecoveryService {
  /// Solicita el envío de código de recuperación al email
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ForgotPasswordRequest(email: email).toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('No encontramos una cuenta con ese email');
      } else if (response.statusCode == 429) {
        throw Exception('Demasiadas solicitudes. Intenta más tarde');
      } else {
        throw Exception('Error al enviar el código. Intenta nuevamente');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión. Verifica tu internet');
    }
  }

  /// Verifica el código de 6 dígitos alfanumérico
  Future<String> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyCode),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(VerifyCodeRequest(
          email: email,
          code: code.toUpperCase(), // Normalizar a mayúsculas
        ).toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['resetToken'] as String;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'Código incorrecto';
        throw Exception(message);
      } else if (response.statusCode == 429) {
        throw Exception('Máximo de intentos alcanzado');
      } else {
        throw Exception('Error al verificar el código');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión. Verifica tu internet');
    }
  }

  /// Restablece la contraseña con el token de verificación
  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.resetPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ResetPasswordRequest(
          resetToken: resetToken,
          newPassword: newPassword,
        ).toJson()),
      );

      if (response.statusCode == 200) {
        return; // Éxito
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'Error al actualizar contraseña';
        throw Exception(message);
      } else {
        throw Exception('Error al actualizar la contraseña');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión. Verifica tu internet');
    }
  }
}
