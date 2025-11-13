class DocumentaryModel {
  final String idDocumentary;
  final String memorialId;
  final String memorialName;
  final String title;
  final String description;

  // NUEVOS CAMPOS
  final String? narrativeFocus;
  final String? emotionalTone;
  final String? styleFilter;
  final String? thumbnailUrl;
  final DateTime? publishedDate;

  final String status; // DRAFT, PROCESSING, COMPLETED, PUBLISHED, FAILED, CANCELLED
  final int progress;
  final String? videoUrl;
  final int? videoSize;
  final int? videoDuration;
  final int totalMemories;
  final String? errorMessage;
  final DateTime createdDate;
  final DateTime? processingCompleted;
  final DateTime? updatedDate;

  DocumentaryModel({
    required this.idDocumentary,
    required this.memorialId,
    required this.memorialName,
    required this.title,
    required this.description,
    this.narrativeFocus,
    this.emotionalTone,
    this.styleFilter,
    this.thumbnailUrl,
    this.publishedDate,
    required this.status,
    required this.progress,
    this.videoUrl,
    this.videoSize,
    this.videoDuration,
    required this.totalMemories,
    this.errorMessage,
    required this.createdDate,
    this.processingCompleted,
    this.updatedDate,
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
      narrativeFocus: json['narrativeFocus'],
      emotionalTone: json['emotionalTone'],
      styleFilter: json['styleFilter'],
      thumbnailUrl: json['thumbnailUrl'],
      publishedDate: json['publishedDate'] != null ? parseDate(json['publishedDate']) : null,
      status: json['status'] ?? 'DRAFT',
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
      updatedDate: json['updatedDate'] != null ? parseDate(json['updatedDate']) : null,
    );
  }

  // Helpers
  bool get isDraft => status == 'DRAFT';
  bool get isProcessing => status == 'PROCESSING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isPublished => status == 'PUBLISHED';
  bool get isFailed => status == 'FAILED';
  bool get isCancelled => status == 'CANCELLED';

  String get statusText {
    switch (status) {
      case 'DRAFT':
        return 'Borrador';
      case 'PROCESSING':
        return 'Procesando';
      case 'COMPLETED':
        return 'Completado';
      case 'PUBLISHED':
        return 'Publicado';
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
