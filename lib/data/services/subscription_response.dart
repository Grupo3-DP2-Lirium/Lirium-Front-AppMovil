class SubscriptionResponse {
  final String? subscriptionId; // null si es Free
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
      planName: json['planName'] ?? 'Free',
      planDescription: json['planDescription'] ?? '',
      planPrice: (json['planPrice'] ?? 0).toDouble(),
      planCurrency: json['planCurrency'] ?? 'USD',
    );
  }
}