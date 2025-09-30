class FileResponseModel {
  final String idFile;
  final String fileName;
  final String originalFileName;
  final String fileType;
  final String mimeType;
  final String fileUrl;
  final double fileSize;
  final DateTime uploadedDate;
  final String? fileContentBase64;

  FileResponseModel({
    required this.idFile,
    required this.fileName,
    required this.originalFileName,
    required this.fileType,
    required this.mimeType,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedDate,
    this.fileContentBase64
  });

  factory FileResponseModel.fromJson(Map<String, dynamic> json) {
    return FileResponseModel(
      idFile: json['idFile'] ?? '',
      fileName: json['fileName'] ?? '',
      originalFileName: json['originalFileName'] ?? '',
      fileType: json['fileType'] ?? '',
      mimeType: json['mimeType'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileSize: (json['fileSize'] ?? 0).toDouble(),
      uploadedDate: DateTime.parse(json['uploadedDate']),
      fileContentBase64: json['fileContentBase64'],
    );
  }
}
