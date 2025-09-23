// utils/file_url_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';

class FileUrlHelper {
  // Cambia esta URL por tu URL base real del servidor
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  /// Construye la URL completa del archivo
  static String getFileUrl(String fileUrl) {
    if (fileUrl.isEmpty) return '';

    // Si ya es una URL completa, devolverla tal como está
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    }

    // Si es una ruta relativa, construir la URL completa
    // Asegurar que baseUrl no termine con '/' y fileUrl no empiece con '/'
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanFileUrl = fileUrl.startsWith('/') ? fileUrl : '/$fileUrl';

    return '$cleanBaseUrl$cleanFileUrl';
  }

  /// Verifica si un archivo es una imagen basándose en su mimeType
  static bool isImage(String mimeType) {
    return mimeType.startsWith('image/');
  }

  /// Verifica si un archivo es un video basándose en su mimeType
  static bool isVideo(String mimeType) {
    return mimeType.startsWith('video/');
  }

  /// Verifica si un archivo es audio basándose en su mimeType
  static bool isAudio(String mimeType) {
    return mimeType.startsWith('audio/');
  }

  /// Obtiene el icono apropiado para un tipo de archivo
  static IconData getFileIcon(String mimeType) {
    if (isImage(mimeType)) return Icons.image;
    if (isVideo(mimeType)) return Icons.videocam;
    if (isAudio(mimeType)) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }
}

// Extensión para FileResponse para facilitar el acceso a las URLs
extension FileResponseExtension on FileResponse {
  /// Obtiene la URL completa del archivo
  String get fullUrl => FileUrlHelper.getFileUrl(fileUrl);

  /// Verifica si es una imagen
  bool get isImage => FileUrlHelper.isImage(mimeType);

  /// Verifica si es un video
  bool get isVideo => FileUrlHelper.isVideo(mimeType);

  /// Verifica si es audio
  bool get isAudio => FileUrlHelper.isAudio(mimeType);

  /// Obtiene el icono apropiado
  IconData get icon => FileUrlHelper.getFileIcon(mimeType);
}

// Extensión para MemoryResponse para facilitar el trabajo con archivos
extension MemoryResponseExtension on MemoryResponse {
  /// Obtiene solo las imágenes
  List<FileResponse> get images => files.where((f) => f.isImage).toList();

  /// Obtiene solo los videos
  List<FileResponse> get videos => files.where((f) => f.isVideo).toList();

  /// Obtiene solo los audios
  List<FileResponse> get audios => files.where((f) => f.isAudio).toList();

  /// Obtiene la primera imagen (para thumbnail)
  FileResponse? get firstImage {
    try {
      return images.first;
    } catch (e) {
      return null;
    }
  }

  /// URL de la primera imagen (para thumbnail)
  String? get firstImageUrl => firstImage?.fullUrl;

  /// Cuenta total de archivos multimedia
  int get mediaCount => images.length + videos.length + audios.length;
}