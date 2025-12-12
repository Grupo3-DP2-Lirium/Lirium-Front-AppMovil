import 'dart:convert';
import '../../config/api_constants.dart';
import 'http_service.dart';

class UserReportService {
  final HttpService _http = HttpService();

  Future<void> createReport({
    required String reportedUserId,
    required String reason,
    required String description,
    required String contentType,
    required String contentId,
  }) async {
    try {
      print('📋 Enviando reporte de usuario: $reportedUserId');

      final response = await _http
          .post('${ApiConstants.baseUrl}/user-reports', {
            'reportedUserId': reportedUserId,
            'reason': reason,
            'description': description,
            'contentType': contentType,
            'contentId': contentId,
          });

      print('📋 Status code: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al enviar reporte');
      }

      print('✅ Reporte enviado exitosamente');
    } catch (e) {
      print('❌ Error al enviar reporte: $e');
      throw Exception('Error al enviar reporte: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getMyReports() async {
    try {
      final response = await _http.get(
        '${ApiConstants.baseUrl}/user-reports/my-reports',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al cargar reportes');
      }
    } catch (e) {
      print('❌ Error al cargar reportes: $e');
      throw Exception('Error al cargar reportes: ${e.toString()}');
    }
  }
}
