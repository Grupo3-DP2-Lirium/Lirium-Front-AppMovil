import '../../../../data/models/memorial_response.dart';

class MemorialDetailsState {
  final String idMemorial;
  final String name;
  final String nickname;
  final String relation;
  final String birthDate;
  final String gender;
  final String description;
  final bool isOwner;
  final bool canEdit;
  final bool isCollaborative;
  final bool isJournal;
  final String? profilePhotoUrl;
  final String userId;
  final DateTime createdDate;
  final DateTime updatedDate;

  MemorialDetailsState({
    this.idMemorial = '',
    this.name = '',
    this.nickname = '',
    this.relation = '',
    this.birthDate = '',
    this.gender = '',
    this.description = '',
    this.isOwner = false,
    this.canEdit = false,
    this.isCollaborative = false,
    this.isJournal = false,
    this.profilePhotoUrl,
    this.userId = '',
    DateTime? createdDate,
    DateTime? updatedDate,
  })  : createdDate = createdDate ?? DateTime.now(),
        updatedDate = updatedDate ?? DateTime.now();

  MemorialDetailsState copyWith({
    String? idMemorial,
    String? name,
    String? nickname,
    String? relation,
    String? birthDate,
    String? gender,
    String? description,
    bool? isOwner,
    bool? canEdit,
    bool? isCollaborative,
    bool? isJournal,
    String? profilePhotoUrl,
    String? userId,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return MemorialDetailsState(
      idMemorial: idMemorial ?? this.idMemorial,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      relation: relation ?? this.relation,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      description: description ?? this.description,
      isOwner: isOwner ?? this.isOwner,
      canEdit: canEdit ?? this.canEdit,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      isJournal: isJournal ?? this.isJournal,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      userId: userId ?? this.userId,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  factory MemorialDetailsState.fromResponse(MemorialResponseModel resp) {
    return MemorialDetailsState(
      idMemorial: resp.idMemorial,
      name: resp.name,
      nickname: resp.nickname,
      relation: resp.relation,
      birthDate: resp.birthDate,
      gender: resp.gender,
      description: resp.description,
      isOwner: resp.isOwner,
      canEdit: resp.canEdit,
      isCollaborative: resp.isCollaborative,
      isJournal: resp.isJournal,
      profilePhotoUrl: resp.profilePhoto?.fileUrl,
      userId: resp.userId,
      createdDate: resp.createdDate,
      updatedDate: resp.updatedDate,
    );
  }
}
