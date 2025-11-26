import 'file_response.dart';

class UserResponse {
  final String email;
  final String fullName;
  final String name;
  final double usedSpace;
  final double totalCapacity;
  final int documentariesPurchased;
  final int documentariesAvailable;
  final FileResponse? profilePhoto;

  UserResponse({
    required this.email,
    required this.fullName,
    required this.name,
    required this.usedSpace,
    required this.totalCapacity,
    required this.documentariesPurchased,
    required this.documentariesAvailable,
    this.profilePhoto,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      email: json["email"] ?? "",
      fullName: json["fullName"] ?? "",
      name: json["name"] ?? "",
      usedSpace: (json["usedSpace"] as num?)?.toDouble() ?? 0.0,
      totalCapacity: (json["totalCapacity"] as num?)?.toDouble() ?? 15.0,
      documentariesPurchased: json["documentariesPurchased"] ?? 0,
      documentariesAvailable: json["documentariesAvailable"] ?? 0,
      profilePhoto: json["profilePhoto"] != null
          ? FileResponse.fromJson(json["profilePhoto"])
          : null,
    );
  }
}
