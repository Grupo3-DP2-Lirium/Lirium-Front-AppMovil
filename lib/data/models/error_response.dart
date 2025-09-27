class ErrorResponse {
  final String message;
  final int? statusCode;
  final String? error;

  ErrorResponse({
    required this.message,
    this.statusCode,
    this.error,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] ?? 'Error desconocido',
      statusCode: json['statusCode'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'error': error,
    };
  }
}