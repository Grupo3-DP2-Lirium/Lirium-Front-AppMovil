import 'extra_storage_response.dart';

class SubscriptionResponse {
  final String? subscriptionId;  // null si es Free
  final String status;           // ACTIVE, NONE, CANCELLED, EXPIRED
  final String frequency;        // MONTHLY, YEARLY
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentMethod;   // CASH, CARD, PAYPAL, etc.

  // Datos del plan
  final String? planId;          // null si es Free
  final String planName;
  final String planDescription;
  final double planPrice;
  final String planCurrency;
  final double? storageLimitGb;
  final int? maxFiles;  // null = ilimitado
  final int? maxCollaborations;
  final int? maxDocumentariesPerMonth;
  final String? supportLevel;
  int documentariesPurchased;
  int documentariesAvailable;
  final List<ExtraStorageResponse>? extraStorage;

  SubscriptionResponse({
    required this.subscriptionId,
    required this.status,
    required this.frequency,
    this.startDate,
    this.endDate,
    this.paymentMethod,
    this.planId,
    required this.planName,
    required this.planDescription,
    required this.planPrice,
    required this.planCurrency,
    required this.storageLimitGb,
    this.maxFiles,
    this.maxCollaborations,
    this.maxDocumentariesPerMonth,
    this.supportLevel,
    this.documentariesAvailable=0,
    this.documentariesPurchased=0,
    this.extraStorage
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      subscriptionId: json['subscriptionId'],
      status: json['status'] ?? 'NONE',
      frequency: json['frequency'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      paymentMethod: json['paymentMethod'] ?? json['currentPaymentMethod'],
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? 'DESCUBRE_LIRIUM',
      planDescription: json['planDescription'] ?? '',
      planPrice: (json['planPrice'] ?? 0).toDouble(),
      planCurrency: json['planCurrency'] ?? 'USD',
      storageLimitGb: (json['storageLimitGb'] ?? 15).toDouble(),
      maxFiles: json['maxFiles'],
      maxCollaborations: json['maxCollaborations'],
      maxDocumentariesPerMonth: json['maxDocumentariesPerMonth'],
      supportLevel: json['supportLevel'],
      extraStorage: json['extraStorageSubscriptions'] != null
          ? List<ExtraStorageResponse>.from(
          json['extraStorageSubscriptions']
              .map((x) => ExtraStorageResponse.fromJson(x)))
          : [],
      documentariesAvailable: json['documentariesAvailable'] ?? 0,
      documentariesPurchased: json['documentariesPurchased'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'status': status,
      'frequency': frequency,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'planId': planId,
      'planName': planName,
      'planDescription': planDescription,
      'planPrice': planPrice,
      'planCurrency': planCurrency,
      'storageLimitGb': storageLimitGb,
      'maxFiles': maxFiles,
      'maxCollaborations': maxCollaborations,
      'maxDocumentariesPerMonth': maxDocumentariesPerMonth,
      'supportLevel': supportLevel,
      'extraStorageSubscriptions': extraStorage?.map((x) => x.toJson()).toList(),
      'documentalesComprados': documentariesPurchased,
      'documentalesDisponibles':documentariesAvailable,
    };
  }

}