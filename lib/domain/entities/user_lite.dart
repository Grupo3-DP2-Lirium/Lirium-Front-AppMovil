class UserLite {
  final String id;
  final String name;
  final String? profilePhotoUrl;

  UserLite({
    required this.id,
    required this.name,
    this.profilePhotoUrl,
  });
}