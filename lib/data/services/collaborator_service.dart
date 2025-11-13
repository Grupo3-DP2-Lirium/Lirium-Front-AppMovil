import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/collaborator_response.dart';
import '../../config/api_constants.dart';
import 'http_service.dart';

class CollaboratorService {
  final HttpService _http = HttpService();

  Future<List<CollaboratorResponse>> getCollaborators(String memorialId) async {
    final response = await _http.get('${ApiConstants.baseUrl}/collaborators/memorial/$memorialId');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollaboratorResponse.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar colaboradores');
    }
  }

  /// ✅ NUEVO: Invitar directamente por email
  Future<void> inviteByEmail({
    required String memorialId,
    required String email,
    required bool canEdit,
    required bool canComment,
  }) async {
    try {
      print('📧 Enviando invitación por email a: $email');
      
      final response = await _http.post(
        '${ApiConstants.baseUrl}/collaborators/invite-by-email',
        {
          'memorialId': memorialId,
          'email': email,
          'canEdit': canEdit,
          'canComment': canComment,
        },
      );
      
      print('📋 Status code: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al enviar invitación');
      }
      
      print('✅ Invitación enviada exitosamente');
      
    } catch (e) {
      print('❌ Error en inviteByEmail: $e');
      rethrow;
    }
  }

  Future<void> updateCollaborator(
    int collaboratorId, {
    required bool canEdit,
    required bool canComment,
  }) async {
    try {
      print('🔄 Actualizando colaborador $collaboratorId');
      
      final response = await _http.put(
        '${ApiConstants.baseUrl}/collaborators/$collaboratorId',
        {
          'canEdit': canEdit,
          'canComment': canComment,
        },
      );
      
      print('📋 Update status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar colaborador: ${response.statusCode}');
      }
      
      print('✅ Colaborador actualizado');
    } catch (e) {
      print('❌ Error actualizando colaborador: $e');
      rethrow;
    }
  }

  Future<void> removeCollaborator(int collaboratorId) async {
    try {
      print('🗑️ Eliminando colaborador $collaboratorId');
      
      final response = await _http.delete(
        '${ApiConstants.baseUrl}/collaborators/$collaboratorId',
      );
      
      print('📋 Delete status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar colaborador: ${response.statusCode}');
      }
      
      print('✅ Colaborador eliminado');
    } catch (e) {
      print('❌ Error eliminando colaborador: $e');
      rethrow;
    }
  }
}