import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'file_response.dart';

class MemorialResponseModel {
  final String idMemorial;
  final String name;
  final String nickname;
  final String description;
  final String gender;
  final String relation;
  final String birthDate;
  final bool isCollaborative;
  final bool isJournal;
  final String userId;
  final DateTime createdDate;
  final DateTime updatedDate;
  final FileResponse? profilePhoto;
  final bool isOwner; // ✅ CRÍTICO: Ahora obligatorio, no nullable
  final bool canEdit; // ✅ CRÍTICO: Nuevo campo para permisos

  MemorialResponseModel({
    required this.idMemorial,
    required this.name,
    required this.nickname,
    required this.description,
    required this.gender,
    required this.relation,
    required this.birthDate,
    required this.isCollaborative,
    required this.isJournal,
    required this.userId,
    required this.createdDate,
    required this.updatedDate,
    this.profilePhoto,
    this.isOwner = false, // ✅ Default falso si no viene del backend
    this.canEdit = false, // ✅ Default falso si no viene del backend
  });

  factory MemorialResponseModel.fromJson(Map<String, dynamic> json) {
    String createdRaw = json['createdDate'] ?? '';
    String updatedRaw = json['updatedDate'] ?? '';

    DateTime parseDate(String raw) {
      if (raw.isEmpty) return DateTime.now();
      return DateTime.parse(raw.replaceFirst(' ', 'T'));
    }

    // ✅ CRÍTICO: Parsear isOwner del backend
    bool isOwner = json['isOwner'] ?? false;
    
    print('🔍 Parseando memorial:');
    print('   - ID: ${json["idMemorial"]}');
    print('   - Nombre: ${json["name"]}');
    print('   - isOwner desde JSON: $isOwner');

    return MemorialResponseModel(
      idMemorial: json["idMemorial"] ?? '',
      name: json["name"] ?? '',
      nickname: json["nickname"] ?? '',
      description: json["description"] ?? '',
      gender: json["gender"] ?? '',
      relation: json["relationType"] ?? '',
      birthDate: json["birthDate"] ?? '',
      isCollaborative: json["collaborative"] ?? false,
      isJournal: json["journal"] ?? false,
      userId: json['userId'] ?? '',
      createdDate: parseDate(createdRaw),
      updatedDate: updatedRaw.isNotEmpty ? parseDate(updatedRaw) : DateTime.now(),
      profilePhoto: json['profilePhoto'] != null
          ? FileResponse.fromJson(json['profilePhoto'])
          : null,
      isOwner: isOwner, // ✅ CRÍTICO
      canEdit: json['canEdit'] ?? false, // ✅ CRÍTICO
    );
  }

  Memorial toEntity() {
    return Memorial(
      idMemorial: idMemorial,
      name: name,
      nickname: nickname,
      description: description,
      gender: gender,
      relation: relation,
      birthDate: birthDate.isNotEmpty ? DateTime.tryParse(birthDate) : null,
      isCollaborative: isCollaborative,
      isJournal: isJournal,
      createdDate: createdDate,
      profilePhotoUrl: profilePhoto?.fileUrl,
      isOwner: isOwner,
      canEdit: canEdit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idMemorial,
      'name': name,
      'description': description,
      'isCollaborative': isCollaborative,
      'userId': userId,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'isOwner': isOwner, // ✅ Incluir en JSON
      'canEdit': canEdit, // ✅ Incluir en JSON
    };
  }
}