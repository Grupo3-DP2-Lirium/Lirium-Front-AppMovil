class MemorialRequestModel {
  final String name;
  final String nickname;
  final String description;
  final String gender;
  final String relation;
  final String birthDate;
  final bool isCollaborative;
  final bool isJournal;

  MemorialRequestModel({
    required this.name,
    required this.nickname,
    required this.description,
    required this.gender,
    required this.relation,
    required this.birthDate,
    required this.isCollaborative,
    required this.isJournal,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "relationType": relation, // 👈 backend pide esto
    "nickname": nickname,
    "description": description,
    "gender": gender,
    "birthDate": birthDate,
    "isCollaborative": isCollaborative,
    "isJournal": isJournal,
  };
}
