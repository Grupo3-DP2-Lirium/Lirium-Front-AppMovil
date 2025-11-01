import 'file.dart';

class Memory {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime? photoDate;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool visible;
  final List<String> tags;
  final String? associatedQuestion;
  final List<File> files;
  final double? totalUsedSpace;
  final DateTime createdDate;
  final DateTime? updateDate;

  Memory({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.photoDate,
    required this.location,
    this.latitude,
    this.longitude,
    required this.visible,
    required this.tags,
    required this.associatedQuestion,
    required this.files,
    required this.totalUsedSpace,
    required this.createdDate,
    required this.updateDate
  });

  Memory copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    DateTime? photoDate,
    String? location,
    double? latitude,
    double? longitude,
    bool? visible,
    List<String>? tags,
    String? associatedQuestion,
    List<File>? files,
    double? totalUsedSpace,
    DateTime? createdDate,
    DateTime? updateDate
  }) {
    return Memory(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      photoDate: photoDate ?? this.photoDate,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visible: visible ?? this.visible,
      tags: tags ?? this.tags,
      associatedQuestion: associatedQuestion ?? this.associatedQuestion,
      files: files ?? this.files,
      totalUsedSpace: totalUsedSpace ?? this.totalUsedSpace,
      createdDate: createdDate ?? this.createdDate,
      updateDate: updateDate ?? this.updateDate,
    );
  }

  int get mediaCount => files.length;

  List<File> get images => files.where((f) => f.isImage).toList();

  List<File> get videos => files.where((f) => f.mimeType.startsWith("video/")).toList();

  List<File> get audios => files.where((f) => f.mimeType.startsWith("audio/")).toList();

  String? get firstImageUrl => images.isNotEmpty ? images.first.url : null;
}