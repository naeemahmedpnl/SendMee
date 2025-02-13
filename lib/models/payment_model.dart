class PaymentResponse {
  final String clientSecret;
  final bool success;
  final String? error;

  PaymentResponse({
    required this.clientSecret,
    required this.success,
    this.error,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      clientSecret: json['clientSecret'] ?? '',
      success: json['success'] ?? false,
      error: json['error'],
    );
  }
}