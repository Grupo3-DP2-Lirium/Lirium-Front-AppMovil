class Reminder {
  final int? id;
  final String title;
  final String? description;
  final DateTime notificationDate;
  final bool active;
  final DateTime createdDate;
  final DateTime? updatedDate;

  Reminder({
    this.id,
    required this.title,
    this.description,
    required this.notificationDate,
    required this.active,
    required this.createdDate,
    this.updatedDate,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['idReminder'],
      title: json['title'],
      description: json['description'],
      notificationDate: DateTime.parse(json['notificationDate']),
      active: json['active'],
      createdDate: DateTime.parse(json['createdDate']),
      updatedDate: json['updatedDate'] != null 
          ? DateTime.parse(json['updatedDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'idReminder': id,
      'title': title,
      'description': description,
      'notificationDate': notificationDate.toIso8601String(),
      'active': active,
      'createdDate': createdDate.toIso8601String(),
      if (updatedDate != null) 'updatedDate': updatedDate!.toIso8601String(),
    };
  }

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? notificationDate,
    bool? active,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      notificationDate: notificationDate ?? this.notificationDate,
      active: active ?? this.active,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}