class Memorial {
  final String idMemorial;
  final String name;
  final String nickname;
  final String description;
  final String gender;
  final String relation;
  final DateTime? birthDate; // ✅ Ahora es nullable
  final bool isCollaborative;
  final bool isJournal;
  final DateTime createdDate;
  final String? profilePhotoUrl;
  final String? profilePhotoBase64;
  final bool? isOwner; // ✅ CRÍTICO: Campo obligatorio
  final bool? canEdit; // ✅ CRÍTICO: Nuevo campo para permisos

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
    this.profilePhotoBase64,
    this.isOwner = false,
    this.canEdit = false,
  });

}
