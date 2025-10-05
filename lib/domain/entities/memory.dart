import 'file.dart';

class Memory {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime? photoDate;
  final String? location;
  final bool visible;
  final List<String> tags;
  final String? associatedQuestion;
  final List<File> files;
  final double? totalUsedSpace;
  final DateTime createdDate;

  Memory({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.photoDate,
    required this.location,
    required this.visible,
    required this.tags,
    required this.associatedQuestion,
    required this.files,
    required this.totalUsedSpace,
    required this.createdDate,
  });

  Memory copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    DateTime? photoDate,
    String? location,
    bool? visible,
    List<String>? tags,
    String? associatedQuestion,
    List<File>? files,
    double? totalUsedSpace,
    DateTime? createdDate,
  }) {
    return Memory(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      photoDate: photoDate ?? this.photoDate,
      location: location ?? this.location,
      visible: visible ?? this.visible,
      tags: tags ?? this.tags,
      associatedQuestion: associatedQuestion ?? this.associatedQuestion,
      files: files ?? this.files,
      totalUsedSpace: totalUsedSpace ?? this.totalUsedSpace,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  int get mediaCount => files.length;

  List<File> get images => files.where((f) => f.isImage).toList();

  List<File> get videos => files.where((f) => f.mimeType.startsWith("video/")).toList();

  List<File> get audios => files.where((f) => f.mimeType.startsWith("audio/")).toList();

  String? get firstImageUrl => images.isNotEmpty ? images.first.url : null;
}