class Memorial {
  final String idMemorial;
  final String name;
  final String nickname;
  final String description;
  final String gender;
  final String relation;
  final DateTime birthDate;
  final bool isCollaborative;
  final bool isJournal;
  final DateTime createdDate;
  final String? profilePhotoUrl;
  final String? profilePhotoBase64;

  Memorial({
    required this.idMemorial,
    required this.name,
    required this.nickname,
    required this.description,
    required this.gender,
    required this.relation,
    required this.birthDate,
    required this.isCollaborative,
    required this.isJournal,
    required this.createdDate,
    this.profilePhotoUrl,
    this.profilePhotoBase64
  });

}
