  // lib/data/services/invite_code_service.dart
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../../config/api_constants.dart';
  import 'http_service.dart';

  class InviteCodeService {
    final HttpService _http = HttpService();

    /// Genera un código de invitación
    Future<InviteCodeResponse> createInviteCode({
      required String memorialId,
      bool canEdit = false,
      bool canComment = true,
      int maxUses = 1,
    }) async {
      final response = await _http.post(
        '${ApiConstants.baseUrl}/collaborators/invite-code',
        {
          'memorialId': memorialId,
          'canEdit': canEdit,
          'canComment': canComment,
          'maxUses': maxUses,
        },
      );

      if (response.statusCode == 200) {
        return InviteCodeResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear código de invitación');
      }
    }

    /// Valida un código de invitación
    Future<InviteCodeValidation> validateCode(String code) async {
      final response = await _http.get(
        '${ApiConstants.baseUrl}/collaborators/validate-code/${code.toUpperCase()}',
      );

      if (response.statusCode == 200) {
        return InviteCodeValidation.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error is String ? error : error['message'] ?? 'Código inválido');
      }
    }

    /// Acepta una invitación con código
    Future<Map<String, dynamic>> acceptInviteCode(String code) async {
      final response = await _http.post(
        '${ApiConstants.baseUrl}/collaborators/accept-code/${code.toUpperCase()}',
        {},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error is String ? error : error['message'] ?? 'Error al aceptar invitación');
      }
    }

    /// Lista códigos de invitación de un memorial
    Future<List<InviteCodeResponse>> getInviteCodes(String memorialId) async {
      final response = await _http.get(
        '${ApiConstants.baseUrl}/collaborators/invite-codes/$memorialId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => InviteCodeResponse.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar códigos');
      }
    }

    /// Revoca un código de invitación
    Future<void> revokeInviteCode(String code) async {
      final response = await _http.delete(
        '${ApiConstants.baseUrl}/collaborators/invite-code/${code.toUpperCase()}',
      );

      if (response.statusCode != 200) {
        throw Exception('Error al revocar código');
      }
    }
  }

  // Modelos de respuesta
  class InviteCodeResponse {
    final String code;
    final bool canEdit;
    final bool canComment;
    final DateTime createdDate;
    final DateTime expiresAt;
    final String status;
    final int maxUses;
    final int usedCount;

    InviteCodeResponse({
      required this.code,
      required this.canEdit,
      required this.canComment,
      required this.createdDate,
      required this.expiresAt,
      required this.status,
      required this.maxUses,
      required this.usedCount,
    });

    factory InviteCodeResponse.fromJson(Map<String, dynamic> json) {
      return InviteCodeResponse(
        code: json['code'],
        canEdit: json['canEdit'],
        canComment: json['canComment'],
        createdDate: DateTime.parse(json['createdDate']),
        expiresAt: DateTime.parse(json['expiresAt']),
        status: json['status'],
        maxUses: json['maxUses'],
        usedCount: json['usedCount'],
      );
    }
  }

  class InviteCodeValidation {
    final String memorialId;
    final String memorialName;
    final String memorialDescription;
    final String inviterName;
    final bool canEdit;
    final bool canComment;

    InviteCodeValidation({
      required this.memorialId,
      required this.memorialName,
      required this.memorialDescription,
      required this.inviterName,
      required this.canEdit,
      required this.canComment,
    });

    factory InviteCodeValidation.fromJson(Map<String, dynamic> json) {
      return InviteCodeValidation(
        memorialId: json['memorialId'],
        memorialName: json['memorialName'],
        memorialDescription: json['memorialDescription'] ?? '',
        inviterName: json['inviterName'],
        canEdit: json['canEdit'],
        canComment: json['canComment'],
      );
    }
  }