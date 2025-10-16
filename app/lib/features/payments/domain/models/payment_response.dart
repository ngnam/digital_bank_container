class PaymentResponse {
  final String id;
  final String status; // PENDING_2FA, SUCCESS, FAILED

  PaymentResponse({required this.id, required this.status});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) => PaymentResponse(
    id: json['id'] as String,
    status: json['status'] as String,
  );
}
