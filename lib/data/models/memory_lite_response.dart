class MemoryLiteResponse {
  final String idMemory;
  final String title;
  final String description;
  final DateTime? photoDate;
  final DateTime createdDate;
  final String? firstFileUrl;
  final String? fileType;

  MemoryLiteResponse({
    required this.idMemory,
    required this.title,
    required this.description,
    this.photoDate,
    required this.createdDate,
    this.firstFileUrl,
    this.fileType,
  });

  factory MemoryLiteResponse.fromJson(Map<String, dynamic> json) {
    return MemoryLiteResponse(
      idMemory: json['idMemory'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photoDate: json['photoDate'] != null
          ? DateTime.parse(json['photoDate'] as String)
          : null,
      createdDate: DateTime.parse(json['createdDate'] as String),
      firstFileUrl: json['firstFileUrl'] as String?,
      fileType: json['fileType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMemory': idMemory,
      'title': title,
      'description': description,
      'photoDate': photoDate?.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'firstFileUrl': firstFileUrl,
      'fileType': fileType,
    };
  }
}
