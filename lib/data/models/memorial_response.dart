import 'package:flutter_frontend/domain/entities/memorial.dart';

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
  });

  factory MemorialResponseModel.fromJson(Map<String, dynamic> json) {
    return MemorialResponseModel(
      idMemorial: json["idMemorial"],
      name: json["name"],
      nickname: json["nickname"],
      description: json["description"],
      gender: json["gender"],
      relation: json["relationType"], // 👈 backend
      birthDate: json["birthDate"],
      isCollaborative: json["isCollaborative"] ?? false,
      isJournal: json["isJournal"] ?? false,
    );
  }

  /// Aquí sí haces toEntity
  Memorial toEntity() {
    return Memorial(
      id: idMemorial,
      name: name,
      nickname: nickname,
      description: description,
      gender: gender,
      relation: relation,
      birthDate: DateTime.parse(birthDate),
      isCollaborative: isCollaborative,
      isJournal: isJournal,
    );
  }
}
