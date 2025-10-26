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
  });

  factory MemorialResponseModel.fromJson(Map<String, dynamic> json) {
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
      createdDate: DateTime.parse(json['createdDate']),
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : DateTime.now(),
      profilePhoto: json['profilePhoto'] != null
          ? FileResponse.fromJson(json['profilePhoto'])
          : null,
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
      birthDate: birthDate.isNotEmpty ? DateTime.tryParse(birthDate) : null, // ✅ Manejo seguro de null
      isCollaborative: isCollaborative,
      isJournal: isJournal,
      createdDate: createdDate,
      profilePhotoUrl: profilePhoto?.fileUrl
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
    };
  }

}
