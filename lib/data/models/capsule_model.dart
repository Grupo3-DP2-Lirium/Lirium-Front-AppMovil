class CapsuleModel {
  final String idCapsule;
  final String memorialId;
  final String memorialName;
  final String userPrompt;
  final String title;
  final String? description;
  final String? musicTrack;
  final String filter;
  final String status;
  final int progress;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int? videoSize;
  final int? videoDuration;
  final int? totalMemories;
  final String? errorMessage;
  final DateTime createdDate;
  final DateTime? processingCompleted;
  final DateTime? publishedDate;
  final DateTime? updatedDate;

  CapsuleModel({
    required this.idCapsule,
    required this.memorialId,
    required this.memorialName,
    required this.userPrompt,
    required this.title,
    this.description,
    this.musicTrack,
    required this.filter,
    required this.status,
    required this.progress,
    this.videoUrl,
    this.thumbnailUrl,
    this.videoSize,
    this.videoDuration,
    this.totalMemories,
    this.errorMessage,
    required this.createdDate,
    this.processingCompleted,
    this.publishedDate,
    this.updatedDate,
  });

  factory CapsuleModel.fromJson(Map<String, dynamic> json) {
    return CapsuleModel(
      idCapsule: json['idCapsule'] ?? '',
      memorialId: json['memorialId'] ?? '',
      memorialName: json['memorialName'] ?? '',
      userPrompt: json['userPrompt'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      musicTrack: json['musicTrack'],
      filter: json['filter'] ?? 'NATURAL',
      status: json['status'] ?? 'DRAFT',
      progress: json['progress'] ?? 0,
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      videoSize: json['videoSize'],
      videoDuration: json['videoDuration'],
      totalMemories: json['totalMemories'],
      errorMessage: json['errorMessage'],
      createdDate: DateTime.parse(json['createdDate']),
      processingCompleted: json['processingCompleted'] != null
          ? DateTime.parse(json['processingCompleted'])
          : null,
      publishedDate: json['publishedDate'] != null
          ? DateTime.parse(json['publishedDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCapsule': idCapsule,
      'memorialId': memorialId,
      'memorialName': memorialName,
      'userPrompt': userPrompt,
      'title': title,
      'description': description,
      'musicTrack': musicTrack,
      'filter': filter,
      'status': status,
      'progress': progress,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'videoSize': videoSize,
      'videoDuration': videoDuration,
      'totalMemories': totalMemories,
      'errorMessage': errorMessage,
      'createdDate': createdDate.toIso8601String(),
      'processingCompleted': processingCompleted?.toIso8601String(),
      'publishedDate': publishedDate?.toIso8601String(),
      'updatedDate': updatedDate?.toIso8601String(),
    };
  }

  // Getters de estado
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
        return 'Desconocido';
    }
  }

  String get filterText {
    switch (filter) {
      case 'VIVID':
        return 'Vivid';
      case 'DRAMATIC':
        return 'Dramatic';
      case 'YELLOW':
        return 'Yellow';
      case 'MONO':
        return 'Mono';
      case 'SILVERTONE':
        return 'Silvertone';
      case 'NATURAL':
        return 'Natural';
      default:
        return 'Natural';
    }
  }

  String get durationFormatted {
    if (videoDuration == null) return '--:--';
    final minutes = videoDuration! ~/ 60;
    final seconds = videoDuration! % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sizeFormatted {
    if (videoSize == null) return '0 MB';
    final mb = videoSize! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}