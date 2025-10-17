import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.description,
    required super.timestamp,
    super.currency,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'],
        type: json['type'],
        amount: (json['amount'] as num).toDouble(),
        description: json['description'],
        timestamp: DateTime.parse(json['timestamp']),
        currency: json['currency'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'currency': currency,
      };
}
