import '../../domain/enums/memory_origin_type.dart';

class MemoryCreateRequest {
  final String memorialId;
  final MemoryOriginType type;
  final String title;
  final String? description;
  final DateTime photoDate;
  final String? location;
  final bool visible;
  final List<String> tags;
  final String? associatedQuestion;
  final int? questionId;
  final int? answerId;
  final double? latitude;
  final double? longitude;

  MemoryCreateRequest({
    required this.memorialId,
    required this.type,
    required this.title,
    this.description,
    required this.photoDate,
    this.location,
    this.latitude,
    this.longitude,
    this.visible = true,
    this.tags = const [],
    this.associatedQuestion,
    this.questionId,
    this.answerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'memorialId': memorialId,
      'type': type.value,
      'title': title,
      'description': description,
      'photoDate': photoDate.toIso8601String().split('T')[0], // Format as LocalDate
      'location': location,
      "latitude": latitude,
      "longitude": longitude,
      'visible': visible,
      'tags': tags,
      'associatedQuestion': associatedQuestion,
      'questionId': questionId,
      'answerId': answerId,
    };
  }
}