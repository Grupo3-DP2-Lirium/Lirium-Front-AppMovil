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

  Map<String, dynamic> toJson() {
    // ✅ DEBUG: Imprimir valores antes de enviar
    print('🔍 Dart toJson():');
    print('   - isCollaborative: $isCollaborative');
    print('   - isJournal: $isJournal');
    
    final json = {
      "name": name,
      "relationType": relation,
      "nickname": nickname,
      "description": description,
      "gender": gender,
      "birthDate": birthDate,
      // ✅ CAMBIAR: Enviar SIN "is"
      "collaborative": isCollaborative,
      "journal": isJournal,
    };
    
    print('📦 JSON generado: $json');
    return json;
  }
}