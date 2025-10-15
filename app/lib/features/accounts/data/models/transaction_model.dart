import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required int id,
    required String type,
    required double amount,
    required String description,
    required DateTime timestamp,
  }) : super(
          id: id,
          type: type,
          amount: amount,
          description: description,
          timestamp: timestamp,
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'],
        type: json['type'],
        amount: (json['amount'] as num).toDouble(),
        description: json['description'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };
}
