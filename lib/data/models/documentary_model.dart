class DocumentaryModel {
  final String idDocumentary;
  final String memorialId;
  final String memorialName;
  final String title;
  final String description;
  final String status; // PENDING, PROCESSING, COMPLETED, FAILED, CANCELLED
  final int progress;
  final String? videoUrl;
  final int? videoSize;
  final int? videoDuration;
  final int totalMemories;
  final String? errorMessage;
  final DateTime createdDate;
  final DateTime? processingCompleted;

  DocumentaryModel({
    required this.idDocumentary,
    required this.memorialId,
    required this.memorialName,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    this.videoUrl,
    this.videoSize,
    this.videoDuration,
    required this.totalMemories,
    this.errorMessage,
    required this.createdDate,
    this.processingCompleted,
  });

  factory DocumentaryModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String? raw) {
      if (raw == null || raw.isEmpty) return DateTime.now();
      return DateTime.parse(raw.replaceFirst(' ', 'T'));
    }

    return DocumentaryModel(
      idDocumentary: json['idDocumentary'] ?? '',
      memorialId: json['memorialId'] ?? '',
      memorialName: json['memorialName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      progress: json['progress'] ?? 0,
      videoUrl: json['videoUrl'],
      videoSize: json['videoSize'],
      videoDuration: json['videoDuration'],
      totalMemories: json['totalMemories'] ?? 0,
      errorMessage: json['errorMessage'],
      createdDate: parseDate(json['createdDate']),
      processingCompleted: json['processingCompleted'] != null
          ? parseDate(json['processingCompleted'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDocumentary': idDocumentary,
      'memorialId': memorialId,
      'memorialName': memorialName,
      'title': title,
      'description': description,
      'status': status,
      'progress': progress,
      'videoUrl': videoUrl,
      'videoSize': videoSize,
      'videoDuration': videoDuration,
      'totalMemories': totalMemories,
      'errorMessage': errorMessage,
      'createdDate': createdDate.toIso8601String(),
      'processingCompleted': processingCompleted?.toIso8601String(),
    };
  }

  // Helpers
  bool get isProcessing => status == 'PROCESSING' || status == 'PENDING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';

  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'En cola';
      case 'PROCESSING':
        return 'Procesando';
      case 'COMPLETED':
        return 'Completado';
      case 'FAILED':
        return 'Error';
      case 'CANCELLED':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String get durationFormatted {
    if (videoDuration == null) return '--:--';
    final minutes = videoDuration! ~/ 60;
    final seconds = videoDuration! % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get fileSizeFormatted {
    if (videoSize == null) return '--';
    final mb = videoSize! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}