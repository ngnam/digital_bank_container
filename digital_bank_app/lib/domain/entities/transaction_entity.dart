// lib/domain/entities/transaction_entity.dart
enum TransactionType {
  all,
  deposit,
  withdrawal,
  transfer,
  payment,
}

enum TransactionStatus {
  pending,
  success,
  failed,
}

class TransactionEntity {
  final String id;
  final String accountId;
  final DateTime date;
  final double amount;
  final String description;

  // Bổ sung để đáp ứng phần UI/logic (type, status, currency)
  final TransactionType type;
  final TransactionStatus status;
  final String currency;

  const TransactionEntity({
    required this.id,
    required this.accountId,
    required this.date,
    required this.amount,
    required this.description,
    this.type = TransactionType.transfer,
    this.status = TransactionStatus.success,
    this.currency = 'VND',
  });
}
