class CapsuleFilterModel {
  final String id;
  final String name;
  final String description;

  CapsuleFilterModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CapsuleFilterModel.fromJson(Map<String, dynamic> json) {
    return CapsuleFilterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}