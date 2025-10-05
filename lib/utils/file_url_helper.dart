// utils/file_url_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/file_response.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';

class FileUrlHelper {

  // Para emulador Android:
  static const String baseUrl = 'http://10.0.2.2:8080';

  /// Construye la URL completa para descargar un archivo
  static String getFileUrl({
    required String fullPath, // Ruta completa con el archivo o URL de Azure
    required String fileName,
  }) {
    // Si ya es una URL completa de Azure o cualquier servicio en la nube, devolverla directamente
    if (fullPath.startsWith('https://') || fullPath.startsWith('http://')) {
      print('Using direct URL: $fullPath');
      return fullPath;
    }

    // Si no, construir URL local para desarrollo
    // Separar la ruta del archivo
    String directoryPath = fullPath;
    if (fullPath.endsWith('\\$fileName')) {
      directoryPath = fullPath.substring(0, fullPath.length - fileName.length - 1);
    } else if (fullPath.endsWith('/$fileName')) {
      directoryPath = fullPath.substring(0, fullPath.length - fileName.length - 1);
    }

    final encodedPath = Uri.encodeComponent(directoryPath);
    final encodedName = Uri.encodeComponent(fileName);

    final url = '$baseUrl/api/files/download?path=$encodedPath&name=$encodedName';

    print('Full Path: $fullPath');
    print('Directory: $directoryPath');
    print('FileName: $fileName');
    print('Generated local URL: $url');

    return url;
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



// Extensión para MemoryResponse
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
  String? get firstImageUrl => firstImage?.downloadUrl;

  /// Cuenta total de archivos multimedia
  int get mediaCount => images.length + videos.length + audios.length;
}