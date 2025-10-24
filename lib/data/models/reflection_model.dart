class ReflectionModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdDate;
  final List<ReflectionFile> attachedFiles;

  ReflectionModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdDate,
    this.attachedFiles = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdDate': createdDate.toIso8601String(),
    'attachedFiles': attachedFiles.map((f) => f.toJson()).toList(),
  };

  factory ReflectionModel.fromJson(Map<String, dynamic> json) => ReflectionModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createdDate: DateTime.parse(json['createdDate']),
    attachedFiles: (json['attachedFiles'] as List?)
        ?.map((f) => ReflectionFile.fromJson(f))
        .toList() ?? [],
  );

  ReflectionModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdDate,
    List<ReflectionFile>? attachedFiles,
  }) => ReflectionModel(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdDate: createdDate ?? this.createdDate,
    attachedFiles: attachedFiles ?? this.attachedFiles,
  );
}

class ReflectionFile {
  final String id;
  final String path;
  final String name;
  final ReflectionFileType type;
  final int sizeInBytes;

  ReflectionFile({
    required this.id,
    required this.path,
    required this.name,
    required this.type,
    required this.sizeInBytes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'name': name,
    'type': type.toString(),
    'sizeInBytes': sizeInBytes,
  };

  factory ReflectionFile.fromJson(Map<String, dynamic> json) => ReflectionFile(
    id: json['id'],
    path: json['path'],
    name: json['name'],
    type: ReflectionFileType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => ReflectionFileType.image,
    ),
    sizeInBytes: json['sizeInBytes'],
  );

  bool get isImage => type == ReflectionFileType.image;
  bool get isAudio => type == ReflectionFileType.audio;
  bool get isVideo => type == ReflectionFileType.video;
}

enum ReflectionFileType {
  image,
  audio,
  video,
}

// Enum para el tipo de usuario
enum UserType {
  free,
  premium,
}