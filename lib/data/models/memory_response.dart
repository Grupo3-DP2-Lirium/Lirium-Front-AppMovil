import 'package:flutter_frontend/data/models/file_response.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';


class MemoryResponse {
  final String idMemory;
  final String type;
  final String title;
  final String description;
  final DateTime? photoDate;
  final String? location;
  final bool visible;
  final double? longitude;
  final double? latitude;
  final List<String> tags;
  final String? associatedQuestion;
  final List<FileResponse> files;
  final double? totalUsedSpace;
  final DateTime createdDate;
  final DateTime? updateDate;

  MemoryResponse({
    required this.idMemory,
    required this.type,
    required this.title,
    required this.description,
    required this.photoDate,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.visible,
    required this.tags,
    required this.associatedQuestion,
    required this.files,
    required this.totalUsedSpace,
    required this.createdDate,
    required this.updateDate
  });

  factory MemoryResponse.fromJson(Map<String, dynamic> j) => MemoryResponse(
    idMemory: j['idMemory'],
    type: j['type'],
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    photoDate: j['photoDate'] != null ? DateTime.parse(j['photoDate']) : null,
    location: j['location'],
    latitude: j['latitude'] != null ? (j['latitude'] as num).toDouble() : null,
    longitude: j['longitude'] != null ? (j['longitude'] as num).toDouble() : null,
    visible: j['visible'] ?? true,
    tags: (j['tags'] as List?)?.cast<String>() ?? const [],
    associatedQuestion: j['associatedQuestion'],
    files: ((j['files'] as List?) ?? [])
        .map((e) => FileResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalUsedSpace: j['totalUsedSpace'] == null ? null : (j['totalUsedSpace'] as num).toDouble(),
    createdDate: DateTime.parse(j['createdDate']),
    updateDate: j['updateDate'] != null ? DateTime.parse(j['updateDate']) : null,
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

  /// Convierte la respuesta del backend a la entidad `Memory`
  Memory toEntity() {
    return Memory(
      id: idMemory,
      type: type,
      title: title,
      description: description,
      photoDate: photoDate,
      location: location,
      latitude: latitude,
      longitude: longitude,
      visible: visible,
      tags: tags,
      associatedQuestion: associatedQuestion,
      files: files.map((f) => f.toEntity()).toList(),
      totalUsedSpace: totalUsedSpace,
      createdDate: createdDate,
      updateDate: updateDate
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMemory': idMemory,
      'type': type,
      'title': title,
      'description': description,
      'photoDate': photoDate?.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'visible': visible,
      'tags': tags,
      'associatedQuestion': associatedQuestion,
      'files': files.map((f) => f.toJson()).toList(),
      'totalUsedSpace': totalUsedSpace,
      'createdDate': createdDate.toIso8601String(),
    };
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