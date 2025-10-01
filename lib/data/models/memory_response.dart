// models/memory_response.dart
class FileResponse {
  final String idFile;
  final String fileName;
  final String originalFileName;
  final String fileType; // "image" | "video" | "audio" | ...
  final String mimeType;
  final String fileUrl; // Ojo: viene como ruta relativa
  final double fileSize;
  final DateTime uploadedDate;

  FileResponse({
    required this.idFile,
    required this.fileName,
    required this.originalFileName,
    required this.fileType,
    required this.mimeType,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedDate,
  });

  factory FileResponse.fromJson(Map<String, dynamic> j) => FileResponse(
    idFile: j['idFile'],
    fileName: j['fileName'],
    originalFileName: j['originalFileName'],
    fileType: j['fileType'],
    mimeType: j['mimeType'],
    fileUrl: j['fileUrl'],
    fileSize: (j['fileSize'] as num).toDouble(),
    uploadedDate: DateTime.parse(j['uploadedDate']),
  );
}


class MemoryResponse {
  final String idMemory;
  final String type;
  final String title;
  final String description;
  final DateTime? photoDate;
  final String? location;
  final bool visible;
  final List<String> tags;
  final String? associatedQuestion;
  final List<FileResponse> files;
  final double? totalUsedSpace;
  final DateTime createdDate;

  MemoryResponse({
    required this.idMemory,
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

  factory MemoryResponse.fromJson(Map<String, dynamic> j) => MemoryResponse(
    idMemory: j['idMemory'],
    type: j['type'],
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    photoDate: j['photoDate'] != null ? DateTime.parse(j['photoDate']) : null,
    location: j['location'],
    visible: j['visible'] ?? true,
    tags: (j['tags'] as List?)?.cast<String>() ?? const [],
    associatedQuestion: j['associatedQuestion'],
    files: ((j['files'] as List?) ?? [])
        .map((e) => FileResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalUsedSpace: j['totalUsedSpace'] == null ? null : (j['totalUsedSpace'] as num).toDouble(),
    createdDate: DateTime.parse(j['createdDate']),
  );
}

// Un contenedor de paginación simple (solo lo que necesitamos)
class PageMemoryResponse {
  final List<MemoryResponse> content;
  final int totalElements;
  final int totalPages;
  final int number; // página actual

  PageMemoryResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
  });

  factory PageMemoryResponse.fromJson(Map<String, dynamic> j) => PageMemoryResponse(
    content: ((j['content'] as List?) ?? [])
        .map((e) => MemoryResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalElements: j['totalElements'] ?? 0,
    totalPages: j['totalPages'] ?? 0,
    number: j['number'] ?? 0,
  );
}
