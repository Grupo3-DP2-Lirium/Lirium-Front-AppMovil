import 'package:flutter/widgets.dart';

class File {
  final String id;
  final String name;
  final String originalName;
  final String type;
  final String mimeType;
  final String url;
  final double size;
  final DateTime uploadedDate;
  final Key key;

  File({
    required this.id,
    required this.name,
    required this.originalName,
    required this.type,
    required this.mimeType,
    required this.url,
    required this.size,
    required this.uploadedDate,
  }) : key = UniqueKey();

  bool get isImage => mimeType.startsWith("image/");
  bool get isVideo => mimeType.startsWith("video/");
  bool get isAudio => mimeType.startsWith("audio/");
}
