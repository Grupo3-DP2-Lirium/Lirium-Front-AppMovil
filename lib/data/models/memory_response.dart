import 'package:flutter/cupertino.dart';
import 'package:flutter_frontend/utils/file_url_helper.dart';

class FileResponse {
  final String idFile;
  final String fileName;
  final String originalFileName;
  final String fileType; // "image" | "video" | "audio" | ...
  final String mimeType;
  final String fileUrl; // Ruta relativa desde el backend
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

  //Obtiene la URL completa para descargar el archivo
  String get downloadUrl {
    // Si fileUrl ya es una URL completa de Azure, usarla directamente
    if (fileUrl.startsWith('https://') || fileUrl.startsWith('http://')) {
      return fileUrl;
    }
    
    // Si no, usar el helper para construir URL local
    return FileUrlHelper.getFileUrl(
      fullPath: fileUrl,
      fileName: fileName,
    );
  }

  // Verifica si es una imagen
  bool get isImage => FileUrlHelper.isImage(mimeType);

  // Verifica si es un video
  bool get isVideo => FileUrlHelper.isVideo(mimeType);

  // Verifica si es audio
  bool get isAudio => FileUrlHelper.isAudio(mimeType);

  // btiene el icono apropiado
  IconData get icon => FileUrlHelper.getFileIcon(mimeType);
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

  List<FileResponse> get images =>
      files.where((f) => f.isImage).toList();

  List<FileResponse> get videos =>
      files.where((f) => f.isVideo).toList();

  List<FileResponse> get audios =>
      files.where((f) => f.isAudio).toList();

  // Obtiene la primera imagen (para thumbnail)
  FileResponse? get firstImage {
    final imgs = images;
    return imgs.isNotEmpty ? imgs.first : null;
  }

  // URL de la primera imagen (para usar en MemoryCard)
  String? get firstImageUrl => firstImage?.downloadUrl;

  // Cuenta total de archivos multimedia
  int get mediaCount => files.length;

  // Lista de tipos de media que tiene (para el indicador)
  List<String> get mediaTypes {
    final types = <String>[];
    if (images.isNotEmpty) types.add('image');
    if (videos.isNotEmpty) types.add('video');
    if (audios.isNotEmpty) types.add('audio');
    return types;
  }
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