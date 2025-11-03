enum NotificationType {
  SYSTEM,              // Notificaciones generales del sistema
  MEMORIAL_SHARED,     // Cuando se comparte un memorial
  COMMENT,             // Cuando alguien comenta
  REMINDER,            // Recordatorios programados
  SUBSCRIPTION,        // Notificaciones de suscripción (activación, renovación, vencimiento)
  PAYMENT,             // Notificaciones de pagos (éxito, fallo)
  DOCUMENTARY,         // Notificaciones relacionadas con documentales
  REFLECTION,          // Notificaciones de reflexiones personales
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
      // ✅ CRÍTICO: El backend envía fechas SIN zona horaria, asumimos UTC
      createdDate: DateTime.parse(json['createdDate']),
      readDate: json['readDate'] != null 
          ? DateTime.parse(json['readDate'])
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
      'createdDate': createdDate.toIso8601String(),
      if (readDate != null) 'readDate': readDate!.toIso8601String(),
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
      case 'SYSTEM':
        return NotificationType.SYSTEM;
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