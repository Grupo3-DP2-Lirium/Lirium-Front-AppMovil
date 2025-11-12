class CapsuleRequestModel {
  final String memorialId;
  final String userPrompt;
  final String title;
  final String? description;
  final String? musicTrack;
  final String filter;

  CapsuleRequestModel({
    required this.memorialId,
    required this.userPrompt,
    required this.title,
    this.description,
    this.musicTrack,
    this.filter = 'NATURAL',
  });

  Map<String, dynamic> toJson() {
    return {
      'memorialId': memorialId,
      'userPrompt': userPrompt,
      'title': title,
      'description': description,
      'musicTrack': musicTrack,
      'filter': filter,
    };
  }
}