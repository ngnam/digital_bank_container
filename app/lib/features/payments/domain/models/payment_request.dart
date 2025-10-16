class PaymentRequest {
  final int fromAccountId;
  final int? toAccountId; // internal
  final String? toBankCode; // external
  final String? toAccountNumber;
  final String? toName;
  final double amount;
  final String? description;

  PaymentRequest({
    required this.fromAccountId,
    this.toAccountId,
    this.toBankCode,
    this.toAccountNumber,
    this.toName,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJsonInternal() => {
    'fromAccountId': fromAccountId,
    'toAccountId': toAccountId,
    'amount': amount,
    'description': description,
  };

  Map<String, dynamic> toJsonExternal() => {
    'fromAccountId': fromAccountId,
    'toBankCode': toBankCode,
    'toAccountNumber': toAccountNumber,
    'toName': toName,
    'amount': amount,
    'description': description,
  };
}
