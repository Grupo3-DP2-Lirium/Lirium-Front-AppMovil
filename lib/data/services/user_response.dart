class UserResponse {
  final String idUser;
  final String firstName;
  final String firstLastName;
  final String? secondLastName;
  final String email;
  final List<String> roles;
  final String status;
  final double? usedSpace;
  final double? totalCapacity;
  final String createdDate;
  final String? updatedDate;
  final String? lastSessionDate;

  UserResponse({
    required this.idUser,
    required this.firstName,
    required this.firstLastName,
    this.secondLastName,
    required this.email,
    required this.roles,
    required this.status,
    this.usedSpace,
    this.totalCapacity,
    required this.createdDate,
    this.updatedDate,
    this.lastSessionDate,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      idUser: json['idUser'] as String,
      firstName: json['firstName'] as String,
      firstLastName: json['firstLastName'] as String,
      secondLastName: json['secondLastName'] as String?,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] ?? []),
      status: json['status'] as String,
      usedSpace: (json['usedSpace'] as num?)?.toDouble(),
      totalCapacity: (json['totalCapacity'] as num?)?.toDouble(),
      createdDate: json['createdDate'] as String,
      updatedDate: json['updatedDate'] as String?,
      lastSessionDate: json['lastSessionDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'idUser': idUser,
    'firstName': firstName,
    'firstLastName': firstLastName,
    'secondLastName': secondLastName,
    'email': email,
    'roles': roles,
    'status': status,
    'usedSpace': usedSpace,
    'totalCapacity': totalCapacity,
    'createdDate': createdDate,
    'updatedDate': updatedDate,
    'lastSessionDate': lastSessionDate,
  };
}
