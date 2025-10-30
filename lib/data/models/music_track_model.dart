class MusicTrackModel {
  final String id;
  final String name;
  final String description;
  final String duration;
  final String mood;

  MusicTrackModel({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.mood,
  });

  factory MusicTrackModel.fromJson(Map<String, dynamic> json) {
    return MusicTrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      mood: json['mood'] ?? '',
    );
  }
}