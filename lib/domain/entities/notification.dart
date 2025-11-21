enum NotificationType {
  SYSTEM,
  MEMORIAL_SHARED,
  COMMENT,
  REMINDER,
  SUBSCRIPTION,
  PAYMENT,
  DOCUMENTARY,
  REFLECTION,
  COLLABORATION
}

class AppNotification {
  final int? idNotification;
  final String title;
  final String message;
  final NotificationType type;
  final int? relatedEntityId;
  final bool isRead;
  final DateTime createdDate;
  final DateTime? readDate;

  AppNotification({
    this.idNotification,
    required this.title,
    required this.message,
    required this.type,
    this.relatedEntityId,
    required this.isRead,
    required this.createdDate,
    this.readDate,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      idNotification: json['idNotification'],
      title: json['title'],
      message: json['message'],
      type: _parseNotificationType(json['type']),
      relatedEntityId: json['relatedEntityId'],
      isRead: json['isRead'] ?? false,
      
      // ✅ SOLUCIÓN: Parse con .toUtc() explícito
      // El backend ahora envía fechas con 'Z' al final (ISO-8601 UTC)
      // DateTime.parse() las reconoce como UTC automáticamente
      createdDate: DateTime.parse(json['createdDate']).toUtc(),
      readDate: json['readDate'] != null 
          ? DateTime.parse(json['readDate']).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idNotification != null) 'idNotification': idNotification,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'relatedEntityId': relatedEntityId,
      'isRead': isRead,
      
      // ✅ Enviar en formato ISO-8601 UTC
      'createdDate': createdDate.toUtc().toIso8601String(),
      if (readDate != null) 'readDate': readDate!.toUtc().toIso8601String(),
    };
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'REMINDER':
        return NotificationType.REMINDER;
      case 'COMMENT':
        return NotificationType.COMMENT;
      case 'MEMORIAL_SHARED':
        return NotificationType.MEMORIAL_SHARED;
      case 'SUBSCRIPTION':
        return NotificationType.SUBSCRIPTION;
      case 'PAYMENT':
        return NotificationType.PAYMENT;
      case 'DOCUMENTARY':
        return NotificationType.DOCUMENTARY;
      case 'REFLECTION':
        return NotificationType.REFLECTION;
      case 'COLLABORATION':
        return NotificationType.COLLABORATION;
      case 'SYSTEM':
      default:
        return NotificationType.SYSTEM;
    }
  }

  AppNotification copyWith({
    int? idNotification,
    String? title,
    String? message,
    NotificationType? type,
    int? relatedEntityId,
    bool? isRead,
    DateTime? createdDate,
    DateTime? readDate,
  }) {
    return AppNotification(
      idNotification: idNotification ?? this.idNotification,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      isRead: isRead ?? this.isRead,
      createdDate: createdDate ?? this.createdDate,
      readDate: readDate ?? this.readDate,
    );
  }
}