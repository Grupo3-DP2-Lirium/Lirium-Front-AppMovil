class Memorial {
  final String id;
  final String name;
  final String nickname;
  final String description;
  final String gender;
  final String relation;
  final DateTime birthDate;
  final bool isCollaborative;
  final bool isJournal;

  Memorial({
    required this.id,
    required this.name,
    required this.nickname,
    required this.description,
    required this.gender,
    required this.relation,
    required this.birthDate,
    required this.isCollaborative,
    required this.isJournal,
  });
}
