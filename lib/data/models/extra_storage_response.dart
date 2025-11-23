class ExtraStorageResponse {
  final String idExtraPlan;
  final String planName;
  final double additionalStorageGb;
  final String status;
  final DateTime startDate;

  ExtraStorageResponse({
    required this.idExtraPlan,
    required this.planName,
    required this.additionalStorageGb,
    required this.status,
    required this.startDate,
  });

  factory ExtraStorageResponse.fromJson(Map<String, dynamic> json) {
    return ExtraStorageResponse(
      idExtraPlan: json['extraPlanId'],
      planName: json['planName'] ?? '',
      additionalStorageGb: (json['additionalStorageGb'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      startDate: DateTime.parse(json['startDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extraPlanId': idExtraPlan,
      'planName': planName,
      'additionalStorageGb': additionalStorageGb,
      'status': status,
      'startDate': startDate.toIso8601String(),
    };
  }
}
