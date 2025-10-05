class File{
  final String id;
  final String name;
  final String originalName;
  final String type;
  final String mimeType;
  final String url;
  final double size;
  final DateTime uploadedDate;
  final String? contentBase64;

  File({
    required this.id,
    required this.name,
    required this.originalName,
    required this.type,
    required this.mimeType,
    required this.url,
    required this.size,
    required this.uploadedDate,
    this.contentBase64,
  });

  bool get isImage => mimeType.startsWith("image/");
}