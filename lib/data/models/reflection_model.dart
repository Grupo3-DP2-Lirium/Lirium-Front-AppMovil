class ReflectionModel {
  final String id;
  final String type;
  final String title;
  final String content;
  final DateTime? photoDate;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool visible;
  final List<String> tags;
  final String? associatedQuestion;
  final List<ReflectionFile> attachedFiles;
  final double? totalUsedSpace;
  final DateTime createdDate;
  final List<String> categorias;
  final List<String> momentos;
  final bool esLineaTiempo;

  ReflectionModel({
    this.id = '',
    this.type = 'REFLECTION',
    required this.title,
    required this.content,
    this.photoDate,
    this.location,
    this.latitude,
    this.longitude,
    this.visible = true,
    this.tags = const [],
    this.associatedQuestion,
    this.attachedFiles = const [],
    this.totalUsedSpace,
    required this.createdDate,
    this.categorias = const [],
    this.momentos = const [],
    this.esLineaTiempo = false,
  });

  // Para crear reflexión (request al backend)
  Map<String, dynamic> toCreateJson() => {
    'type': type,
    'title': title,
    'description': content,
    'photoDate': photoDate?.toIso8601String().split('T').first ?? DateTime.now().toIso8601String().split('T').first,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'visible': visible,
    'tags': tags,
    'associatedQuestion': associatedQuestion,
    'esLineaTiempo': esLineaTiempo,
  };

  // Para actualizar reflexión (request al backend)
  Map<String, dynamic> toUpdateJson() => {
    'idMemory': id,
    'title': title,
    'description': content,
    'photoDate': photoDate?.toIso8601String().split('T').first ?? DateTime.now().toIso8601String().split('T').first,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'visible': visible,
    'tags': tags,
    'associatedQuestion': associatedQuestion,
    'esLineaTiempo': esLineaTiempo,
  };

  // Desde respuesta del backend
  factory ReflectionModel.fromJson(Map<String, dynamic> json) => ReflectionModel(
    id: json['idMemory'] ?? json['id'] ?? '',
    type: json['type'] ?? 'REFLECTION',
    title: json['title'] ?? '',
    content: json['description'] ?? json['content'] ?? '',
    photoDate: json['photoDate'] != null 
        ? DateTime.tryParse(json['photoDate']) 
        : null,
    location: json['location'], // Puede ser null
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    visible: json['visible'] ?? true,
    tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    associatedQuestion: json['associatedQuestion'], // Puede ser null
    attachedFiles: json['files'] != null 
        ? (json['files'] as List<dynamic>)
            .map((file) => ReflectionFile.fromJson(file))
            .toList()
        : [],
    totalUsedSpace: json['totalUsedSpace']?.toDouble(),
    createdDate: json['createdDate'] != null 
        ? DateTime.tryParse(json['createdDate']) ?? DateTime.now()
        : DateTime.now(),
    categorias: json['categorias'] != null ? List<String>.from(json['categorias']) : [],
    momentos: json['momentos'] != null ? List<String>.from(json['momentos']) : [],
    esLineaTiempo: json['esLineaTiempo'] ?? false,
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
    type: type,
    photoDate: photoDate,
    location: location,
    latitude: latitude,
    longitude: longitude,
    visible: visible,
    tags: tags,
    associatedQuestion: associatedQuestion,
    totalUsedSpace: totalUsedSpace,
    categorias: categorias,
    momentos: momentos,
    esLineaTiempo: esLineaTiempo,
  );
}

class ReflectionFile {
  final String id;
  final String fileName;
  final String originalName;
  final String fileType;
  final int fileSize;
  final String downloadUrl;
  final String? localPath; // Para archivos locales antes de subir

  ReflectionFile({
    required this.id,
    required this.fileName,
    required this.originalName,
    required this.fileType,
    required this.fileSize,
    required this.downloadUrl,
    this.localPath,
  });

  // Factory desde respuesta del backend
  factory ReflectionFile.fromJson(Map<String, dynamic> json) => ReflectionFile(
    id: json['idFile'] ?? json['id'] ?? '',
    fileName: json['fileName'] ?? '',
    originalName: json['originalFileName'] ?? json['originalName'] ?? json['name'] ?? '',
    fileType: json['fileType'] ?? json['mimeType'] ?? '',
    fileSize: (json['fileSize'] is double) 
        ? (json['fileSize'] * 1024 * 1024).round() // Convertir MB a bytes
        : (json['fileSize'] ?? 0),
    downloadUrl: json['fileUrl'] ?? json['downloadUrl'] ?? '',
  );

  // Factory para archivos locales (antes de subir)
  factory ReflectionFile.fromLocalFile({
    required String localPath,
    required String originalName,
    required String fileType,
    required int fileSize,
  }) => ReflectionFile(
    id: ''  ,
    fileName: originalName,
    originalName: originalName,
    fileType: fileType,
    fileSize: fileSize,
    downloadUrl: '',
    localPath: localPath,
  );

  Map<String, dynamic> toJson() => {
    'idFile': id,
    'fileName': fileName,
    'originalName': originalName,
    'fileType': fileType,
    'fileSize': fileSize,
    'downloadUrl': downloadUrl,
  };

  bool get isImage {
    final type = fileType.toLowerCase();
    final name = fileName.toLowerCase();
    final originalNameLower = originalName.toLowerCase();
    
    return type.contains('image') || 
           type.contains('jpg') || 
           type.contains('png') || 
           type.contains('jpeg') ||
           name.endsWith('.jpg') ||
           name.endsWith('.jpeg') ||
           name.endsWith('.png') ||
           name.endsWith('.gif') ||
           name.endsWith('.bmp') ||
           name.endsWith('.webp') ||
           originalNameLower.endsWith('.jpg') ||
           originalNameLower.endsWith('.jpeg') ||
           originalNameLower.endsWith('.png') ||
           originalNameLower.endsWith('.gif') ||
           originalNameLower.endsWith('.bmp') ||
           originalNameLower.endsWith('.webp');
  }
  
  bool get isAudio {
    final type = fileType.toLowerCase();
    final name = fileName.toLowerCase();
    final originalNameLower = originalName.toLowerCase();
    
    return type.contains('audio') || 
           type.contains('mp3') || 
           type.contains('m4a') || 
           type.contains('wav') ||
           name.endsWith('.mp3') ||
           name.endsWith('.m4a') ||
           name.endsWith('.wav') ||
           name.endsWith('.aac') ||
           originalNameLower.endsWith('.mp3') ||
           originalNameLower.endsWith('.m4a') ||
           originalNameLower.endsWith('.wav') ||
           originalNameLower.endsWith('.aac');
  }
  
  bool get isVideo {
    final type = fileType.toLowerCase();
    final name = fileName.toLowerCase();
    final originalNameLower = originalName.toLowerCase();
    
    return type.contains('video') || 
           type.contains('mp4') || 
           type.contains('mov') || 
           type.contains('avi') ||
           name.endsWith('.mp4') ||
           name.endsWith('.mov') ||
           name.endsWith('.avi') ||
           name.endsWith('.mkv') ||
           originalNameLower.endsWith('.mp4') ||
           originalNameLower.endsWith('.mov') ||
           originalNameLower.endsWith('.avi') ||
           originalNameLower.endsWith('.mkv');
  }

  // Getter para obtener el tipo como enum (para compatibilidad)
  ReflectionFileType get type {
    if (isImage) return ReflectionFileType.image;
    if (isAudio) return ReflectionFileType.audio;
    if (isVideo) return ReflectionFileType.video;
    return ReflectionFileType.image; // default
  }
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