class QuestionResponse {
  final String id;
  final String text;
  final String categoryId;
  final bool isPredefined;

  QuestionResponse({
    required this.id,
    required this.text,
    required this.categoryId,
    required this.isPredefined,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      categoryId: json['categoryId'] ?? '',
      isPredefined: json['isPredefined'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'categoryId': categoryId,
      'isPredefined': isPredefined,
    };
  }
}