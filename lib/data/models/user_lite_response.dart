class UserLiteResponse {
  final String idUser;
  final String name;
  final String? profilePhotoUrl;

  UserLiteResponse({
    required this.idUser,
    required this.name,
    this.profilePhotoUrl,
  });

  factory UserLiteResponse.fromJson(Map<String, dynamic> json) {
    return UserLiteResponse(
      idUser: json['idUser'] as String,
      name: json['name'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }

  toJson() {
    return {
      'idUser': idUser,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }
}