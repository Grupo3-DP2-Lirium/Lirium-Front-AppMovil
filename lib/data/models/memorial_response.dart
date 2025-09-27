class MemorialResponse {
  final String id;
  final String name;
  final String description;
  final bool isCollaborative;
  final String userId;
  final DateTime createdDate;
  final DateTime updatedDate;

  MemorialResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.isCollaborative,
    required this.userId,
    required this.createdDate,
    required this.updatedDate,
  });

  factory MemorialResponse.fromJson(Map<String, dynamic> json) {
    return MemorialResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isCollaborative: json['isCollaborative'] ?? false,
      userId: json['userId'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
      updatedDate: DateTime.parse(json['updatedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isCollaborative': isCollaborative,
      'userId': userId,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
    };
  }
}