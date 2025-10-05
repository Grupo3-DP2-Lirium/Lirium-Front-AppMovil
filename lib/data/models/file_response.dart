import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/utils/file_url_helper.dart';

class FileResponse {
  final String idFile;
  final String fileName;
  final String originalFileName;
  final String fileType; // "image" | "video" | "audio" | ...
  final String mimeType;
  final String fileUrl; // Puede ser ruta local o URL completa
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
    required this.uploadedDate
  });

  factory FileResponse.fromJson(Map<String, dynamic> j) {
    return FileResponse(
      idFile: j['idFile'] ?? '',
      fileName: j['fileName'] ?? '',
      originalFileName: j['originalFileName'] ?? '',
      fileType: j['fileType'] ?? '',
      mimeType: j['mimeType'] ?? '',
      fileUrl: j['fileUrl'] ?? '',
      fileSize: (j['fileSize'] ?? 0).toDouble(),
      uploadedDate: DateTime.parse(j['uploadedDate'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idFile': idFile,
      'fileName': fileName,
      'originalFileName': originalFileName,
      'fileType': fileType,
      'mimeType': mimeType,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'uploadedDate': uploadedDate.toIso8601String()
    };
  }

  /// Convierte la respuesta del backend a la entidad `File`
  File toEntity() {
    return File(
      id: idFile,
      name: fileName,
      originalName: originalFileName,
      type: fileType,
      mimeType: mimeType,
      url: fileUrl,
      size: fileSize,
      uploadedDate: uploadedDate
    );
  }

  /// Devuelve la URL completa (si ya es una URL externa, la usa directamente)
  String get downloadUrl {
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    }
    return FileUrlHelper.getFileUrl(fullPath: fileUrl, fileName: fileName);
  }

  /// Verifica si el archivo es imagen
  bool get isImage => FileUrlHelper.isImage(mimeType);

  /// Verifica si el archivo es video
  bool get isVideo => FileUrlHelper.isVideo(mimeType);

  /// Verifica si el archivo es audio
  bool get isAudio => FileUrlHelper.isAudio(mimeType);

  /// Obtiene el icono apropiado para el tipo MIME
  IconData get icon => FileUrlHelper.getFileIcon(mimeType);
}
