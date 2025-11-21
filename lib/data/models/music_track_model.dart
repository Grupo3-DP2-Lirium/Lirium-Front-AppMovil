class MusicTrackModel {
  final String id;
  final String previewId;
  final String name;
  final String description;
  final String duration;
  final String mood;

  MusicTrackModel({
    required this.id,
    required this.previewId,
    required this.name,
    required this.description,
    required this.duration,
    required this.mood,
  });

  factory MusicTrackModel.fromJson(Map<String, dynamic> json) {
    return MusicTrackModel(
      id: json['id'] ?? '',
      previewId: json['previewId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      mood: json['mood'] ?? '',
    );
  }
}